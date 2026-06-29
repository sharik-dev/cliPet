import SwiftUI
import AppKit

private enum DrawTool: Equatable {
    case pencil, bucket, rectangle, triangle, circle
}

/// Éditeur de pet : dessiner ses propres animaux pixel-art en direct.
/// La palette est une liste de couleurs libres (pas de rôles imposés), les
/// modifications s'appliquent immédiatement et sont sauvegardées automatiquement.
struct SpriteEditorView: View {
    @EnvironmentObject var settings: PetSettings
    @ObservedObject private var store = SpriteStore.shared

    @State private var frameName = "idle1"
    @State private var grid: [[Character]] = []
    @State private var brush: Character = "g"
    @State private var editSize: CGFloat = 392

    // Outil actif
    @State private var activeTool: DrawTool = .pencil

    // Historique d'édition (annuler / rétablir)
    @State private var undoStack: [[[Character]]] = []
    @State private var redoStack: [[[Character]]] = []
    @State private var strokeSnapshot: [[Character]]? = nil

    // Début du tracé de forme (rectangle / triangle / cercle)
    @State private var shapeStartRow: Int = 0
    @State private var shapeStartCol: Int = 0
    @State private var hasShapeStart: Bool = false

    // Associer (copier la frame courante vers d'autres frames)
    @State private var showAssociate = false
    @State private var associateTargets: Set<String> = []

    // Copier / coller une frame (presse-papiers de sprite interne à l'éditeur)
    @State private var frameClipboard: [[Character]]? = nil

    private var cols: Int { grid.first?.count ?? 33 }
    private var rows: Int { grid.count }

    /// Caractères affichés dans la palette : couleurs de base + couleurs ajoutées.
    private var paletteChars: [Character] {
        SpriteStore.baseChars + store.addedChars.map { Character($0) }
    }

    private var paletteView: PixelPalette {
        PixelPalette(body: settings.bodyColor, belly: settings.bellyColor,
                     stripe: settings.stripeColor, eye: settings.eyeColor, nose: settings.noseColor,
                     customColors: store.customColors)
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
        let availW = size.width - 172 - 16 - 32 - 76   // sidebar + spacing + padding + flèches
        let availH = size.height - 32 - 40 - 90    // padding + titre + previews
        return max(220, min(availW, availH, 460))
    }

    // MARK: - Zone d'édition

