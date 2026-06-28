import SwiftUI
import AppKit

/// Gestionnaire de skins : choisir le skin actif du chat (extensible).
/// Les skins intégrés sont fournis avec l'app ; on peut en ajouter en déposant
/// des fichiers JSON dans Application Support/cliPet/skins/.
struct SkinManagerView: View {
    @EnvironmentObject var settings: PetSettings
    @ObservedObject private var store = SpriteStore.shared

    @State private var skins: [Skin] = SkinCatalog.all()

    private var palette: PixelPalette {
        PixelPalette(body: settings.bodyColor, belly: settings.bellyColor,
                     stripe: settings.stripeColor, eye: settings.eyeColor, nose: settings.noseColor)
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

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2),
                          spacing: 12) {
                    ForEach(skins) { skin in
                        skinCard(skin)
                            .contextMenu {
                                Button(l10n.skinRename) { showRenameAlert(for: skin) }
                            }
                    }
                }
                .padding(16)
            }

            footer
        }
        .frame(width: 440, height: 540)
        .background(PixelTheme.bg)
        .foregroundStyle(PixelTheme.text)
        .onAppear { skins = SkinCatalog.all() }
    }

    private func skinCard(_ skin: Skin) -> some View {
        let active = store.activeSkinId == skin.id
        return ZStack(alignment: .topTrailing) {
            VStack(spacing: 6) {
                SkinIconView(palette: palette)
                    .frame(width: 52, height: 52)

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

            // Bouton renommer — toujours visible, coin haut droit
            Button { showRenameAlert(for: skin) } label: {
                Image(systemName: "pencil")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(PixelTheme.dim)
                    .padding(6)
            }
            .buttonStyle(.plain)
            .help(l10n.skinRename)
        }
    }

    private var footer: some View {
        VStack(spacing: 6) {
            Button(l10n.skinOpenFolder) { openSkinsFolder() }
                .buttonStyle(PixelButtonStyle())
            Text(l10n.skinDropHint)
                .font(PixelTheme.font(8, .regular)).foregroundStyle(PixelTheme.dim)
                .multilineTextAlignment(.center)
        }
        .padding(12)
        .overlay(Rectangle().fill(PixelTheme.border).frame(height: 2), alignment: .top)
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

// MARK: - Icône pixel art de skin (face de chat 9×9)

private struct SkinIconView: View {
    let palette: PixelPalette

    // 9 colonnes × 9 lignes : g=body, X=outline, o=eye, w=belly, p=nose, d=stripe, .=transparent
    private static let pixels: [[Character]] = [
        [".", "g", "X", ".", ".", ".", "X", "g", "."],
        [".", "g", "g", "g", "g", "g", "g", "g", "."],
        ["X", "g", "g", "g", "g", "g", "g", "g", "X"],
        ["X", "g", "o", "g", "g", "g", "o", "g", "X"],
        ["X", "g", "g", "g", "g", "g", "g", "g", "X"],
        ["X", "w", "w", "d", "p", "d", "w", "w", "X"],
        ["X", "g", "g", "g", "g", "g", "g", "g", "X"],
        [".", "X", "g", "g", "g", "g", "g", "X", "."],
        [".", ".", "X", "X", "X", "X", "X", ".", "."],
    ]

    var body: some View {
        Canvas { ctx, size in
            let cols = CGFloat(9)
            let rows = CGFloat(9)
            let pw = size.width / cols
            let ph = size.height / rows
            for (ry, row) in Self.pixels.enumerated() {
                for (rx, ch) in row.enumerated() {
                    guard ch != "." else { continue }
                    guard let color = palette.color(for: ch) else { continue }
                    let rect = CGRect(x: CGFloat(rx) * pw, y: CGFloat(ry) * ph, width: pw, height: ph)
                    ctx.fill(Path(rect), with: .color(color))
                }
            }
        }
    }
}
