import AppKit
import SwiftUI
import Combine

extension Notification.Name {
    /// Demande l'ouverture de l'éditeur de pet (émise depuis les réglages).
    static let openPetEditor = Notification.Name("cliPet.openPetEditor")
}

/// Panneau flottant qui peut devenir « key » sans activer l'app (pour recevoir les clics).
final class FloatingPanel: NSPanel {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}

/// Vue d'hébergement du jouet (pelote) : suit l'engine en direct.
struct ToyHostView: View {
    @ObservedObject var engine: PetEngine
    @ObservedObject var settings: PetSettings
    var body: some View {
        ToyView(tick: engine.animTick, rolling: engine.toyRolling,
                bodyColor: settings.bodyColor, bellyColor: settings.bellyColor,
                stripeColor: settings.stripeColor, eyeColor: settings.eyeColor,
                noseColor: settings.noseColor)
            .frame(width: engine.toySize, height: engine.toySize)
    }
}

/// Gère la fenêtre du chat, la pelote, le panneau d'historique et l'éditeur dev.
final class PetController {
    private let engine: PetEngine
    private let settings: PetSettings
    private let clipboard: ClipboardManager
    private let folderStore = ClipFolderStore()

    private let petPanel: FloatingPanel
    private let toyPanel: FloatingPanel
    private var clipPanel: FloatingPanel?
    private var editorWindow: NSWindow?
    private var skinWindow: NSWindow?
    private var settingsWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    private var clipResignObserver: NSObjectProtocol?

    /// Le pet est-il masqué (caché par l'utilisateur) ?
    private(set) var isPetHidden = false

    init(engine: PetEngine, settings: PetSettings, clipboard: ClipboardManager) {
        self.engine = engine
        self.settings = settings
        self.clipboard = clipboard

        let size = engine.spriteSize
        petPanel = FloatingPanel(
            contentRect: NSRect(x: engine.position.x, y: engine.position.y, width: size, height: size),
            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        toyPanel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: engine.toySize, height: engine.toySize),
            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        configure(petPanel)
        configure(toyPanel)
        toyPanel.ignoresMouseEvents = true   // décoratif

        let host = NSHostingView(rootView: PetView(engine: engine, settings: settings) { [weak self] in
            self?.toggleClipboardPanel()
        })
        host.frame = NSRect(x: 0, y: 0, width: size, height: size)
        host.autoresizingMask = [.width, .height]
        petPanel.contentView = host
        petPanel.orderFrontRegardless()

        let toyHost = NSHostingView(rootView: ToyHostView(engine: engine, settings: settings))
        toyHost.autoresizingMask = [.width, .height]
        toyPanel.contentView = toyHost

        bind()
    }

    private func configure(_ panel: FloatingPanel) {
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        panel.isMovableByWindowBackground = false
        panel.hidesOnDeactivate = false
        panel.isFloatingPanel = true
        panel.becomesKeyOnlyIfNeeded = true
    }

