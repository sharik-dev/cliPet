import AppKit

// Sparkle pilote les mises à jour automatiques (notif + install en 1 clic).
// L'import est conditionnel : tant que le package SPM n'est pas ajouté, un stub
// garde le projet compilable. Dès que Sparkle est lié, le vrai updater s'active.

#if canImport(Sparkle)
import Sparkle

/// Wrapper autour de `SPUStandardUpdaterController` : vérifs auto (selon l'Info.plist)
/// + action manuelle « Rechercher des mises à jour… » depuis le menu.
final class UpdaterController {
    static let shared = UpdaterController()
    private let controller: SPUStandardUpdaterController

    private init() {
        // startingUpdater: true → démarre le scheduler de vérifs automatiques.
        controller = SPUStandardUpdaterController(startingUpdater: true,
                                                  updaterDelegate: nil,
                                                  userDriverDelegate: nil)
    }

    var canCheckForUpdates: Bool { controller.updater.canCheckForUpdates }

    /// Vérif manuelle : affiche l'UI Sparkle (trouvé / à jour / erreur).
    func checkForUpdates() { controller.updater.checkForUpdates() }

    /// Opt-in aux vérifications automatiques (exposable dans les Réglages).
    var automaticallyChecksForUpdates: Bool {
        get { controller.updater.automaticallyChecksForUpdates }
        set { controller.updater.automaticallyChecksForUpdates = newValue }
    }
}

#else

/// Stub actif tant que le package Sparkle n'est pas ajouté (garde le build vert).
final class UpdaterController {
    static let shared = UpdaterController()
    private init() {}
    var canCheckForUpdates: Bool { false }
    func checkForUpdates() {
        NSLog("[cliPet] Sparkle absent — ajoute le package SPM pour activer les mises à jour.")
    }
    var automaticallyChecksForUpdates: Bool {
        get { false }
        set { _ = newValue }
    }
}

#endif
