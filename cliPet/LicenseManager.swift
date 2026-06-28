import Foundation
import Combine

// ============================================================================
// Licence — vérification multi-canal (Gumroad + LemonSqueezy).
//
// Une clé achetée sur N'IMPORTE quel canal doit pouvoir s'activer. Le manager
// essaie chaque provider à l'activation et mémorise celui qui a réussi, puis
// revalide silencieusement au lancement.
//
// ⚠️ CONFIG À REMPLIR (Phase B, quand les comptes existent) :
//   • Gumroad      : LicenseConfig.gumroadProductId
//   • LemonSqueezy : LicenseConfig.lemonStoreId / lemonProductId (filtrage facultatif)
// Tant que c'est vide, l'activation échoue proprement (état .invalid) — le build reste vert.
// ============================================================================

enum LicenseConfig {
    /// Gumroad : "product_id" du produit (Settings → Advanced → product_id),
    /// ou le permalink. Laisser vide tant que le produit n'existe pas.
    static let gumroadProductId = ""

    /// LemonSqueezy : facultatif, sert juste à rejeter une clé d'un autre produit.
    static let lemonStoreId = ""
    static let lemonProductId = ""

    /// Durée de l'essai gratuit (en jours) avant que le paywall ne s'active.
    static let trialDays = 3

    /// Page d'achat publique (Gumroad). À remplacer par ton vrai lien produit.
    static let buyURL = "https://clipet.sharik.fr/buy"

    // MARK: - Prix (indicatif — Gumroad/LemonSqueezy encaissent dans la vraie devise)

    /// Prix de référence (USD).
    static let basePrice = "$4.99"

    /// Prix locaux arrondis par devise, calés sur ~4,99 $ (style App Store,
    /// pas de conversion FX brute). Devise détectée via la locale de l'utilisateur.
    static let prices: [String: String] = [
        "USD": "$4.99",
        "EUR": "4,99 €",
        "GBP": "£4.49",
        "CHF": "CHF 4.90",
        "CAD": "CA$6.99",
        "AUD": "A$7.99",
        "JPY": "¥700",
        "CNY": "¥35",
        "INR": "₹399",
        "BRL": "R$24,90",
        "MXN": "$99",
        "RUB": "499 ₽",
        "KRW": "₩6,500",
        "SAR": "ر.س 18.99",
        "AED": "د.إ 18.99",
    ]

    /// Prix à afficher selon la devise locale (repli sur USD).
    static func localizedPrice() -> String {
        let code = Locale.current.currency?.identifier ?? "USD"
        return prices[code] ?? prices["USD"]!
    }
}

// MARK: - Modèle

/// Canal d'origine d'une licence.
enum LicenseChannel: String, Codable {
    case gumroad
    case lemonsqueezy
}

/// État de validité présenté à l'UI.
enum LicenseState: Equatable {
    case unknown          // pas encore vérifié
    case unlicensed       // aucune clé enregistrée
    case valid            // clé valide
    case invalid(String)  // refusée / remboursée (raison)
    case offline          // clé connue mais serveur injoignable → tolérance
}

/// Enregistrement persisté d'une licence activée.
struct LicenseRecord: Codable {
    var key: String
    var channel: LicenseChannel
    var instanceId: String?   // LemonSqueezy renvoie un id d'instance à l'activation
}

// MARK: - Provider (un par canal)

protocol LicenseProvider {
    var channel: LicenseChannel { get }
    /// Active la clé (lie la machine). Renvoie l'enregistrement à persister.
    func activate(key: String) async throws -> LicenseRecord
    /// Revalide un enregistrement existant.
    func validate(_ record: LicenseRecord) async throws -> Bool
}

enum LicenseError: LocalizedError {
    case notConfigured
    case rejected(String)
    case network

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "Licence channel not configured."
        case .rejected(let r): return r
        case .network: return "Could not reach the licence server."
        }
    }
}

// MARK: - Gumroad

/// API Gumroad : POST /v2/licenses/verify (product_id + license_key).
struct GumroadProvider: LicenseProvider {
    let channel: LicenseChannel = .gumroad

    func activate(key: String) async throws -> LicenseRecord {
        let ok = try await verify(key: key)
        guard ok else { throw LicenseError.rejected("Invalid Gumroad licence key.") }
        return LicenseRecord(key: key, channel: .gumroad, instanceId: nil)
    }

    func validate(_ record: LicenseRecord) async throws -> Bool {
        try await verify(key: record.key)
    }

    private func verify(key: String) async throws -> Bool {
        guard !LicenseConfig.gumroadProductId.isEmpty else { throw LicenseError.notConfigured }
        var req = URLRequest(url: URL(string: "https://api.gumroad.com/v2/licenses/verify")!)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        // increment_uses_count=false : ne pas gonfler le compteur à chaque vérif.
        let body = "product_id=\(LicenseConfig.gumroadProductId)&license_key=\(key)&increment_uses_count=false"
        req.httpBody = body.data(using: .utf8)

        let (data, resp) = try await dataTask(req)
        guard let http = resp as? HTTPURLResponse else { throw LicenseError.network }
        // 404 → clé inconnue ; 200 → succès (sauf remboursement/litige).
        guard http.statusCode == 200 else { return false }
        let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        guard (json?["success"] as? Bool) == true,
              let purchase = json?["purchase"] as? [String: Any] else { return false }
        // Rejeter remboursements / litiges / abonnement annulé.
        if (purchase["refunded"] as? Bool) == true { return false }
        if (purchase["chargebacked"] as? Bool) == true { return false }
        if purchase["subscription_cancelled_at"] is String { return false }
        return true
    }
}

// MARK: - LemonSqueezy

