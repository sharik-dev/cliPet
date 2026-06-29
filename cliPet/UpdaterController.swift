import AppKit

#if canImport(Sparkle)
import Sparkle

final class UpdaterController {
    static let shared = UpdaterController()

    private let updater: SPUUpdater
    // Driver kept alive as a strong reference (SPUUpdater holds it weakly)
    private let driver = PixelUpdateDriver()

    private init() {
        updater = SPUUpdater(
            hostBundle: Bundle.main,
            applicationBundle: Bundle.main,
            userDriver: driver,
            delegate: nil
        )
        try? updater.start()
    }

    var canCheckForUpdates: Bool { updater.canCheckForUpdates }
    func checkForUpdates() { updater.checkForUpdates() }

    var automaticallyChecksForUpdates: Bool {
        get { updater.automaticallyChecksForUpdates }
        set { updater.automaticallyChecksForUpdates = newValue }
    }
}

#else

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
