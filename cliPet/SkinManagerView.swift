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

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("🎨 SKINS").font(PixelTheme.font(15)).tracking(2)
                Spacer()
                Button { skins = SkinCatalog.all() } label: {
                    Image(systemName: "arrow.clockwise")
                }.buttonStyle(.plain).foregroundStyle(PixelTheme.dim)
                    .help("Rescanner")
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(PixelTheme.panel)
            .overlay(Rectangle().fill(PixelTheme.border).frame(height: 2), alignment: .bottom)

            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2),
                          spacing: 12) {
                    ForEach(skins) { skin in
                        Button { store.setActiveSkin(skin.id) } label: {
                            skinCard(skin)
                        }.buttonStyle(.plain)
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
        return VStack(spacing: 6) {
            PixelSpriteView(frame: skin.frames["idle1"] ?? skin.frames["idle"] ?? [],
                            palette: palette)
                .frame(width: 96, height: 96)
            Text(skin.name).font(PixelTheme.font(11)).lineLimit(1)
                .foregroundStyle(active ? PixelTheme.text : PixelTheme.dim)
            Text(skin.builtin ? "intégré" : "perso")
                .font(PixelTheme.font(8, .regular)).foregroundStyle(PixelTheme.dim)
            if active {
                Text("● ACTIF").font(PixelTheme.font(9)).foregroundStyle(PixelTheme.accent2)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(active ? PixelTheme.panelHi : PixelTheme.panel)
        .overlay(Rectangle().strokeBorder(active ? PixelTheme.accent : PixelTheme.border, lineWidth: 2))
    }

    private var footer: some View {
        VStack(spacing: 6) {
            Button("📁 OUVRIR LE DOSSIER DES SKINS") { openSkinsFolder() }
                .buttonStyle(PixelButtonStyle())
            Text("Dépose un .json ici puis « Rescanner » pour ajouter un skin.")
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
}
