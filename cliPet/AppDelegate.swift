import AppKit
import SwiftUI
import Combine

/// Point d'orchestration de l'app (mode agent, sans fenêtre principale).
@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    let settings = PetSettings()
    private(set) lazy var clipboard = ClipboardManager(settings: settings)
    private(set) lazy var engine = PetEngine(settings: settings)
    private var petController: PetController?
    private var statusItem: NSStatusItem?
    private var hidePetItem: NSMenuItem?
    private var cancellables = Set<AnyCancellable>()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Agent : pas d'icône Dock, vit dans la barre de menus.
        NSApp.setActivationPolicy(.accessory)

        petController = PetController(engine: engine, settings: settings, clipboard: clipboard)
        clipboard.start()
        engine.start()

        // Démarre Sparkle (vérifs auto des mises à jour selon l'Info.plist).
        _ = UpdaterController.shared

        setupStatusItem()

        // Licence / essai : verrouille si l'essai est fini et aucune clé valide.
        enforceLicense()

        // Analytics anonymes (tunnel de vente) — aucune donnée perso.
        Analytics.trackFirstLaunchOnce()

        // Rebuild menu when language changes.
        settings.$language.dropFirst().receive(on: RunLoop.main).sink { [weak self] _ in
            self?.rebuildMenu()
        }.store(in: &cancellables)

        // Guidage « lancer au démarrage » au tout premier lancement.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.promptLaunchAtLoginIfNeeded()
        }
    }

    /// Propose une seule fois d'ajouter cliPet aux apps lancées au démarrage.
    private func promptLaunchAtLoginIfNeeded() {
        let key = "cliPet.didPromptLaunchAtLogin"
        if UserDefaults.standard.bool(forKey: key) { return }
        if LaunchAtLogin.isEnabled { UserDefaults.standard.set(true, forKey: key); return }
        UserDefaults.standard.set(true, forKey: key)

        let l = L10n.for_(L10n.Language(rawValue: settings.language) ?? .en)
        let alert = NSAlert()
        alert.messageText = l.launchPromptTitle
        alert.informativeText = l.launchPromptBody
        alert.addButton(withTitle: l.launchEnable)
        alert.addButton(withTitle: l.launchLater)

        NSApp.activate(ignoringOtherApps: true)
        if alert.runModal() == .alertFirstButtonReturn {
            // Échec d'enregistrement → ouvrir les Réglages Système.
            if !LaunchAtLogin.setEnabled(true) { LaunchAtLogin.openLoginItemsSettings() }
        }
    }

    // MARK: - Licence / essai

    private let license = LicenseManager.shared

    /// Verrouille l'app derrière le paywall si l'essai est terminé sans licence.
    private func enforceLicense() {
        license.startTrialIfNeeded()
        if !license.hasOptimisticAccess { lockBehindPaywall() }

        // Revalidation réseau silencieuse : verrouille seulement si confirmé invalide.
        Task { @MainActor in
            await license.revalidateOnLaunch()
            if !license.hasAccess { lockBehindPaywall() }
        }
    }

    private func lockBehindPaywall() {
        Analytics.track("app_paywall_shown")
        petController?.setPetHidden(true, animated: false)
        petController?.showLicenseWindow(license: license, locked: true) { [weak self] in
            self?.petController?.setPetHidden(false, animated: false)
        }
    }

    @objc private func openLicense() {
        petController?.showLicenseWindow(license: license, locked: false) {}
    }

    func applicationWillTerminate(_ notification: Notification) {
        engine.stop()
        clipboard.stop()
    }

    // MARK: - Barre d'état

    private func setupStatusItem() {
        let item = NSStatusItem.create()
        if let button = item.button {
            button.image = NSImage(systemSymbolName: "pawprint.fill", accessibilityDescription: "cliPet")
        }
        item.menu = buildMenu()
        statusItem = item
    }

    private func rebuildMenu() {
        statusItem?.menu = buildMenu()
        // Sync hide/show label with current state after rebuild.
        let hidden = petController?.isPetHidden ?? false
        let l10n = L10n.for_(L10n.Language(rawValue: settings.language) ?? .en)
        hidePetItem?.title = hidden ? l10n.menuShowPet : l10n.menuHidePet
    }

    private func buildMenu() -> NSMenu {
        let l10n = L10n.for_(L10n.Language(rawValue: settings.language) ?? .en)
        let menu = NSMenu()
        menu.addItem(withTitle: l10n.menuClipboard,
                     action: #selector(toggleClipboard), keyEquivalent: "")
            .target = self
        let hideItem = menu.addItem(withTitle: l10n.menuHidePet,
                                    action: #selector(toggleHidePet), keyEquivalent: "h")
        hideItem.target = self
        hidePetItem = hideItem
        menu.delegate = self   // resync du libellé Masquer/Afficher à chaque ouverture
        menu.addItem(.separator())
        menu.addItem(withTitle: l10n.menuSettings,
                     action: #selector(openSettings), keyEquivalent: ",")
            .target = self
        menu.addItem(withTitle: l10n.menuClearHistory,
                     action: #selector(clearHistory), keyEquivalent: "")
            .target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: l10n.menuCheckUpdates,
                     action: #selector(checkForUpdates), keyEquivalent: "")
            .target = self
        menu.addItem(withTitle: l10n.menuLicense,
                     action: #selector(openLicense), keyEquivalent: "")
            .target = self
        menu.addItem(withTitle: l10n.menuSupport,
                     action: #selector(openSupport), keyEquivalent: "")
            .target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: l10n.menuQuit,
                     action: #selector(quit), keyEquivalent: "q")
            .target = self
        return menu
    }

    @objc private func toggleClipboard() { petController?.toggleClipboardPanel() }
    @objc private func openEditor() { petController?.openSpriteEditor() }
    @objc private func openSkins() { petController?.openSkinManager() }
    @objc private func clearHistory() { petController?.showClearHistoryConfirm() }
    @objc private func quit() { NSApp.terminate(nil) }
    @objc private func openSettings() { petController?.openSettings() }
    @objc private func checkForUpdates() { UpdaterController.shared.checkForUpdates() }

    /// Ouvre le client mail de l'utilisateur, pré-rempli vers le support cliPet.
    @objc private func openSupport() {
        let subject = "cliPet — Support"
        let encoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject
        if let url = URL(string: "mailto:sharikmohamed9@gmail.com?subject=\(encoded)") {
            NSWorkspace.shared.open(url)
        }
    }

    /// Avant l'affichage du menu : resynchronise le libellé Masquer/Afficher
    /// (l'état peut avoir changé hors menu, ex. bouton « masquer » du presse-papiers).
    func menuNeedsUpdate(_ menu: NSMenu) {
        let hidden = petController?.isPetHidden ?? false
        let l10n = L10n.for_(L10n.Language(rawValue: settings.language) ?? .en)
        hidePetItem?.title = hidden ? l10n.menuShowPet : l10n.menuHidePet
    }

    @objc private func toggleHidePet() {
        petController?.togglePetVisible()
        let hidden = petController?.isPetHidden ?? false
        let l10n = L10n.for_(L10n.Language(rawValue: settings.language) ?? .en)
        hidePetItem?.title = hidden ? l10n.menuShowPet : l10n.menuHidePet
    }
}

private extension NSStatusItem {
    static func create() -> NSStatusItem {
        NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    }
}
