import SwiftUI

/// Panneau d'historique du presse-papiers (pixel-art) + dossiers de favoris.
struct ClipboardHistoryView: View {
    @ObservedObject var clipboard: ClipboardManager
    @ObservedObject var folders: ClipFolderStore
    let l10n: L10n
    let onPick: (ClipItem) -> Void
    let onClose: () -> Void
    var onClearHistory: (() -> Void)? = nil

    @State private var search = ""
    @State private var selectedFolder: ClipFolder?   // nil = vue historique
    @State private var showManageFolders = false
    @State private var newFolderName = ""

    // MARK: - Données affichées

    private var historyItems: [ClipItem] {
        guard !search.isEmpty else { return clipboard.history }
        return clipboard.history.filter { matches($0.text, $0.preview) }
    }

    private func savedItems(in folder: ClipFolder) -> [SavedClip] {
        let all = folders.saved(in: folder.id)
        guard !search.isEmpty else { return all }
        return all.filter { matches($0.text, $0.text) }
    }

    private func matches(_ a: String, _ b: String) -> Bool {
        a.localizedCaseInsensitiveContains(search) || b.localizedCaseInsensitiveContains(search)
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            divider
            folderBar
            divider
            searchField
            divider
            content
        }
        .frame(width: 300)
        .pixelPanel(PixelTheme.bg)
    }

    private var divider: some View { Rectangle().fill(PixelTheme.border).frame(height: 2) }

    // MARK: - En-tête

    private var header: some View {
        HStack(spacing: 6) {
            Image(systemName: "doc.on.clipboard.fill")
                .foregroundStyle(PixelTheme.accent)
            Text(l10n.clipTitle)
                .font(PixelTheme.font(11))
                .foregroundStyle(PixelTheme.text)
                .tracking(1)
            Spacer()
            if selectedFolder == nil, let onClear = onClearHistory {
                Button(action: onClear) { Image(systemName: "trash.fill") }
                    .buttonStyle(.plain).foregroundStyle(PixelTheme.dim)
                    .help(l10n.clipClearHelp)
            }
            Button(action: onClose) { Image(systemName: "xmark") }
                .buttonStyle(.plain).foregroundStyle(PixelTheme.dim)
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .background(PixelTheme.panelHi)
    }

    // MARK: - Barre de dossiers

    private var folderBar: some View {
        HStack(spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    folderChip(nil)
                    ForEach(folders.folders) { folderChip($0) }
                }
                .padding(.horizontal, 2).padding(.vertical, 2)
            }
            Button { showManageFolders = true } label: {
                Image(systemName: "folder.badge.plus").font(.system(size: 14))
            }
            .buttonStyle(.plain).foregroundStyle(PixelTheme.accent2)
            .popover(isPresented: $showManageFolders, arrowEdge: .bottom) { manageFolders }
        }
        .padding(.horizontal, 10).padding(.vertical, 6)
    }

    @ViewBuilder
    private func folderChip(_ folder: ClipFolder?) -> some View {
        let selected = selectedFolder?.id == folder?.id
        Button { selectedFolder = folder } label: {
            VStack(spacing: 1) {
                Group {
                    if let folder {
                        PixelFolderView(color: folder.color).frame(width: 30, height: 24)
                    } else {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 14))
                            .foregroundStyle(PixelTheme.text)
                            .frame(width: 30, height: 24)
                    }
                }
                Text(folder?.name ?? l10n.historyTab)
                    .font(PixelTheme.font(7, .regular))
                    .foregroundStyle(selected ? PixelTheme.text : PixelTheme.dim)
                    .lineLimit(1)
                    .frame(width: 40)
            }
            .padding(3)
            .background(selected ? PixelTheme.panelHi : Color.clear)
            .overlay(Rectangle().strokeBorder(selected ? PixelTheme.accent : .clear, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private var manageFolders: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text(l10n.foldersTitle)
                    .font(PixelTheme.font(11))
                    .foregroundStyle(PixelTheme.accent)
                Spacer()
                Text("\(folders.folders.count)")
                    .font(PixelTheme.font(9, .regular))
                    .foregroundStyle(PixelTheme.dim)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(PixelTheme.bg)
                    .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
            }
            .padding(.horizontal, 12).padding(.top, 12).padding(.bottom, 8)

            // Add folder row
            HStack(spacing: 6) {
                TextField(l10n.newFolderPlaceholder, text: $newFolderName)
                    .textFieldStyle(.plain).font(PixelTheme.font(10, .regular))
                    .foregroundStyle(PixelTheme.text)
                    .padding(.horizontal, 8).padding(.vertical, 5)
                    .background(PixelTheme.bg)
                    .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
                    .onSubmit(createFolder)
                Button(action: createFolder) {
                    Image(systemName: "plus")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                         ? PixelTheme.dim : PixelTheme.accent)
                        .frame(width: 26, height: 26)
                        .background(PixelTheme.bg)
                        .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
                }
                .buttonStyle(.plain)
                .disabled(newFolderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding(.horizontal, 12).padding(.bottom, 8)

            if !folders.folders.isEmpty {
                Rectangle().fill(PixelTheme.border).frame(height: 1)
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(folders.folders) { f in
                            FolderEditRow(
                                folder: f,
                                clipCount: folders.saved(in: f.id).count,
                                onRename: { folders.renameFolder(f, to: $0) },
                                onColor: { folders.setFolderColor(f, $0) },
                                onDelete: { deleteFolder(f) })
                            if f.id != folders.folders.last?.id {
                                Rectangle().fill(PixelTheme.border.opacity(0.4)).frame(height: 1)
                                    .padding(.leading, 12)
                            }
                        }
                    }
                }
                .frame(maxHeight: 220)
            }
        }
        .frame(width: 256).background(PixelTheme.panel)
    }

    private func createFolder() {
        let n = newFolderName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty else { return }
        folders.addFolder(name: n)
        newFolderName = ""
    }

    private func deleteFolder(_ f: ClipFolder) {
        if selectedFolder?.id == f.id { selectedFolder = nil }
        folders.removeFolder(f)
    }

    // MARK: - Recherche

    private var searchField: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass").foregroundStyle(PixelTheme.dim)
            TextField(l10n.clipSearchPlaceholder, text: $search)
                .textFieldStyle(.plain)
                .font(PixelTheme.font(11, .regular))
                .foregroundStyle(PixelTheme.text)
        }
        .padding(.horizontal, 10).padding(.vertical, 7)
    }

    // MARK: - Contenu (historique ou dossier)

    @ViewBuilder
    private var content: some View {
        if let folder = selectedFolder {
            savedList(folder)
        } else {
            historyList
        }
    }

    private var historyList: some View {
        Group {
            if historyItems.isEmpty {
                emptyState(clipboard.history.isEmpty ? l10n.clipEmpty : l10n.clipNoResults)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(historyItems.enumerated()), id: \.element.id) { idx, item in
                            ClipRow(item: item, index: idx,
                                    imageURL: clipboard.imageURL(for: item),
                                    onPick: { onPick(item) },
                                    onDelete: { clipboard.remove(item) },
                                    picker: pickerData(for: item))
                            rowSeparator
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
        }
    }

    private func savedList(_ folder: ClipFolder) -> some View {
        let items = savedItems(in: folder)
        return Group {
            if items.isEmpty {
                emptyState(folders.saved(in: folder.id).isEmpty ? l10n.folderEmpty : l10n.clipNoResults)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(items.enumerated()), id: \.element.id) { idx, clip in
                            ClipRow(item: ClipItem(kind: clip.kind, text: clip.text, imageFile: clip.imageFile),
                                    index: idx,
                                    imageURL: folders.savedImageURL(for: clip),
                                    onPick: {
                                        clipboard.placeOnPasteboard(kind: clip.kind, text: clip.text,
                                                                    imageURL: folders.savedImageURL(for: clip))
                                        onClose()
                                    },
                                    onDelete: { folders.removeSaved(clip) },
                                    picker: nil)
                            rowSeparator
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
        }
    }

    private var rowSeparator: some View {
        Rectangle().fill(PixelTheme.border.opacity(0.5)).frame(height: 1)
    }

    private func emptyState(_ text: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "pawprint.fill")
                .font(.system(size: 22)).foregroundStyle(PixelTheme.dim)
            Text(text)
                .font(PixelTheme.font(10, .regular))
                .foregroundStyle(PixelTheme.dim)
        }
        .frame(maxWidth: .infinity, minHeight: 120)
    }

    // MARK: - Picker de dossier pour un item d'historique

    private func pickerData(for item: ClipItem) -> FolderPickerData {
        let sig = clipSignature(kind: item.kind, text: item.text, imageFile: item.imageFile)
        let src = clipboard.imageURL(for: item)
        return FolderPickerData(
            l10n: l10n,
            folders: folders.folders,
            savedAnywhere: folders.isSavedAnywhere(signature: sig),
            isIn: { folders.isSaved(signature: sig, in: $0.id) },
            toggle: { folders.toggle(kind: item.kind, text: item.text, imageFile: item.imageFile,
                                     imageSource: src, folder: $0) },
            createAndSave: { name in
                let f = folders.addFolder(name: name)
                folders.toggle(kind: item.kind, text: item.text, imageFile: item.imageFile,
                               imageSource: src, folder: f)
            }
        )
    }
}

