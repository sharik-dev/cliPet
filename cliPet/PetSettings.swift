import SwiftUI
import Combine

/// Réglages persistés du pet : couleurs, vitesse, comportements.
/// Persistés dans UserDefaults via une clé JSON unique.
final class PetSettings: ObservableObject {

    // MARK: - Couleurs (la partie esthétique qu'on affinera ensemble)
    @Published var bodyColor: Color   { didSet { save() } }   // pelage principal
    @Published var bellyColor: Color  { didSet { save() } }   // ventre / museau / pattes
    @Published var stripeColor: Color { didSet { save() } }   // rayures / ombres
    @Published var eyeColor: Color    { didSet { save() } }   // yeux
    @Published var noseColor: Color   { didSet { save() } }   // nez

    // MARK: - Comportement
    @Published var speed: Double      { didSet { save() } }   // 0.5 = lent, 2.0 = rapide
    @Published var scale: Double      { didSet { save() } }   // taille du chat à l'écran
    @Published var mischiefEnabled: Bool { didSet { save() } } // bêtises actives
    @Published var chaseCursor: Bool  { didSet { save() } }   // poursuit le curseur
    @Published var toyEnabled: Bool   { didSet { save() } }   // joue avec la pelote

    // MARK: - Clipboard
    @Published var maxHistory: Int    { didSet { save() } }   // nb max d'items gardés

    // MARK: - Language
    @Published var language: String   { didSet { save() } }   // BCP-47 code, e.g. "en"

    // MARK: - Variantes (coats) sauvegardées par l'utilisateur
    @Published var customCoats: [PetPreset] = []   { didSet { save() } }

    private var isLoading = false

    init() {
        bodyColor   = Color(hex: "#969BA1")
        bellyColor  = Color(hex: "#F5F5F5")
        stripeColor = Color(hex: "#3C4045")
        eyeColor    = Color(hex: "#141414")
        noseColor   = Color(hex: "#CE2828")
        speed       = 1.0
        scale       = 0.5
        mischiefEnabled = true
        chaseCursor = true
        toyEnabled  = true
        maxHistory  = 50
        language    = "en"
        load()
    }

    /// Applique un preset du catalogue.
    func apply(_ preset: PetPreset) {
        isLoading = true
        bodyColor = Color(hex: preset.body)
        bellyColor = Color(hex: preset.belly)
        stripeColor = Color(hex: preset.stripe)
        eyeColor = Color(hex: preset.eye)
        noseColor = Color(hex: preset.nose)
        isLoading = false
        save()
    }

    /// Sauvegarde le jeu de couleurs courant comme nouvelle variante (coat).
    @discardableResult
    func saveCurrentAsCoat(name: String) -> PetPreset {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeName = trimmed.isEmpty ? "Variant \(customCoats.count + 1)" : trimmed
        let coat = PetPreset(
            id: "user-\(UUID().uuidString)", name: safeName,
            body: bodyColor.hexString, belly: bellyColor.hexString,
            stripe: stripeColor.hexString, eye: eyeColor.hexString, nose: noseColor.hexString)
        customCoats.append(coat)
        return coat
    }

    func removeCoat(_ coat: PetPreset) {
        customCoats.removeAll { $0.id == coat.id }
    }

    // MARK: - Persistance

    private struct Payload: Codable {
        var body, belly, stripe, eye, nose: String
        var speed, scale: Double
        var mischief, chase: Bool
        var toy: Bool
        var maxHistory: Int
        var language: String
        var customCoats: [PetPreset]?

