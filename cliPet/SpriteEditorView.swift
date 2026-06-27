import SwiftUI

/// Outil développeur : éditer les frames pixel-art en direct.
/// Les modifications s'appliquent au chat immédiatement (via SpriteStore)
/// et peuvent être sauvegardées dans un fichier rechargé au lancement.
struct SpriteEditorView: View {
    @EnvironmentObject var settings: PetSettings
    @ObservedObject private var store = SpriteStore.shared

    @State private var frameName = "idle"
    @State private var grid: [[Character]] = []
    @State private var brush: Character = "g"

    private let editSize: CGFloat = 392

    private var cols: Int { grid.first?.count ?? CatSprites.size }
    private var rows: Int { grid.count }

    // (char, libellé)
    private let palette: [(Character, String)] = [
        (".", "vide"), ("X", "contour"), ("g", "pelage"), ("d", "rayures"),
        ("w", "blanc"), ("o", "yeux"), ("h", "reflet"), ("p", "rose"),
    ]

    private var paletteView: PixelPalette {
        PixelPalette(body: settings.bodyColor, belly: settings.bellyColor,
                     stripe: settings.stripeColor, eye: settings.eyeColor, nose: settings.noseColor)
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            editor
            sidebar
        }
        .padding(16)
        .frame(minWidth: 540, minHeight: 600)
        .background(PixelTheme.bg)
        .foregroundStyle(PixelTheme.text)
        .font(PixelTheme.font(12, .regular))
        .onAppear(perform: loadGrid)
        .onChange(of: frameName) { _ in loadGrid() }
    }

    // MARK: - Zone d'édition

    private var editor: some View {
        VStack(spacing: 10) {
            Text("FRAME : \(frameName.uppercased())")
                .font(PixelTheme.font(11)).foregroundStyle(PixelTheme.accent).tracking(1)

            Canvas { ctx, size in
                let cell = size.width / CGFloat(cols)
                // damier de transparence
                for r in 0..<rows {
                    for c in 0..<cols {
                        let rect = CGRect(x: CGFloat(c) * cell, y: CGFloat(r) * cell,
                                          width: cell, height: cell)
                        let dark = (r + c) % 2 == 0
                        ctx.fill(Path(rect), with: .color(dark ? PixelTheme.panel : PixelTheme.panelHi))
                        if r < grid.count, c < grid[r].count,
                           let color = paletteView.color(for: grid[r][c]) {
                            ctx.fill(Path(rect), with: .color(color))
                        }
                        ctx.stroke(Path(rect), with: .color(PixelTheme.border.opacity(0.4)), lineWidth: 0.5)
                    }
                }
            }
            .frame(width: editSize, height: editSize)
            .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 2))
            .gesture(DragGesture(minimumDistance: 0).onChanged { v in
                paint(at: v.location)
            })

            // Aperçu live (le vrai chat, recoloré)
            HStack(spacing: 16) {
                preview(.idle, "idle")
                preview(.walk, "marche")
                preview(.play, "joue")
            }
        }
    }

    private func preview(_ state: PetState, _ label: String) -> some View {
        VStack(spacing: 4) {
            TimelineView(.animation) { t in
                let tick = Int(t.date.timeIntervalSinceReferenceDate * 30)
                PixelCatView(state: state, facing: .right, tick: tick,
                             bodyColor: settings.bodyColor, bellyColor: settings.bellyColor,
                             stripeColor: settings.stripeColor, eyeColor: settings.eyeColor,
                             noseColor: settings.noseColor)
                    .frame(width: 56, height: 56)
            }
            Text(label).font(PixelTheme.font(9)).foregroundStyle(PixelTheme.dim)
        }
        .padding(6).pixelPanel()
    }

    // MARK: - Barre latérale

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 12) {
            PixelSectionHeader(title: "Frame")
            Picker("", selection: $frameName) {
                ForEach(CatSprites.order, id: \.self) { Text($0).tag($0) }
            }
            .labelsHidden().pickerStyle(.menu)

            PixelSectionHeader(title: "Pinceau")
            VStack(spacing: 6) {
                ForEach(palette, id: \.0) { ch, name in
                    Button { brush = ch } label: {
                        HStack(spacing: 8) {
                            Rectangle()
                                .fill(paletteView.color(for: ch) ?? Color.clear)
                                .frame(width: 18, height: 18)
                                .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
                                .background(ch == "." ? checker : nil)
                            Text(name).font(PixelTheme.font(11, .regular))
                            Spacer()
                            if brush == ch { Image(systemName: "checkmark").foregroundStyle(PixelTheme.accent) }
                        }
                        .padding(.horizontal, 8).padding(.vertical, 5)
                        .background(brush == ch ? PixelTheme.panelHi : PixelTheme.panel)
                        .overlay(Rectangle().strokeBorder(
                            brush == ch ? PixelTheme.accent : PixelTheme.border, lineWidth: 1))
                    }
                    .buttonStyle(.plain)
                }
            }

            PixelSectionHeader(title: "Actions")
            Button("EFFACER LA FRAME") { clearFrame() }
                .buttonStyle(PixelButtonStyle())
            Button("💾 SAUVEGARDER") { store.save() }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent2.darkened(0.35)))
            Button("RÉINITIALISER TOUT") { store.resetToDefault(); loadGrid() }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent.darkened(0.35)))

            Text("Les modifs s'appliquent au chat en direct.\nSauvegarde :")
                .font(PixelTheme.font(9, .regular)).foregroundStyle(PixelTheme.dim)
            Text(SpriteStore.savePath)
                .font(PixelTheme.font(8, .regular)).foregroundStyle(PixelTheme.dim)
                .lineLimit(3).truncationMode(.middle)

            Spacer()
        }
        .frame(width: 150)
    }

    private var checker: some View {
        Rectangle().fill(PixelTheme.panelHi)
    }

    // MARK: - Logique

    private func loadGrid() {
        grid = store.frame(frameName).map { Array($0) }
    }

    private func paint(at p: CGPoint) {
        guard cols > 0 else { return }
        let cell = editSize / CGFloat(cols)
        let c = Int(p.x / cell), r = Int(p.y / cell)
        guard r >= 0, r < rows, c >= 0, c < grid[r].count else { return }
        guard grid[r][c] != brush else { return }
        grid[r][c] = brush
        commit()
    }

    private func clearFrame() {
        grid = grid.map { row in Array(repeating: Character("."), count: row.count) }
        commit()
    }

    private func commit() {
        store.update(frameName, grid.map { String($0) })
    }
}