// MARK: - Picker de dossier (étoile)

/// Données + actions passées à la pop-up de l'étoile pour sauvegarder un clip.
struct FolderPickerData {
    let l10n: L10n
    let folders: [ClipFolder]
    let savedAnywhere: Bool
    let isIn: (ClipFolder) -> Bool
    let toggle: (ClipFolder) -> Void
    let createAndSave: (String) -> Void
}

/// Ligne d'édition d'un dossier : icône + point couleur + nom + badge + corbeille.
private struct FolderEditRow: View {
    let folder: ClipFolder
    var clipCount: Int = 0
    let onRename: (String) -> Void
    let onColor: (Color) -> Void
    let onDelete: () -> Void

    @State private var name = ""
    @State private var hover = false

    var body: some View {
        HStack(spacing: 8) {
            // Folder icon (small)
            PixelFolderView(color: folder.color).frame(width: 20, height: 16)

            // Color dot — clicking opens native ColorPicker
            ColorPicker("", selection: Binding(get: { folder.color }, set: onColor), supportsOpacity: false)
                .labelsHidden()
                .frame(width: 18, height: 18)
                .clipShape(Circle())
                .overlay(Circle().strokeBorder(PixelTheme.border, lineWidth: 1))

            // Name field
            TextField("", text: $name)
                .textFieldStyle(.plain)
                .font(PixelTheme.font(11, .regular))
                .foregroundStyle(PixelTheme.text)
                .onChange(of: name) { onRename($0) }

            Spacer(minLength: 0)

            // Clip count badge
            if clipCount > 0 {
                Text("\(clipCount)")
                    .font(PixelTheme.font(8, .regular))
                    .foregroundStyle(PixelTheme.dim)
                    .padding(.horizontal, 5).padding(.vertical, 1)
                    .background(PixelTheme.bg)
                    .overlay(Rectangle().strokeBorder(PixelTheme.border.opacity(0.6), lineWidth: 1))
            }

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 10))
                    .foregroundStyle(hover ? Color.red.opacity(0.8) : PixelTheme.dim)
            }
            .buttonStyle(.plain)
            .opacity(hover ? 1 : 0.5)
        }
        .padding(.horizontal, 12).padding(.vertical, 8)
        .background(hover ? PixelTheme.panelHi : Color.clear)
        .contentShape(Rectangle())
        .onHover { hover = $0 }
        .onAppear { name = folder.name }
    }
}

