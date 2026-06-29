import SwiftUI
import AppKit

/// Gestionnaire de skins : choisir le skin actif du chat (extensible).
/// Les skins intégrés sont fournis avec l'app ; on peut en ajouter en déposant
/// des fichiers JSON dans Application Support/cliPet/skins/.
struct SkinManagerView: View {
    @EnvironmentObject var settings: PetSettings
    @ObservedObject private var store = SpriteStore.shared

    @State private var skins: [Skin] = SkinCatalog.all()
    @State private var tab: SkinTab = .mine
    var initialTab: SkinTab = .mine

    enum SkinTab { case mine, market }

    /// Palette d'aperçu propre à un skin (avec SA palette, pas celle du skin actif).
    private func cardPalette(for skin: Skin) -> PixelPalette {
        PixelPalette(body: settings.bodyColor, belly: settings.bellyColor,
                     stripe: settings.stripeColor, eye: settings.eyeColor, nose: settings.noseColor,
                     customColors: store.previewColors(for: skin.id))
    }

    private var l10n: L10n { L10n.for_(L10n.Language(rawValue: settings.language) ?? .en) }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(l10n.skinManagerTitle).font(PixelTheme.font(15)).tracking(2)
                Spacer()
                Button { skins = SkinCatalog.all() } label: {
                    Image(systemName: "arrow.clockwise")
                }.buttonStyle(.plain).foregroundStyle(PixelTheme.dim)
                    .help(l10n.skinRescan)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(PixelTheme.panel)
            .overlay(Rectangle().fill(PixelTheme.border).frame(height: 2), alignment: .bottom)

            tabBar

