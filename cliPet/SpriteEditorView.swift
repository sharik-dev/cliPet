import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// Éditeur de pet : dessiner ses propres animaux pixel-art en direct.
/// La palette est une liste de couleurs libres (pas de rôles imposés), les
/// modifications s'appliquent immédiatement et sont sauvegardées automatiquement.
struct SpriteEditorView: View {
    @EnvironmentObject var settings: PetSettings
    @ObservedObject private var store = SpriteStore.shared

    @State private var frameName = "idle1"
    @State private var grid: [[Character]] = []
    @State private var brush: Character = "g"
    @State private var bgTolerance: Double = 60
    @State private var editSize: CGFloat = 392

    // Historique d'édition (annuler / rétablir)
    @State private var undoStack: [[[Character]]] = []
    @State private var redoStack: [[[Character]]] = []
    @State private var strokeSnapshot: [[Character]]? = nil

    // Associer (copier la frame courante vers d'autres frames)
    @State private var showAssociate = false
    @State private var associateTargets: Set<String> = []

    private var cols: Int { grid.first?.count ?? 33 }
    private var rows: Int { grid.count }

    /// Caractères affichés dans la palette : couleurs de base + couleurs ajoutées.
    private var paletteChars: [Character] {
        SpriteStore.baseChars + store.addedChars.map { Character($0) }
    }

    private var paletteView: PixelPalette {
        PixelPalette(body: settings.bodyColor, belly: settings.bellyColor,
                     stripe: settings.stripeColor, eye: settings.eyeColor, nose: settings.noseColor)
    }

    var body: some View {
        GeometryReader { geo in
            let side = idealSide(for: geo.size)
            ScrollView([.vertical, .horizontal]) {
                HStack(alignment: .top, spacing: 16) {
                    editor
                    sidebar
                }
                .padding(16)
                .frame(minWidth: geo.size.width, minHeight: geo.size.height, alignment: .topLeading)
            }
            .onAppear { editSize = side }
            .onChange(of: side) { editSize = $0 }
        }
        .frame(minWidth: 360, minHeight: 360)
        .background(PixelTheme.bg)
        .foregroundStyle(PixelTheme.text)
        .font(PixelTheme.font(12, .regular))
        .onAppear(perform: loadGrid)
        .onChange(of: frameName) { _ in loadGrid() }
    }

    /// Taille du canvas adaptée à l'espace dispo (carré), avec bornes.
    private func idealSide(for size: CGSize) -> CGFloat {
        let availW = size.width - 172 - 16 - 32   // sidebar + spacing + padding
        let availH = size.height - 32 - 40 - 90    // padding + titre + previews
        return max(220, min(availW, availH, 460))
    }

    // MARK: - Zone d'édition

