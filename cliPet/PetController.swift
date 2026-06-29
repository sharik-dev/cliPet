import AppKit
import SwiftUI
import Combine

extension Notification.Name {
    /// Demande l'ouverture de l'éditeur de pet (émise depuis les réglages).
    static let openPetEditor = Notification.Name("cliPet.openPetEditor")
    /// Demande l'ouverture du skin manager sur l'onglet marketplace.
    static let openMarketplace = Notification.Name("cliPet.openMarketplace")
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

/// Vue d'hébergement de la niche : suit les couleurs du pet et le SpriteStore
/// (pour refléter en direct les retouches faites dans l'éditeur).
struct NicheHostView: View {
    @ObservedObject var settings: PetSettings
    @ObservedObject var store = SpriteStore.shared
    var body: some View {
        NicheView(bodyColor: settings.bodyColor, bellyColor: settings.bellyColor,
                  stripeColor: settings.stripeColor, eyeColor: settings.eyeColor,
                  noseColor: settings.noseColor)
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
    private let nichePanel: FloatingPanel
    private var clipPanel: FloatingPanel?
    private var editorWindow: NSWindow?
    private var skinWindow: NSWindow?
    private var settingsWindow: NSWindow?
    private var clearHistoryWindow: NSWindow?
    private var licenseWindow: NSWindow?
    private var cancellables = Set<AnyCancellable>()
    private var clipResignObserver: NSObjectProtocol?

    /// Le pet est-il masqué (caché par l'utilisateur) ? Reflète l'intention
    /// immédiatement (libellé du menu correct) même pendant l'animation.
    private(set) var isPetHidden = false
    /// Animation d'entrée/sortie de niche en cours (anti double-déclenchement).
    private var isTransitioning = false
    /// Jeton de génération : incrémenté à chaque transition. Un callback dont le
    /// jeton ne correspond plus appartient à une transition périmée et est ignoré.
    /// Évite qu'une animation interrompue laisse la niche affichée ou bloque les
    /// masquages suivants.
    private var transitionGen = 0

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
        nichePanel = FloatingPanel(
            contentRect: NSRect(x: 0, y: 0, width: engine.nicheSize, height: engine.nicheSize),
            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        configure(petPanel)
        configure(toyPanel)
        configure(nichePanel)
        toyPanel.ignoresMouseEvents = true   // décoratif
        nichePanel.ignoresMouseEvents = true // décoratif
        // Juste sous le pet : le chat passe visuellement devant la niche en y entrant.
        nichePanel.level = NSWindow.Level(rawValue: NSWindow.Level.floating.rawValue - 1)

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

        let nicheHost = NSHostingView(rootView: NicheHostView(settings: settings))
        nicheHost.autoresizingMask = [.width, .height]
        nichePanel.contentView = nicheHost

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

        NotificationCenter.default.publisher(for: .openMarketplace)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.openSkinManager(tab: .market) }
            .store(in: &cancellables)
    }

    // MARK: - Historique

    func toggleClipboardPanel() {
        if clipPanel != nil { hideClipboardPanel() } else { showClipboardPanel() }
    }

    private func showClipboardPanel() {
        let panel = FloatingPanel(contentRect: NSRect(x: 0, y: 0, width: 300, height: 160),
            styleMask: [.borderless, .nonactivatingPanel], backing: .buffered, defer: false)
        configure(panel)

        let view = ClipboardHistoryView(
            clipboard: clipboard,
            folders: folderStore,
            l10n: L10n.for_(L10n.Language(rawValue: settings.language) ?? .en),
            onPick: { [weak self] item in self?.clipboard.copyToPasteboard(item); self?.hideClipboardPanel() },
            onClose: { [weak self] in self?.hideClipboardPanel() },
            onClearHistory: { [weak self] in self?.showClearHistoryConfirm() },
            onHidePet: { [weak self] in
                self?.hideClipboardPanel()
                self?.setPetHidden(true)
            })

        // Taille fixe : le panneau ne change jamais de dimensions (la liste défile).
        let host = NSHostingView(rootView: view)
        host.layoutSubtreeIfNeeded()
        let fixedSize = NSSize(width: 300, height: host.fittingSize.height)
        host.frame = NSRect(origin: .zero, size: fixedSize)
        panel.setContentSize(fixedSize)
        panel.contentView = host

        clipPanel = panel
        repositionClipPanel()
        panel.makeKeyAndOrderFront(nil)
        engine.freeze()

        clipResignObserver = NotificationCenter.default.addObserver(
            forName: NSWindow.didResignKeyNotification, object: panel, queue: .main
        ) { [weak self, weak panel] _ in
            // Le focus peut partir vers un popover/enfant du panneau (ex: picker de
            // favoris) : dans ce cas on ne ferme pas, sinon cliquer sur ⭐ fermerait
            // le presse-papiers. On ferme seulement si le focus quitte vraiment l'app.
            DispatchQueue.main.async {
                guard let self, let panel else { return }
                if let key = NSApp.keyWindow {
                    if key === panel || key.parent === panel { return }
                    if String(describing: type(of: key)).contains("Popover") { return }
                }
                self.hideClipboardPanel()
            }
        }
    }

