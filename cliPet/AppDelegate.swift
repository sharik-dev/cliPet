import AppKit
import SwiftUI

/// Point d'orchestration de l'app (mode agent, sans fenêtre principale).
final class AppDelegate: NSObject, NSApplicationDelegate {
    let settings = PetSettings()
    private(set) lazy var clipboard = ClipboardManager(settings: settings)
    private(set) lazy var engine = PetEngine(settings: settings)
    private var petController: PetController?
    private var statusItem: NSStatusItem?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Agent : pas d'icône Dock, vit dans la barre de menus.
        NSApp.setActivationPolicy(.accessory)

        petController = PetController(engine: engine, settings: settings, clipboard: clipboard)
        clipboard.start()
        engine.start()

        setupStatusItem()
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

        let menu = NSMenu()
        menu.addItem(withTitle: "Historique du presse-papiers",
                     action: #selector(toggleClipboard), keyEquivalent: "")
            .target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Réglages…",
                     action: #selector(openSettings), keyEquivalent: ",")
            .target = self
        menu.addItem(withTitle: "Vider l'historique",
                     action: #selector(clearHistory), keyEquivalent: "")
            .target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Éditeur de sprite (dev)…",
                     action: #selector(openEditor), keyEquivalent: "e")
            .target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quitter cliPet",
                     action: #selector(quit), keyEquivalent: "q")
            .target = self

        item.menu = menu
        statusItem = item
    }

    @objc private func toggleClipboard() { petController?.toggleClipboardPanel() }
    @objc private func openEditor() { petController?.openSpriteEditor() }
    @objc private func clearHistory() { clipboard.clear() }
    @objc private func quit() { NSApp.terminate(nil) }

    @objc private func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        // macOS 14+ : showSettingsWindow: — fallback showPreferencesWindow: pour macOS 13.
        if !NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil) {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
}

private extension NSStatusItem {
    static func create() -> NSStatusItem {
        NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    }
}