private struct FolderPicker: View {
    let data: FolderPickerData
    @State private var newName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(data.l10n.saveToFolder).font(PixelTheme.font(10)).foregroundStyle(PixelTheme.accent)
            if data.folders.isEmpty {
                Text(data.l10n.noFoldersYet)
                    .font(PixelTheme.font(9, .regular)).foregroundStyle(PixelTheme.dim)
            } else {
                ForEach(data.folders) { f in
                    Button { data.toggle(f) } label: {
                        HStack(spacing: 6) {
                            Image(systemName: data.isIn(f) ? "checkmark.square.fill" : "square")
                                .foregroundStyle(data.isIn(f) ? PixelTheme.accent2 : PixelTheme.dim)
                            Rectangle().fill(f.color).frame(width: 10, height: 10)
                                .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
                            Text(f.name).font(PixelTheme.font(11, .regular)).foregroundStyle(PixelTheme.text)
                            Spacer()
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }
            Rectangle().fill(PixelTheme.border).frame(height: 1)
            TextField(data.l10n.newFolderPlaceholder, text: $newName)
                .textFieldStyle(.plain).font(PixelTheme.font(10, .regular))
                .foregroundStyle(PixelTheme.text)
                .padding(.horizontal, 8).padding(.vertical, 5)
                .background(PixelTheme.bg)
                .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
                .onSubmit(create)
            Button(data.l10n.addFolder, action: create)
                .buttonStyle(PixelButtonStyle())
                .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(10).frame(width: 200).background(PixelTheme.panel)
    }

    private func create() {
        let n = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !n.isEmpty else { return }
        data.createAndSave(n)
        newName = ""
    }
}

// MARK: - Ligne de clip

private struct ClipRow: View {
    let item: ClipItem
    let index: Int
    let imageURL: URL?
    let onPick: () -> Void
    let onDelete: () -> Void
    var picker: FolderPickerData? = nil

    @State private var hover = false
    @State private var showPicker = false

    /// La ligne reste « active » (surlignée, actions visibles) tant que le picker est ouvert,
    /// pour éviter que la croix disparaisse et décale l'étoile (ce qui faisait re-popper le popover).
    private var active: Bool { hover || showPicker }

    var body: some View {
        Group {
            if item.kind == .image { imageRow } else { standardRow }
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .background(active ? PixelTheme.panelHi : Color.clear)
        .contentShape(Rectangle())
        .onHover { hover = $0 }
    }

    /// Étoile (sauvegarder) + croix (supprimer) — partagé par les deux types de lignes.
    /// La croix garde toujours sa place (opacité seulement) : l'ancre du popover de l'étoile
    /// ne bouge donc jamais, même quand le survol change.
    @ViewBuilder private var trailing: some View {
        HStack(spacing: 8) {
            if let picker {
                Button { showPicker = true } label: {
                    Image(systemName: picker.savedAnywhere ? "star.fill" : "star")
                }
                .buttonStyle(.plain)
                .foregroundStyle(picker.savedAnywhere ? PixelTheme.accent2 : PixelTheme.dim)
                .popover(isPresented: $showPicker, arrowEdge: .trailing) { FolderPicker(data: picker) }
            }
            Button(action: onDelete) { Image(systemName: "xmark") }
                .buttonStyle(.plain).foregroundStyle(PixelTheme.dim)
                .opacity(active ? 1 : 0)
                .allowsHitTesting(active)
        }
    }

    private var standardRow: some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(String(format: "%02d", index + 1))
                    .font(PixelTheme.font(9))
                    .foregroundStyle(PixelTheme.accent2)

                leading

                VStack(alignment: .leading, spacing: 1) {
                    Text(item.preview)
                        .font(PixelTheme.font(11, .regular))
                        .foregroundStyle(PixelTheme.text)
                        .lineLimit(2)
                    if item.kind == .file {
                        Text(item.text)
                            .font(PixelTheme.font(8, .regular))
                            .foregroundStyle(PixelTheme.dim)
                            .lineLimit(1).truncationMode(.middle)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(Rectangle())
            .onTapGesture(perform: onPick)

            trailing
        }
    }

    private var imageRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Text(String(format: "%02d", index + 1))
                        .font(PixelTheme.font(9))
                        .foregroundStyle(PixelTheme.accent2)
                    leading
                    Text(item.preview)
                        .font(PixelTheme.font(10, .regular))
                        .foregroundStyle(PixelTheme.dim)
                        .lineLimit(1)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture(perform: onPick)

                trailing
            }

            Group {
                if let url = imageURL, let img = NSImage(contentsOf: url) {
                    Image(nsImage: img)
                        .resizable()
                        .interpolation(.medium)
                        .scaledToFill()
                } else {
                    ZStack {
                        PixelTheme.panelHi
                        Image(systemName: "photo")
                            .font(.system(size: 22))
                            .foregroundStyle(PixelTheme.dim)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .clipped()
            .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
            .onTapGesture(perform: onPick)
        }
    }

    @ViewBuilder private var leading: some View {
        switch item.kind {
        case .color:
            Rectangle()
                .fill(item.swatch ?? .clear)
                .frame(width: 18, height: 18)
                .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
        case .image:
            Group {
                if let url = imageURL, let img = NSImage(contentsOf: url) {
                    Image(nsImage: img).resizable().interpolation(.medium).scaledToFill()
                } else {
                    Image(systemName: "photo").foregroundStyle(PixelTheme.dim)
                }
            }
            .frame(width: 26, height: 26)
            .clipped()
            .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
        case .file:
            Image(systemName: "doc.fill")
                .font(.system(size: 14))
                .foregroundStyle(PixelTheme.accent2)
                .frame(width: 18)
        case .text:
            EmptyView()
        }
    }
}

// MARK: - Confirmation vider l'historique

struct ClearHistoryConfirmView: View {
    let title: String
    let message: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Titre
            Text(title)
                .font(PixelTheme.font(13))
                .foregroundStyle(PixelTheme.text)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.top, 28)
                .padding(.bottom, 12)

            // Message
            Text(message)
                .font(PixelTheme.font(10, .regular))
                .foregroundStyle(PixelTheme.dim)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.horizontal, 24)
                .padding(.bottom, 28)

            // Séparateur pixel
            Rectangle()
                .fill(PixelTheme.border)
                .frame(height: 2)

            // Boutons pixel art
            HStack(spacing: 0) {
                // Rouge — annuler
                Button(action: onCancel) {
                    HStack(spacing: 6) {
                        PixelXIcon()
                        Text("CANCEL")
                            .font(PixelTheme.font(11))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                }
                .buttonStyle(PixelConfirmButtonStyle(tint: Color(hex: "#7A2020")))

                Rectangle()
                    .fill(PixelTheme.border)
                    .frame(width: 2)

                // Vert — confirmer
                Button(action: onConfirm) {
                    HStack(spacing: 6) {
                        PixelCheckIcon()
                        Text("CLEAR")
                            .font(PixelTheme.font(11))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                }
                .buttonStyle(PixelConfirmButtonStyle(tint: Color(hex: "#1E5C2A")))
            }
        }
        .frame(width: 320)
        .background(PixelTheme.bg)
        .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 2))
    }
}