    private func hideClipboardPanel() {
        if let obs = clipResignObserver {
            NotificationCenter.default.removeObserver(obs); clipResignObserver = nil
        }
        clipPanel?.orderOut(nil)
        clipPanel = nil
        engine.unfreeze()
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
        w.setContentSize(NSSize(width: 680, height: 700))
        w.isReleasedWhenClosed = false
        w.center()
        w.makeKeyAndOrderFront(nil)
        editorWindow = w
    }

    func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        if let w = settingsWindow { w.makeKeyAndOrderFront(nil); return }
        let view = SettingsView()
            .environmentObject(settings)
            .environmentObject(clipboard)
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

    /// Masque / affiche le pet. `animated` orchestre l'aller-retour à la niche ;
    /// `animated: false` bascule instantanément (paywall, etc.).
    func setPetHidden(_ hidden: Bool, animated: Bool = true) {
        guard hidden != isPetHidden else { return }
        isPetHidden = hidden
        // Nouvelle transition : invalide proprement toute transition encore en vol
        // (son callback verra un jeton périmé et ne fera rien). Une demande inverse
        // pendant une animation la supersède donc au lieu d'être ignorée.
        transitionGen &+= 1
        let gen = transitionGen

        guard animated else {
            isTransitioning = false
            nichePanel.orderOut(nil)
            engine.isPaused = hidden
            if hidden {
                petPanel.orderOut(nil); toyPanel.orderOut(nil)
            } else {
                engine.resumeNormal()
                petPanel.orderFrontRegardless()
                if engine.toyVisible { toyPanel.orderFront(nil) }
            }
            return
        }

        if hidden { animateHide(gen: gen) } else { animateShow(gen: gen) }
    }

    /// Position au sol de la niche (collée au bord droit de l'écran).
    private func placeNiche() -> CGRect {
        let visible = PetEngine.visibleFrame()
        let w = engine.nicheSize
        let h = w * CGFloat(CatSprites.nicheRows) / CGFloat(CatSprites.nicheCols)
        let x = visible.maxX - w - 12
        let y = visible.minY
        let frame = NSRect(x: x, y: y, width: w, height: h)
        nichePanel.setFrame(frame, display: true)
        return frame
    }

    /// Abscisse cible du pet pour qu'il soit centré devant la porte de la niche.
    private func doorTargetX(_ niche: CGRect) -> CGFloat {
        niche.midX - engine.spriteSize / 2
    }

    private func animateHide(gen: Int) {
        isTransitioning = true
        engine.isPaused = false
        toyPanel.orderOut(nil)
        let niche = placeNiche()
        nichePanel.orderFront(nil)
        petPanel.orderFrontRegardless()
        engine.walk(to: doorTargetX(niche)) { [weak self] in
            guard let self, gen == self.transitionGen else { return }
            self.petPanel.orderOut(nil)
            self.engine.isPaused = true
            // Le pet est « rentré » : on retire la niche après une courte pause.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                guard let self, gen == self.transitionGen else { return }
                self.nichePanel.orderOut(nil)
                self.isTransitioning = false
            }
        }
    }