    private var editor: some View {
        VStack(spacing: 10) {
            Text("FRAME : \(frameName.uppercased())")
                .font(PixelTheme.font(11)).foregroundStyle(PixelTheme.accent).tracking(1)

            Canvas { ctx, size in
                let cell = size.width / CGFloat(cols)
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
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { v in
                        if strokeSnapshot == nil { strokeSnapshot = grid }  // début de trait
                        paint(at: v.location)
                    }
                    .onEnded { _ in
                        if let snap = strokeSnapshot, snap != grid {
                            undoStack.append(snap)
                            if undoStack.count > 50 { undoStack.removeFirst() }
                            redoStack.removeAll()
                        }
                        strokeSnapshot = nil
                    }
            )

            HStack(spacing: 16) {
                preview(.idle, "idle")
                preview(.walk, "marche")
                preview(.sit, "assis")
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

            PixelSectionHeader(title: "Couleurs")
            VStack(spacing: 6) {
                eraserRow
                ForEach(paletteChars, id: \.self) { ch in
                    colorRow(ch)
                }
            }
            Button("+ AJOUTER UNE COULEUR") { brush = store.addColor(.gray) }
                .buttonStyle(PixelButtonStyle())

            PixelSectionHeader(title: "Image → sprite")
            Button("🖼 IMPORTER UNE IMAGE") { importImage() }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent2.darkened(0.35)))
            VStack(alignment: .leading, spacing: 2) {
                Text("Tolérance fond : \(Int(bgTolerance))")
                    .font(PixelTheme.font(9, .regular)).foregroundStyle(PixelTheme.dim)
                Slider(value: $bgTolerance, in: 0...150)
            }
            Text("Détecte le fond (zones quasi-uniformes connectées aux bords) et le rend vide. ↑ tolérance = plus de fond effacé.")
                .font(PixelTheme.font(8, .regular)).foregroundStyle(PixelTheme.dim)

            PixelSectionHeader(title: "Actions")
            HStack(spacing: 6) {
                Button("↶ ANNULER") { undo() }
                    .buttonStyle(PixelButtonStyle())
                    .disabled(undoStack.isEmpty)
                    .keyboardShortcut("z", modifiers: .command)
                Button("↷ RÉTABLIR") { redo() }
                    .buttonStyle(PixelButtonStyle())
                    .disabled(redoStack.isEmpty)
                    .keyboardShortcut("z", modifiers: [.command, .shift])
            }
            Button("🔗 ASSOCIER…") { associateTargets = []; showAssociate = true }
                .buttonStyle(PixelButtonStyle())
                .popover(isPresented: $showAssociate, arrowEdge: .leading) { associatePopover }
            Button("EFFACER LA FRAME") { clearFrame() }
                .buttonStyle(PixelButtonStyle())
            Button("RÉINITIALISER TOUT") { store.resetToDefault(); loadGrid() }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent.darkened(0.35)))

            Text("💾 Sauvegarde automatique")
                .font(PixelTheme.font(9, .regular)).foregroundStyle(PixelTheme.accent2)
            Text(store.savePath)
                .font(PixelTheme.font(8, .regular)).foregroundStyle(PixelTheme.dim)
                .lineLimit(3).truncationMode(.middle)

            Spacer()
        }
        .frame(width: 172)
    }

    // MARK: - Palette : lignes de couleur

    /// Gomme (caractère vide).
    private var eraserRow: some View {
        Button { brush = "." } label: {
            HStack(spacing: 8) {
                ZStack {
                    Rectangle().fill(PixelTheme.panel)
                    Image(systemName: "eraser").font(.system(size: 10)).foregroundStyle(PixelTheme.dim)
                }
                .frame(width: 18, height: 18)
                .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
                Text("gomme").font(PixelTheme.font(11, .regular))
                Spacer()
                if brush == "." { Image(systemName: "checkmark").foregroundStyle(PixelTheme.accent) }
            }
            .padding(.horizontal, 8).padding(.vertical, 5)
            .background(brush == "." ? PixelTheme.panelHi : PixelTheme.panel)
            .overlay(Rectangle().strokeBorder(
                brush == "." ? PixelTheme.accent : PixelTheme.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    /// Une couleur : pastille sélectionnable + sélecteur de couleur + suppression.
    private func colorRow(_ ch: Character) -> some View {
        let selected = brush == ch
        let isCustom = !SpriteStore.baseChars.contains(ch)
        return HStack(spacing: 6) {
            Button { brush = ch } label: {
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(paletteView.color(for: ch) ?? .clear)
                        .frame(width: 18, height: 18)
                        .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
                    if selected {
                        Image(systemName: "checkmark").font(.system(size: 9))
                            .foregroundStyle(PixelTheme.accent)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 6).padding(.vertical, 5)
                .background(selected ? PixelTheme.panelHi : PixelTheme.panel)
                .overlay(Rectangle().strokeBorder(
                    selected ? PixelTheme.accent : PixelTheme.border, lineWidth: 1))
            }
            .buttonStyle(.plain)

            ColorPicker("", selection: Binding(
                get: { paletteView.color(for: ch) ?? .gray },
                set: { store.setColor(ch, $0) }
            ), supportsOpacity: false)
                .labelsHidden()
                .frame(width: 32)

            if isCustom {
                Button { removeColorChar(ch) } label: {
                    Image(systemName: "trash").font(.system(size: 9)).foregroundStyle(PixelTheme.dim)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func removeColorChar(_ ch: Character) {
        store.removeColor(ch)
        if brush == ch { brush = "g" }
    }

    // MARK: - Associer (copier vers d'autres frames)

    /// Frames de même largeur que la frame courante (cibles compatibles).
    private var associateCandidates: [String] {
        CatSprites.order.filter { $0 != frameName && (store.frame($0).first?.count ?? 0) == cols }
    }

    private var associatePopover: some View {
        let targets = associateCandidates
        return VStack(alignment: .leading, spacing: 8) {
            Text("Copier « \(frameName) » vers :")
                .font(PixelTheme.font(10)).foregroundStyle(PixelTheme.accent)
            ScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(targets, id: \.self) { name in
                        Toggle(isOn: Binding(
                            get: { associateTargets.contains(name) },
                            set: { on in
                                if on { associateTargets.insert(name) } else { associateTargets.remove(name) }
                            }
                        )) { Text(name).font(PixelTheme.font(11, .regular)) }
                            .toggleStyle(.checkbox)
                    }
                }
            }
            .frame(maxHeight: 220)
            HStack(spacing: 6) {
                Button("Tout") { associateTargets = Set(targets) }
                    .buttonStyle(PixelButtonStyle())
                Button("Aucun") { associateTargets = [] }
                    .buttonStyle(PixelButtonStyle())
            }
            Button("ASSOCIER (\(associateTargets.count))") { associateFrames() }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent2.darkened(0.35)))
                .disabled(associateTargets.isEmpty)
        }
        .padding(12)
        .frame(width: 200)
        .background(PixelTheme.bg)
        .foregroundStyle(PixelTheme.text)
    }

    /// Recopie le dessin courant dans toutes les frames sélectionnées.
    private func associateFrames() {
        let rows = grid.map { String($0) }
        for name in associateTargets { store.update(name, rows) }
        showAssociate = false
    }

    // MARK: - Logique

    private func loadGrid() {
        grid = store.frame(frameName).map { Array($0) }
        undoStack.removeAll()
        redoStack.removeAll()
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

    /// Ouvre une image et la convertit en sprite (fond auto-détecté → vide).
    private func importImage() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.png, .jpeg, .tiff, .gif, .bmp, .heic]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        guard panel.runModal() == .OK, let url = panel.url,
              let image = NSImage(contentsOf: url) else { return }

        let targetCols = cols, targetRows = rows
        guard targetCols > 0, targetRows > 0,
              let converted = ImageToSprite.convert(
                image, cols: targetCols, rows: targetRows,
                palette: paletteView, tolerance: bgTolerance) else {
            NSSound.beep()
            return
        }
        pushUndo()
        grid = converted
        commit()
    }

    private func clearFrame() {
        pushUndo()
        grid = grid.map { row in Array(repeating: Character("."), count: row.count) }
        commit()
    }

    private func commit() {
        store.update(frameName, grid.map { String($0) })
    }

    // MARK: - Undo / Redo

    /// Sauvegarde l'état courant avant une modification globale (import, effacer…).
    private func pushUndo() {
        undoStack.append(grid)
        if undoStack.count > 50 { undoStack.removeFirst() }
        redoStack.removeAll()
    }

    private func undo() {
        guard let prev = undoStack.popLast() else { return }
        redoStack.append(grid)
        grid = prev
        commit()
    }

    private func redo() {
        guard let next = redoStack.popLast() else { return }
        undoStack.append(grid)
        grid = next
        commit()
    }
}