    private var editor: some View {
        VStack(spacing: 10) {
            Text("\(l10n.editorSectionFrame) : \(frameName.uppercased())")
                .font(PixelTheme.font(11)).foregroundStyle(PixelTheme.accent).tracking(1)

            HStack(spacing: 10) {
                frameArrow("chevron.left", help: l10n.editorPrevFrame) { step(-1) }

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
                        .onChanged { v in handleDragChanged(at: v.location) }
                        .onEnded   { v in handleDragEnded(at: v.location) }
                )

                frameArrow("chevron.right", help: l10n.editorNextFrame) { step(1) }
            }

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

    /// Flèche de navigation rapide entre frames (à gauche / droite du canvas).
    private func frameArrow(_ symbol: String, help: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(PixelTheme.accent)
                .frame(width: 28, height: 44)
                .background(PixelTheme.panel)
                .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .help(help)
    }

    /// Passe à la frame suivante / précédente dans l'ordre du catalogue (cyclique).
    private func step(_ delta: Int) {
        let order = CatSprites.order
        guard let i = order.firstIndex(of: frameName) else { return }
        let next = (i + delta + order.count) % order.count
        frameName = order[next]
    }

    // MARK: - Barre latérale

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 12) {
            PixelSectionHeader(title: l10n.editorSectionFrame)
            Picker("", selection: $frameName) {
                ForEach(CatSprites.order, id: \.self) { Text($0).tag($0) }
            }
            .labelsHidden().pickerStyle(.menu)

            PixelSectionHeader(title: l10n.editorSectionTools)
            toolSelector

            PixelSectionHeader(title: l10n.editorSectionColors)
            VStack(spacing: 6) {
                eraserRow
                ForEach(paletteChars, id: \.self) { ch in
                    colorRow(ch)
                }
            }
            Button(l10n.editorAddColor) { brush = store.addColor(.gray) }
                .buttonStyle(PixelButtonStyle())

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
            HStack(spacing: 6) {
                Button(l10n.editorCopyFrame) { copyFrame() }
                    .buttonStyle(PixelButtonStyle())
                Button(l10n.editorPasteFrame) { pasteFrame() }
                    .buttonStyle(PixelButtonStyle())
                    .disabled(frameClipboard == nil)
            }
            Button(l10n.editorClearFrame) { clearFrame() }
                .buttonStyle(PixelButtonStyle())

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

    private func clearFrame() {
        pushUndo()
        grid = grid.map { row in Array(repeating: Character("."), count: row.count) }
        commit()
    }

    /// Copie le dessin de la frame courante dans le presse-papiers interne.
    private func copyFrame() { frameClipboard = grid }

    /// Colle le dessin copié dans la frame courante. Les dimensions peuvent
    /// différer : on recopie uniquement les cellules qui se chevauchent.
    private func pasteFrame() {
        guard let src = frameClipboard else { return }
        pushUndo()
        for r in 0..<min(rows, src.count) {
            for c in 0..<min(grid[r].count, src[r].count) {
                grid[r][c] = src[r][c]
            }
        }
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

    // MARK: - Tool selector UI

    private var toolSelector: some View {
        HStack(spacing: 4) {
            toolBtn(.pencil,    "pencil",           l10n.editorToolPencil)
            toolBtn(.bucket,    "paintbucket",      l10n.editorToolBucket)
            toolBtn(.rectangle, "rectangle.fill",   l10n.editorToolRect)
            toolBtn(.triangle,  "triangle.fill",    l10n.editorToolTriangle)
            toolBtn(.circle,    "circle.fill",      l10n.editorToolCircle)
        }
    }

    @ViewBuilder
    private func toolBtn(_ tool: DrawTool, _ icon: String, _ helpText: String) -> some View {
        let selected = activeTool == tool
        Button { activeTool = tool } label: {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(selected ? PixelTheme.accent : PixelTheme.dim)
                .frame(width: 28, height: 24)
                .background(selected ? PixelTheme.panelHi : PixelTheme.panel)
                .overlay(Rectangle().strokeBorder(
                    selected ? PixelTheme.accent : PixelTheme.border, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .help(helpText)
    }

    // MARK: - Drag dispatch

    private func handleDragChanged(at p: CGPoint) {
        switch activeTool {
        case .pencil:
            if strokeSnapshot == nil { strokeSnapshot = grid }
            paint(at: p)
        case .bucket:
            break
        case .rectangle, .triangle, .circle:
            if strokeSnapshot == nil {
                strokeSnapshot = grid
                let cell = clampedCell(p)
                shapeStartRow = cell.row
                shapeStartCol = cell.col
                hasShapeStart = true
            }
            guard hasShapeStart, let snap = strokeSnapshot,
                  let end = boundedCell(p) else { return }
            grid = snap
            applyShape(r0: min(shapeStartRow, end.row), r1: max(shapeStartRow, end.row),
                       c0: min(shapeStartCol, end.col), c1: max(shapeStartCol, end.col))
            commit()
        }
    }

    private func handleDragEnded(at p: CGPoint) {
        switch activeTool {
        case .pencil:
            if let snap = strokeSnapshot, snap != grid {
                undoStack.append(snap); if undoStack.count > 50 { undoStack.removeFirst() }
                redoStack.removeAll()
            }
            strokeSnapshot = nil
        case .bucket:
            if let cell = boundedCell(p) { floodFill(row: cell.row, col: cell.col) }
        case .rectangle, .triangle, .circle:
            if let snap = strokeSnapshot, snap != grid {
                undoStack.append(snap); if undoStack.count > 50 { undoStack.removeFirst() }
                redoStack.removeAll()
            }
            strokeSnapshot = nil
            hasShapeStart = false
        }
    }

    // MARK: - Cell coordinate helpers

    private func clampedCell(_ p: CGPoint) -> (row: Int, col: Int) {
        guard cols > 0 else { return (0, 0) }
        let cell = editSize / CGFloat(cols)
        return (max(0, min(rows - 1, Int(p.y / cell))),
                max(0, min(cols - 1, Int(p.x / cell))))
    }

    private func boundedCell(_ p: CGPoint) -> (row: Int, col: Int)? {
        guard cols > 0 else { return nil }
        let cell = editSize / CGFloat(cols)
        let c = Int(p.x / cell), r = Int(p.y / cell)
        guard r >= 0, r < rows, c >= 0, c < cols else { return nil }
        return (r, c)
    }

    // MARK: - Shape drawing

    private func applyShape(r0: Int, r1: Int, c0: Int, c1: Int) {
        switch activeTool {
        case .rectangle: fillRect(r0: r0, r1: r1, c0: c0, c1: c1)
        case .triangle:  fillTriangle(r0: r0, r1: r1, c0: c0, c1: c1)
        case .circle:    fillCircle(r0: r0, r1: r1, c0: c0, c1: c1)
        default: break
        }
    }

    private func fillRect(r0: Int, r1: Int, c0: Int, c1: Int) {
        for r in r0...r1 {
            guard r < rows else { break }
            for c in c0...c1 {
                guard c < grid[r].count else { break }
                grid[r][c] = brush
            }
        }
    }

    private func fillTriangle(r0: Int, r1: Int, c0: Int, c1: Int) {
        let cMid = (c0 + c1) / 2
        let totalRows = r1 - r0
        for r in r0...r1 {
            guard r < rows else { break }
            let t = totalRows > 0 ? Double(r - r0) / Double(totalRows) : 1.0
            let leftC  = Int((Double(cMid) + t * Double(c0 - cMid)).rounded())
            let rightC = Int((Double(cMid) + t * Double(c1 - cMid)).rounded())
            for c in min(leftC, rightC)...max(leftC, rightC) {
                guard c >= 0, c < grid[r].count else { continue }
                grid[r][c] = brush
            }
        }
    }

    private func fillCircle(r0: Int, r1: Int, c0: Int, c1: Int) {
        let centerR = Double(r0 + r1) / 2.0
        let centerC = Double(c0 + c1) / 2.0
        let radiusR = max(0.5, Double(r1 - r0) / 2.0)
        let radiusC = max(0.5, Double(c1 - c0) / 2.0)
        for r in r0...r1 {
            guard r < rows else { break }
            for c in c0...c1 {
                guard c < grid[r].count else { break }
                let dr = (Double(r) - centerR) / radiusR
                let dc = (Double(c) - centerC) / radiusC
                if dr * dr + dc * dc <= 1.0 { grid[r][c] = brush }
            }
        }
    }

    // MARK: - Flood fill (paint bucket)

    private func floodFill(row: Int, col: Int) {
        let target = grid[row][col]
        guard target != brush else { return }
        pushUndo()
        var queue: [(Int, Int)] = [(row, col)]
        var head = 0
        while head < queue.count {
            let (r, c) = queue[head]; head += 1
            guard r >= 0, r < rows, c >= 0, c < grid[r].count,
                  grid[r][c] == target else { continue }
            grid[r][c] = brush
            queue.append((r - 1, c)); queue.append((r + 1, c))
            queue.append((r, c - 1)); queue.append((r, c + 1))
        }
        commit()
    }
}