        init(body: String, belly: String, stripe: String, eye: String, nose: String,
             speed: Double, scale: Double, mischief: Bool, chase: Bool, toy: Bool,
             maxHistory: Int, language: String, customCoats: [PetPreset]) {
            self.body = body; self.belly = belly; self.stripe = stripe
            self.eye = eye; self.nose = nose; self.speed = speed; self.scale = scale
            self.mischief = mischief; self.chase = chase; self.toy = toy
            self.maxHistory = maxHistory; self.language = language
            self.customCoats = customCoats
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            body      = try c.decode(String.self, forKey: .body)
            belly     = try c.decode(String.self, forKey: .belly)
            stripe    = try c.decode(String.self, forKey: .stripe)
            eye       = try c.decode(String.self, forKey: .eye)
            nose      = try c.decode(String.self, forKey: .nose)
            speed     = try c.decode(Double.self, forKey: .speed)
            scale     = try c.decode(Double.self, forKey: .scale)
            mischief  = try c.decode(Bool.self,   forKey: .mischief)
            chase     = try c.decode(Bool.self,   forKey: .chase)
            toy       = (try? c.decode(Bool.self, forKey: .toy)) ?? true
            maxHistory = try c.decode(Int.self,   forKey: .maxHistory)
            language  = (try? c.decode(String.self, forKey: .language)) ?? "en"
            customCoats = (try? c.decode([PetPreset].self, forKey: .customCoats)) ?? []
        }
    }

    private static let key = "cliPet.settings.v1"

    private func save() {
        guard !isLoading else { return }
        let p = Payload(
            body: bodyColor.hexString, belly: bellyColor.hexString,
            stripe: stripeColor.hexString, eye: eyeColor.hexString, nose: noseColor.hexString,
            speed: speed, scale: scale,
            mischief: mischiefEnabled, chase: chaseCursor, toy: toyEnabled, maxHistory: maxHistory,
            language: language, customCoats: customCoats
        )
        if let data = try? JSONEncoder().encode(p) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
        objectWillChange.send()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: Self.key),
              let p = try? JSONDecoder().decode(Payload.self, from: data) else { return }
        isLoading = true
        bodyColor = Color(hex: p.body)
        bellyColor = Color(hex: p.belly)
        stripeColor = Color(hex: p.stripe)
        eyeColor = Color(hex: p.eye)
        noseColor = Color(hex: p.nose)
        speed = p.speed
        scale = p.scale
        mischiefEnabled = p.mischief
        chaseCursor = p.chase
        toyEnabled = p.toy
        maxHistory = p.maxHistory
        language = p.language
        customCoats = p.customCoats ?? []
        isLoading = false
    }

    func resetToDefaults() {
        UserDefaults.standard.removeObject(forKey: Self.key)
        isLoading = true
        bodyColor = Color(hex: "#969BA1")
        bellyColor = Color(hex: "#F5F5F5")
        stripeColor = Color(hex: "#3C4045")
        eyeColor = Color(hex: "#141414")
        noseColor = Color(hex: "#CE2828")
        speed = 1.0; scale = 0.5
        mischiefEnabled = true; chaseCursor = true; toyEnabled = true; maxHistory = 50
        language = "en"
        isLoading = false
        save()
    }
}

// MARK: - Color <-> Hex (NSColor pour résoudre en composantes RGB)

extension Color {
    init(hex: String) {
        let s = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")).uppercased()
        var rgb: UInt64 = 0
        Scanner(string: s).scanHexInt64(&rgb)
        let r, g, b, a: Double
        if s.count == 8 {
            r = Double((rgb >> 24) & 0xFF) / 255
            g = Double((rgb >> 16) & 0xFF) / 255
            b = Double((rgb >> 8) & 0xFF) / 255
            a = Double(rgb & 0xFF) / 255
        } else {
            r = Double((rgb >> 16) & 0xFF) / 255
            g = Double((rgb >> 8) & 0xFF) / 255
            b = Double(rgb & 0xFF) / 255
            a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    var hexString: String {
        let ns = NSColor(self).usingColorSpace(.sRGB) ?? .black
        let r = Int(round(ns.redComponent * 255))
        let g = Int(round(ns.greenComponent * 255))
        let b = Int(round(ns.blueComponent * 255))
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
