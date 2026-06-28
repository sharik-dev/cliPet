import Foundation

// ============================================================================
// Analytics anonymes (tunnel de vente). Envoi best-effort, jamais bloquant.
//
// PRIVACY : aucune donnée personnelle, JAMAIS le contenu du presse-papiers ni
// des pets. Uniquement un identifiant anonyme aléatoire + le nom d'événement
// (ex. "app_paywall_shown") pour comprendre où les utilisateurs décrochent.
// ============================================================================

enum Analytics {
    private static let endpoint = URL(string: "https://clipet.sharik.fr/api/events")!
    private static let idKey = "cliPet.analytics.anonId"
    private static let firstKey = "cliPet.analytics.firstLaunchSent"

    /// Identifiant anonyme stable (UUID aléatoire, aucune info machine).
    private static var anonId: String {
        if let v = UserDefaults.standard.string(forKey: idKey) { return v }
        let v = UUID().uuidString
        UserDefaults.standard.set(v, forKey: idKey)
        return v
    }

    /// Émet un événement (best-effort, ignore les erreurs réseau).
    static func track(_ name: String, _ props: [String: String]? = nil) {
        var body: [String: Any] = ["name": name, "source": "app", "anonId": anonId]
        if let props { body["props"] = props }
        var req = URLRequest(url: endpoint)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: req).resume()
    }

    /// Premier lancement : émis une seule fois sur la durée de vie de l'install.
    static func trackFirstLaunchOnce() {
        if UserDefaults.standard.bool(forKey: firstKey) { return }
        UserDefaults.standard.set(true, forKey: firstKey)
        track("app_first_launch")
    }
}
