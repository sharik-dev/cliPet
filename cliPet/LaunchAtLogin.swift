import AppKit
import ServiceManagement

/// Gestion de « Lancer au démarrage » via le service moderne `SMAppService`
/// (macOS 13+). Sur les systèmes plus anciens, on guide l'utilisateur vers
/// les Réglages Système > Éléments d'ouverture.
enum LaunchAtLogin {

    /// L'app est-elle actuellement enregistrée comme élément d'ouverture ?
    static var isEnabled: Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }

    /// Active / désactive le lancement au démarrage.
    /// Renvoie `false` si l'opération échoue (app non signée, hors /Applications,
    /// géré par MDM…) — dans ce cas, guider l'utilisateur manuellement.
    @discardableResult
    static func setEnabled(_ enabled: Bool) -> Bool {
        guard #available(macOS 13.0, *) else { return false }
        do {
            if enabled {
                if SMAppService.mainApp.status != .enabled {
                    try SMAppService.mainApp.register()
                }
            } else {
                if SMAppService.mainApp.status == .enabled {
                    try SMAppService.mainApp.unregister()
                }
            }
            return true
        } catch {
            NSLog("[cliPet] LaunchAtLogin error: \(error)")
            return false
        }
    }

    /// Ouvre le volet Réglages Système > Général > Éléments d'ouverture.
    static func openLoginItemsSettings() {
        let candidates = [
            "x-apple.systempreferences:com.apple.LoginItems-Settings.extension",
            "x-apple.systempreferences:com.apple.preference.general",
        ]
        for raw in candidates {
            if let url = URL(string: raw), NSWorkspace.shared.open(url) { return }
        }
    }
}