    private func animateShow(gen: Int) {
        isTransitioning = true
        let visible = PetEngine.visibleFrame()
        let niche = placeNiche()
        nichePanel.orderFront(nil)
        // Le pet réapparaît pile devant la porte, puis sort vers la gauche.
        engine.placeAt(x: doorTargetX(niche))
        petPanel.orderFrontRegardless()
        let dest = CGFloat.random(in: visible.minX ... max(visible.minX, niche.minX - engine.spriteSize))
        // Le chat est sorti : on retire la niche après une courte pause, sans attendre
        // qu'il atteigne sa destination finale.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self, gen == self.transitionGen else { return }
            self.nichePanel.orderOut(nil)
        }
        engine.walk(to: dest) { [weak self] in
            guard let self, gen == self.transitionGen else { return }
            self.nichePanel.orderOut(nil)   // garde-fou si le chat arrive avant la pause
            self.isTransitioning = false
            self.engine.resumeNormal()
            if self.engine.toyVisible { self.toyPanel.orderFront(nil) }
        }
    }

    func showClearHistoryConfirm() {
        NSApp.activate(ignoringOtherApps: true)
        if let w = clearHistoryWindow, w.isVisible { w.makeKeyAndOrderFront(nil); return }

        let l10n = L10n.for_(L10n.Language(rawValue: settings.language) ?? .en)
        let view = ClearHistoryConfirmView(
            title: l10n.clearHistoryTitle,
            message: l10n.clearHistoryMessage,
            onConfirm: { [weak self] in
                self?.clipboard.clear()
                self?.clearHistoryWindow?.close()
            },
            onCancel: { [weak self] in
                self?.clearHistoryWindow?.close()
            }
        )
        let w = NSWindow(contentViewController: NSHostingController(rootView: view))
        w.styleMask = [.titled, .closable]
        w.title = ""
        w.titlebarAppearsTransparent = true
        w.isReleasedWhenClosed = false
        w.setContentSize(NSSize(width: 320, height: 200))
        w.center()
        w.makeKeyAndOrderFront(nil)
        clearHistoryWindow = w
    }

    // MARK: - Licence / paywall

    /// Affiche la fenêtre de licence. `locked = true` (essai terminé) cache le pet
    /// et ne laisse pas fermer la fenêtre sans activer.
    func showLicenseWindow(license: LicenseManager, locked: Bool, onContinue: @escaping () -> Void) {
        NSApp.activate(ignoringOtherApps: true)
        if let w = licenseWindow, w.isVisible { w.makeKeyAndOrderFront(nil); return }

        let l10n = L10n.for_(L10n.Language(rawValue: settings.language) ?? .en)
        let view = LicenseView(license: license, l10n: l10n) { [weak self] in
            self?.licenseWindow?.close()
            self?.licenseWindow = nil
            onContinue()
        }
        let w = NSWindow(contentViewController: NSHostingController(rootView: view))
        w.title = l10n.licenseTitle
        // Essai terminé → fenêtre non fermable (sortie = activer ou quitter).
        w.styleMask = locked ? [.titled] : [.titled, .closable]
        w.titlebarAppearsTransparent = true
        w.isReleasedWhenClosed = false
        w.center()
        w.makeKeyAndOrderFront(nil)
        licenseWindow = w
    }

    func openSkinManager(tab: SkinManagerView.SkinTab = .mine) {
        NSApp.activate(ignoringOtherApps: true)
        if let w = skinWindow {
            // Si déjà ouvert, switche vers l'onglet demandé
            if tab == .market,
               let hc = w.contentViewController as? NSHostingController<SkinManagerView> {
                hc.rootView.initialTab = tab
            }
            w.makeKeyAndOrderFront(nil)
            return
        }
        var view = SkinManagerView()
        view.initialTab = tab
        let w = NSWindow(contentViewController: NSHostingController(rootView: view.environmentObject(settings)))
        w.title = "Gestionnaire de skins — cliPet"
        w.styleMask = [.titled, .closable, .miniaturizable]
        w.isReleasedWhenClosed = false
        w.center()
        w.makeKeyAndOrderFront(nil)
        skinWindow = w
    }

    static func requestOpenMarketplace() {
        NotificationCenter.default.post(name: .openMarketplace, object: nil)
    }
}