private struct PixelConfirmButtonStyle: ButtonStyle {
    let tint: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(PixelTheme.text)
            .background(configuration.isPressed ? tint.darkened(0.15) : tint)
    }
}

// Icône ✓ pixel art (5×4 grille)
private struct PixelCheckIcon: View {
    private let pixels: [(Int, Int)] = [
        (0,3),(1,2),(2,1),(3,0),(4,1),(3,2),(2,3)
    ]
    var body: some View {
        Canvas { ctx, _ in
            for (col, row) in pixels {
                let r = CGRect(x: CGFloat(col) * 2, y: CGFloat(row) * 2, width: 2, height: 2)
                ctx.fill(Path(r), with: .color(.white))
            }
        }
        .frame(width: 10, height: 8)
    }
}

// Icône ✗ pixel art (5×5 grille)
private struct PixelXIcon: View {
    private let pixels: [(Int, Int)] = [
        (0,0),(1,1),(2,2),(3,3),(4,4),
        (4,0),(3,1),(1,3),(0,4)
    ]
    var body: some View {
        Canvas { ctx, _ in
            for (col, row) in pixels {
                let r = CGRect(x: CGFloat(col) * 2, y: CGFloat(row) * 2, width: 2, height: 2)
                ctx.fill(Path(r), with: .color(.white))
            }
        }
        .frame(width: 10, height: 10)
    }
}