    private func bind() {
        // Pas de `.receive(on:)` : pendant un drag, le run loop est en mode
        // event-tracking et un hop RunLoop.main ne serait pas livré avant le
        // relâcher. setDraggedOrigin/tick sont déjà sur le main thread, donc
        // la livraison synchrone déplace la fenêtre en direct.
        engine.$position.sink { [weak self] origin in
            guard let self else { return }
            self.petPanel.setFrameOrigin(origin)
            self.repositionClipPanel()
        }.store(in: &cancellables)

        engine.$spriteSize.receive(on: RunLoop.main).sink { [weak self] size in
            guard let self else { return }
            var f = self.petPanel.frame; f.size = NSSize(width: size, height: size)
            self.petPanel.setFrame(f, display: true)
        }.store(in: &cancellables)

        // Jouet
        engine.$toyPosition.sink { [weak self] p in
            self?.toyPanel.setFrameOrigin(p)
        }.store(in: &cancellables)

        engine.$toySize.receive(on: RunLoop.main).sink { [weak self] s in
            guard let self else { return }
            var f = self.toyPanel.frame; f.size = NSSize(width: s, height: s)
            self.toyPanel.setFrame(f, display: true)
        }.store(in: &cancellables)

        engine.$toyVisible.receive(on: RunLoop.main).sink { [weak self] visible in
            guard let self, !self.isPetHidden else { return }
            if visible { self.toyPanel.orderFront(nil) } else { self.toyPanel.orderOut(nil) }
        }.store(in: &cancellables)

        settings.$scale.receive(on: RunLoop.main).sink { [weak self] _ in
            self?.engine.recomputeSize()
        }.store(in: &cancellables)

        // Changement de skin → recalcule la taille (un skin peut avoir une grille différente).
        SpriteStore.shared.$activeSkinId.receive(on: RunLoop.main).sink { [weak self] _ in
            self?.engine.recomputeSize()
        }.store(in: &cancellables)

        // L'éditeur peut être ouvert depuis les réglages (onglet « Mon pet »).
        NotificationCenter.default.publisher(for: .openPetEditor)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.openSpriteEditor() }
            .store(in: &cancellables)
    }

    // MARK: - Historique

    func toggleClipboardPanel() {
        if clipPanel != nil { hideClipboardPanel() } else { showClipboardPanel() }
    }

    private func showClipboardPanel() {
        let view = ClipboardHistoryView(
            clipboard: clipboard,
            folders: folderStore,
            l10n: L10n.for_(L10n.Language(rawValue: settings.language) ?? .en),
            onPick: { [weak self] item in self?.clipboard.copyToPasteboard(item); self?.hideClipboardPanel() },
            onClose: { [weak self] in self?.hideClipboardPanel() })
        let host = NSHostingView(rootView: view)
        host.layoutSubtreeIfNeeded()
        let fit = host.fittingSize
        host.frame = NSRect(x: 0, y: 0, width: max(300, fit.width), height: max(160, fit.height))

        let panel = FloatingPanel(contentRect: host.frame,
            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        configure(panel)
        panel.contentView = host
        clipPanel = panel
        repositionClipPanel()
        panel.makeKeyAndOrderFront(nil)
        engine.isPaused = true

        clipResignObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification, object: panel, queue: .main
        ) { [weak self] _ in self?.hideClipboardPanel() }
    }

    private func hideClipboardPanel() {
        if let obs = clipResignObserver {
            NotificationCenter.default.removeObserver(obs); clipResignObserver = nil
        }
        clipPanel?.orderOut(nil)
        clipPanel = nil
        engine.isPaused = false
    }

    private func repositionClipPanel() {
        guard let clipPanel else { return }
        let pet = petPanel.frame
        let pw = clipPanel.frame.width
        let visible = PetEngine.visibleFrame()
        var x = pet.midX - pw / 2
        x = min(max(x, visible.minX + 8), visible.maxX - pw - 8)
        let y = min(pet.maxY + 8, visible.maxY - clipPanel.frame.height - 8)
        clipPanel.setFrameOrigin(NSPoint(x: x, y: y))
    }

    // MARK: - Éditeur dev

    static func requestOpenEditor() {
        NotificationCenter.default.post(name: .openPetEditor, object: nil)
    }

    func openSpriteEditor() {
        NSApp.activate(ignoringOtherApps: true)
        if let w = editorWindow { w.makeKeyAndOrderFront(nil); return }

        let view = SpriteEditorView().environmentObject(settings)
        let hosting = NSHostingController(rootView: view)
        let w = NSWindow(contentViewController: hosting)
        w.title = "Éditeur de sprite — cliPet"
        w.styleMask = [.titled, .closable, .miniaturizable, .resizable]
        w.setContentSize(NSSize(width: 560, height: 640))
        w.isReleasedWhenClosed = false
        w.center()
        w.makeKeyAndOrderFront(nil)
        editorWindow = w
    }

    func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        if let w = settingsWindow { w.makeKeyAndOrderFront(nil); return }
        let view = SettingsView().environmentObject(settings)
        let w = NSWindow(contentViewController: NSHostingController(rootView: view))
        w.title = "Réglages — cliPet"
        w.styleMask = [.titled, .closable, .miniaturizable]
        w.isReleasedWhenClosed = false
        w.center()
        w.makeKeyAndOrderFront(nil)
        settingsWindow = w
    }

    // MARK: - Masquer / afficher le pet

    func togglePetVisible() { setPetHidden(!isPetHidden) }

    func setPetHidden(_ hidden: Bool) {
        isPetHidden = hidden
        engine.isPaused = hidden
        if hidden {
            petPanel.orderOut(nil)
            toyPanel.orderOut(nil)
        } else {
            petPanel.orderFrontRegardless()
            if engine.toyVisible { toyPanel.orderFront(nil) }
        }
    }

    func openSkinManager() {
        NSApp.activate(ignoringOtherApps: true)
        if let w = skinWindow { w.makeKeyAndOrderFront(nil); return }
        let view = SkinManagerView().environmentObject(settings)
        let w = NSWindow(contentViewController: NSHostingController(rootView: view))
        w.title = "Gestionnaire de skins — cliPet"
        w.styleMask = [.titled, .closable, .miniaturizable]
        w.isReleasedWhenClosed = false
        w.center()
        w.makeKeyAndOrderFront(nil)
        skinWindow = w
    }
}
