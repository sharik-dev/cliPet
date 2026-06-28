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

    private var l10n: L10n { L10n.for_(L10n.Language(rawValue: settings.language) ?? .en) }

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
            Text("\(l10n.editorSectionFrame) : \(frameName.uppercased())")
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
                preview(.idle, l10n.editorPreviewIdle)
                preview(.walk, l10n.editorPreviewWalk)
                preview(.sit, l10n.editorPreviewSit)
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
            PixelSectionHeader(title: l10n.editorSectionFrame)
            Picker("", selection: $frameName) {
                ForEach(CatSprites.order, id: \.self) { Text($0).tag($0) }
            }
            .labelsHidden().pickerStyle(.menu)

            PixelSectionHeader(title: l10n.editorSectionColors)
            VStack(spacing: 6) {
                eraserRow
                ForEach(paletteChars, id: \.self) { ch in
                    colorRow(ch)
                }
            }
            Button(l10n.editorAddColor) { brush = store.addColor(.gray) }
                .buttonStyle(PixelButtonStyle())

            PixelSectionHeader(title: l10n.editorSectionImport)
            Button(l10n.editorImportImage) { importImage() }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent2.darkened(0.35)))
            VStack(alignment: .leading, spacing: 2) {
                Text(l10n.editorBgTolerance(Int(bgTolerance)))
                    .font(PixelTheme.font(9, .regular)).foregroundStyle(PixelTheme.dim)
                Slider(value: $bgTolerance, in: 0...150)
            }
            Text(l10n.editorBgToleranceHelp)
                .font(PixelTheme.font(8, .regular)).foregroundStyle(PixelTheme.dim)

            PixelSectionHeader(title: l10n.editorSectionActions)
            HStack(spacing: 6) {
                Button(l10n.editorUndo) { undo() }
                    .buttonStyle(PixelButtonStyle())
                    .disabled(undoStack.isEmpty)
                    .keyboardShortcut("z", modifiers: .command)
                Button(l10n.editorRedo) { redo() }
                    .buttonStyle(PixelButtonStyle())
                    .disabled(redoStack.isEmpty)
                    .keyboardShortcut("z", modifiers: [.command, .shift])
            }
            Button(l10n.editorAssociate) { associateTargets = []; showAssociate = true }
                .buttonStyle(PixelButtonStyle())
                .popover(isPresented: $showAssociate, arrowEdge: .leading) { associatePopover }
            Button(l10n.editorClearFrame) { clearFrame() }
                .buttonStyle(PixelButtonStyle())
            Button(l10n.editorResetAll) { store.resetToDefault(); loadGrid() }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent.darkened(0.35)))

            Text(l10n.editorAutoSave)
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
                Text(l10n.editorEraser).font(PixelTheme.font(11, .regular))
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

    /// Une couleur : pastille sélectionnable + sélecteur de couleur + nom (variable) + suppression.
    private func colorRow(_ ch: Character) -> some View {
        let selected = brush == ch
        let isCustom = !SpriteStore.baseChars.contains(ch)
        // Pastille (aperçu + sélection) | nom (variable) | sélecteur de couleur | suppression.
        return HStack(spacing: 6) {
            Button { brush = ch } label: {
                ZStack {
                    Rectangle()
                        .fill(paletteView.color(for: ch) ?? .clear)
                        .frame(width: 22, height: 22)
                        .overlay(Rectangle().strokeBorder(
                            selected ? PixelTheme.accent : PixelTheme.border,
                            lineWidth: selected ? 2 : 1))
                    if selected {
                        Image(systemName: "checkmark").font(.system(size: 9))
                            .foregroundStyle(PixelTheme.accent)
                    }
                }
            }
            .buttonStyle(.plain)

            ColorNameField(ch: ch,
                           placeholder: l10n.defaultColorName(for: ch) ?? l10n.colorNamePlaceholder)

            ColorPicker("", selection: colorBinding(for: ch), supportsOpacity: false)
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

    /// Binding couleur d'un caractère : les rôles de base éditent le coat courant
    /// (`settings`) et nettoient tout override parasite ; les couleurs ajoutées
    /// restent des overrides par skin.
    private func colorBinding(for ch: Character) -> Binding<Color> {
        switch ch {
        case "g": return Binding(get: { settings.bodyColor },   set: { settings.bodyColor = $0;   store.clearColor(ch) })
        case "w": return Binding(get: { settings.bellyColor },  set: { settings.bellyColor = $0;  store.clearColor(ch) })
        case "d": return Binding(get: { settings.stripeColor }, set: { settings.stripeColor = $0; store.clearColor(ch) })
        case "o": return Binding(get: { settings.eyeColor },    set: { settings.eyeColor = $0;    store.clearColor(ch) })
        case "p": return Binding(get: { settings.noseColor },   set: { settings.noseColor = $0;   store.clearColor(ch) })
        default:  return Binding(get: { paletteView.color(for: ch) ?? .gray }, set: { store.setColor(ch, $0) })
        }
    }

    private func removeColorChar(_ ch: Character) {
        store.removeColor(ch)
        if brush == ch { brush = "g" }
    }

    /// Champ de nom d'une couleur (état local pour garder le focus pendant la frappe).
    private struct ColorNameField: View {
        let ch: Character
        let placeholder: String
        @ObservedObject private var store = SpriteStore.shared
        @State private var name = ""

        var body: some View {
            TextField(placeholder, text: $name)
                .textFieldStyle(.plain)
                .font(PixelTheme.font(9, .regular))
                .foregroundStyle(PixelTheme.text)
                .padding(.horizontal, 6).padding(.vertical, 3)
                .background(PixelTheme.panel)
                .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
                .onAppear { name = store.colorName(for: ch) ?? "" }
                .onChange(of: name) { store.setColorName(ch, $0) }
        }
    }

    // MARK: - Associer (copier vers d'autres frames)

    /// Frames de même largeur que la frame courante (cibles compatibles).
    private var associateCandidates: [String] {
        CatSprites.order.filter { $0 != frameName && (store.frame($0).first?.count ?? 0) == cols }
    }

    private var associatePopover: some View {
        let targets = associateCandidates
        return VStack(alignment: .leading, spacing: 8) {
            Text(l10n.editorCopyTo(frameName))
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
                Button(l10n.editorSelectAll) { associateTargets = Set(targets) }
                    .buttonStyle(PixelButtonStyle())
                Button(l10n.editorSelectNone) { associateTargets = [] }
                    .buttonStyle(PixelButtonStyle())
            }
            Button(l10n.editorApply(associateTargets.count)) { associateFrames() }
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