            if tab == .mine {
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2),
                              spacing: 12) {
                        ForEach(skins) { skin in
                            skinCard(skin)
                                .contextMenu {
                                    Button(l10n.skinRename) { showRenameAlert(for: skin) }
                                    Button(l10n.skinExport) { exportPet(skin) }
                                }
                        }
                    }
                    .padding(16)
                }
                footer
            } else {
                MarketplaceView(l10n: l10n) { skins = SkinCatalog.all(); tab = .mine }
                    .environmentObject(settings)
            }
        }
        .frame(width: 440, height: 540)
        .background(PixelTheme.bg)
        .foregroundStyle(PixelTheme.text)
        .onAppear { skins = SkinCatalog.all(); tab = initialTab }
        .onReceive(NotificationCenter.default.publisher(for: .skinsChanged)) { _ in
            skins = SkinCatalog.all()
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(l10n.skinTabMine, .mine)
            tabButton(l10n.skinTabMarket, .market)
        }
        .overlay(Rectangle().fill(PixelTheme.border).frame(height: 2), alignment: .bottom)
    }

    private func tabButton(_ label: String, _ value: SkinTab) -> some View {
        Button { tab = value } label: {
            Text(label).font(PixelTheme.font(11)).tracking(1)
                .frame(maxWidth: .infinity).padding(.vertical, 9)
                .foregroundStyle(tab == value ? PixelTheme.accent : PixelTheme.dim)
                .background(tab == value ? PixelTheme.panelHi : PixelTheme.panel)
        }
        .buttonStyle(.plain)
    }

    /// Skin actuellement sélectionné (cible des actions Éditer / Supprimer).
    private var activeSkin: Skin { SkinCatalog.skin(store.activeSkinId) }

    private func skinCard(_ skin: Skin) -> some View {
        let active = store.activeSkinId == skin.id
        return VStack(spacing: 6) {
            PixelSpriteView(frame: skin.frames["idle1"] ?? skin.frames["idle"] ?? [],
                            palette: cardPalette(for: skin))
                .frame(width: 64, height: 64)

            Text(skin.name).font(PixelTheme.font(11)).lineLimit(1)
                .foregroundStyle(active ? PixelTheme.text : PixelTheme.dim)
            Text(skin.builtin ? l10n.skinBuiltin : l10n.skinCustom)
                .font(PixelTheme.font(8, .regular)).foregroundStyle(PixelTheme.dim)
            if active {
                Text(l10n.skinActive).font(PixelTheme.font(9)).foregroundStyle(PixelTheme.accent2)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(active ? PixelTheme.panelHi : PixelTheme.panel)
        .overlay(Rectangle().strokeBorder(active ? PixelTheme.accent : PixelTheme.border, lineWidth: 2))
        .contentShape(Rectangle())
        .onTapGesture { store.setActiveSkin(skin.id) }
    }

    private func deleteSkin(_ skin: Skin) {
        let alert = NSAlert()
        alert.messageText = l10n.skinDelete
        alert.informativeText = l10n.skinDeleteConfirm(skin.name)
        alert.alertStyle = .warning
        alert.addButton(withTitle: l10n.skinDelete)
        alert.addButton(withTitle: l10n.cancel)
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        if store.activeSkinId == skin.id {
            store.setActiveSkin(SkinCatalog.builtins[0].id)
        }
        SkinCatalog.deleteSkin(skin.id)
        skins = SkinCatalog.all()
    }

    private var footer: some View {
        VStack(spacing: 6) {
            // Éditer / Supprimer le skin sélectionné
            HStack(spacing: 8) {
                Button { showRenameAlert(for: activeSkin) } label: {
                    PixelButtonLabel(glyph: PixelGlyph.pencil, title: l10n.skinEdit)
                }
                .buttonStyle(PixelButtonStyle())
                Button { deleteSkin(activeSkin) } label: {
                    PixelButtonLabel(glyph: PixelGlyph.trash, title: l10n.skinDelete)
                }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent.darkened(0.35)))
                .disabled(activeSkin.builtin)
            }
            HStack(spacing: 8) {
                Button { importPet() } label: {
                    PixelButtonLabel(glyph: PixelGlyph.plus, title: l10n.skinAddPet)
                }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent2.darkened(0.35)))
                Button { openSkinsFolder() } label: {
                    PixelButtonLabel(glyph: PixelGlyph.folder, title: l10n.skinOpenFolder)
                }
                .buttonStyle(PixelButtonStyle())
            }
            Text(l10n.skinDropHint)
                .font(PixelTheme.font(8, .regular)).foregroundStyle(PixelTheme.dim)
                .multilineTextAlignment(.center)
        }
        .padding(12)
        .overlay(Rectangle().fill(PixelTheme.border).frame(height: 2), alignment: .top)
    }

    // MARK: - Import / Export (.clipet)

    private func importPet() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.prompt = l10n.skinAddPet.replacingOccurrences(of: "…", with: "")
        panel.begin { resp in
            guard resp == .OK, let url = panel.url else { return }
            do {
                let pkg = try PetPackage.load(from: url)
                pkg.install()
                skins = SkinCatalog.all()
                notify(l10n.skinImported)
            } catch {
                notify((error as? LocalizedError)?.errorDescription ?? l10n.skinImportError, isError: true)
            }
        }
    }

    private func exportPet(_ skin: Skin) {
        let pkg = PetPackage.forSkin(skin, settings: settings)
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(skin.name).\(PetPackage.fileExtension)"
        panel.begin { resp in
            guard resp == .OK, let url = panel.url else { return }
            try? pkg.encoded().write(to: url)
        }
    }

    private func notify(_ text: String, isError: Bool = false) {
        let alert = NSAlert()
        alert.messageText = text
        alert.alertStyle = isError ? .warning : .informational
        alert.runModal()
    }

    private func openSkinsFolder() {
        guard let dir = SkinCatalog.skinsDirectory else { return }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        NSWorkspace.shared.open(dir)
    }

    private func showRenameAlert(for skin: Skin) {
        let alert = NSAlert()
        alert.messageText = l10n.skinRename.replacingOccurrences(of: "…", with: "")
        alert.addButton(withTitle: l10n.skinRename.replacingOccurrences(of: "…", with: ""))
        alert.addButton(withTitle: l10n.cancel)

        let tf = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
        tf.stringValue = skin.name
        tf.placeholderString = skin.name
        alert.accessoryView = tf
        alert.window.initialFirstResponder = tf

        if alert.runModal() == .alertFirstButtonReturn {
            let newName = tf.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !newName.isEmpty else { return }
            SkinCatalog.renameSkin(skin.id, to: newName)
            skins = SkinCatalog.all()
        }
    }
}