/// API LemonSqueezy : /v1/licenses/activate puis /v1/licenses/validate.
struct LemonSqueezyProvider: LicenseProvider {
    let channel: LicenseChannel = .lemonsqueezy

    func activate(key: String) async throws -> LicenseRecord {
        var req = request(path: "activate")
        req.httpBody = form(["license_key": key, "instance_name": instanceName()])
        let (data, resp) = try await dataTask(req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            throw LicenseError.rejected("Invalid LemonSqueezy licence key.")
        }
        let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        guard (json?["activated"] as? Bool) == true,
              let instance = json?["instance"] as? [String: Any],
              let id = instance["id"] as? String else {
            throw LicenseError.rejected("LemonSqueezy activation failed.")
        }
        return LicenseRecord(key: key, channel: .lemonsqueezy, instanceId: id)
    }

    func validate(_ record: LicenseRecord) async throws -> Bool {
        var req = request(path: "validate")
        var fields = ["license_key": record.key]
        if let id = record.instanceId { fields["instance_id"] = id }
        req.httpBody = form(fields)
        let (data, resp) = try await dataTask(req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else { return false }
        let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        return (json?["valid"] as? Bool) == true
    }

    private func request(path: String) -> URLRequest {
        var req = URLRequest(url: URL(string: "https://api.lemonsqueezy.com/v1/licenses/\(path)")!)
        req.httpMethod = "POST"
        req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        return req
    }

    private func form(_ fields: [String: String]) -> Data? {
        fields.map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? $0.value)" }
            .joined(separator: "&").data(using: .utf8)
    }

    /// Nom d'instance = identifiant lisible de la machine (visible dans le dashboard LS).
    private func instanceName() -> String {
        Host.current().localizedName ?? "cliPet device"
    }
}

private extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        var cs = CharacterSet.urlQueryAllowed
        cs.remove(charactersIn: "&=+")
        return cs
    }()
}

/// Petit wrapper async pour URLSession (compatible toutes versions macOS 12+).
private func dataTask(_ request: URLRequest) async throws -> (Data, URLResponse) {
    try await withCheckedThrowingContinuation { cont in
        URLSession.shared.dataTask(with: request) { data, resp, err in
            if let err = err { cont.resume(throwing: err); return }
            guard let data = data, let resp = resp else {
                cont.resume(throwing: LicenseError.network); return
            }
            cont.resume(returning: (data, resp))
        }.resume()
    }
}

// MARK: - Manager

@MainActor
final class LicenseManager: ObservableObject {
    static let shared = LicenseManager()

    @Published private(set) var state: LicenseState = .unknown

    private let providers: [LicenseProvider] = [GumroadProvider(), LemonSqueezyProvider()]
    private static let storeKey = "cliPet.license.v1"
    private static let trialKey = "cliPet.trialStart.v1"

    private var record: LicenseRecord? {
        didSet {
            if let r = record, let data = try? JSONEncoder().encode(r) {
                UserDefaults.standard.set(data, forKey: Self.storeKey)
            } else {
                UserDefaults.standard.removeObject(forKey: Self.storeKey)
            }
        }
    }

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.storeKey),
           let r = try? JSONDecoder().decode(LicenseRecord.self, from: data) {
            record = r
            state = .unknown
        } else {
            state = .unlicensed
        }
    }

    var isLicensed: Bool {
        switch state { case .valid, .offline: return true; default: return false }
    }

    // MARK: - Essai gratuit

    /// Démarre l'essai au tout premier lancement (idempotent).
    func startTrialIfNeeded() {
        if UserDefaults.standard.object(forKey: Self.trialKey) == nil {
            UserDefaults.standard.set(Date(), forKey: Self.trialKey)
        }
    }

    private var trialStart: Date? {
        UserDefaults.standard.object(forKey: Self.trialKey) as? Date
    }

    /// Jours d'essai restants (0 si terminé ou non démarré).
    var trialDaysRemaining: Int {
        guard let start = trialStart else { return LicenseConfig.trialDays }
        let elapsed = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        return max(0, LicenseConfig.trialDays - elapsed)
    }

    var isTrialActive: Bool { trialDaysRemaining > 0 }

    /// Porte d'accès : l'app tourne si licence valide OU essai en cours.
    var hasAccess: Bool { isLicensed || isTrialActive }

    /// Une clé est enregistrée localement (avant même la revalidation réseau).
    var hasStoredLicense: Bool { record != nil }

    /// Accès optimiste au lancement : on ne verrouille pas un porteur de clé
    /// pendant la revalidation (tolérance hors-ligne).
    var hasOptimisticAccess: Bool { hasStoredLicense || isTrialActive }

    /// Active une clé saisie : essaie chaque canal jusqu'à succès.
    func activate(key: String) async {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { state = .invalid("Empty key"); return }

        var lastError = "Invalid licence key."
        for provider in providers {
            do {
                let rec = try await provider.activate(key: trimmed)
                record = rec
                state = .valid
                return
            } catch let LicenseError.rejected(reason) {
                lastError = reason
            } catch LicenseError.notConfigured {
                continue            // canal pas encore configuré → essayer le suivant
            } catch {
                state = .offline    // réseau KO mais clé peut-être bonne
                return
            }
        }
        state = .invalid(lastError)
    }

    /// Revalidation silencieuse au lancement (tolère le hors-ligne).
    func revalidateOnLaunch() async {
        guard let rec = record else { state = .unlicensed; return }
        for provider in providers where provider.channel == rec.channel {
            do {
                state = try await provider.validate(rec) ? .valid : .invalid("Licence no longer valid.")
            } catch {
                state = .offline    // pas de réseau → on n'enferme pas l'utilisateur dehors
            }
            return
        }
    }

    /// Supprime la licence (déconnexion / test).
    func deactivate() {
        record = nil
        state = .unlicensed
    }
}
