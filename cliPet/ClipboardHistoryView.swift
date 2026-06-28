import SwiftUI

/// Panneau d'historique du presse-papiers (pixel-art) + dossiers de favoris.
struct ClipboardHistoryView: View {
    @ObservedObject var clipboard: ClipboardManager
    @ObservedObject var folders: ClipFolderStore
    let l10n: L10n
    let onPick: (ClipItem) -> Void
    let onClose: () -> Void

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
            if selectedFolder == nil {
                Button(action: clipboard.clear) { Image(systemName: "trash.fill") }
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
            VStack(spacing: 2) {
                Group {
                    if let folder {
                        PixelFolderView(color: folder.color).frame(width: 40, height: 32)
                    } else {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 18))
                            .foregroundStyle(PixelTheme.text)
                            .frame(width: 40, height: 32)
                    }
                }
                Text(folder?.name ?? l10n.historyTab)
                    .font(PixelTheme.font(8, .regular))
                    .foregroundStyle(selected ? PixelTheme.text : PixelTheme.dim)
                    .lineLimit(1)
                    .frame(width: 48)
            }
            .padding(4)
            .background(selected ? PixelTheme.panelHi : Color.clear)
            .overlay(Rectangle().strokeBorder(selected ? PixelTheme.accent : .clear, lineWidth: 2))
        }
        .buttonStyle(.plain)
    }

    private var manageFolders: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(l10n.foldersTitle).font(PixelTheme.font(11)).foregroundStyle(PixelTheme.accent)
            HStack(spacing: 6) {
                TextField(l10n.newFolderPlaceholder, text: $newFolderName)
                    .textFieldStyle(.plain).font(PixelTheme.font(10, .regular))
                    .foregroundStyle(PixelTheme.text)
                    .onSubmit(createFolder)
                Button(action: createFolder) { Image(systemName: "plus") }
                    .buttonStyle(.plain).foregroundStyle(PixelTheme.accent2)
            }
            if !folders.folders.isEmpty {
                Rectangle().fill(PixelTheme.border).frame(height: 1)
                ForEach(folders.folders) { f in
                    HStack(spacing: 6) {
                        Rectangle().fill(f.color).frame(width: 12, height: 12)
                            .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
                        Text(f.name).font(PixelTheme.font(11, .regular)).foregroundStyle(PixelTheme.text)
                        Spacer()
                        Button { deleteFolder(f) } label: { Image(systemName: "trash") }
                            .buttonStyle(.plain).foregroundStyle(PixelTheme.dim)
                    }
                }
            }
        }
        .padding(12).frame(width: 220).background(PixelTheme.panel)
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
            HStack(spacing: 6) {
                TextField(data.l10n.newFolderPlaceholder, text: $newName)
                    .textFieldStyle(.plain).font(PixelTheme.font(10, .regular))
                    .foregroundStyle(PixelTheme.text)
                    .onSubmit(create)
                Button(action: create) { Image(systemName: "plus") }
                    .buttonStyle(.plain).foregroundStyle(PixelTheme.accent2)
            }
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

    var body: some View {
        Group {
            if item.kind == .image { imageRow } else { standardRow }
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .background(hover ? PixelTheme.panelHi : Color.clear)
        .contentShape(Rectangle())
        .onHover { hover = $0 }
        .onTapGesture(perform: onPick)
    }

    /// Étoile (sauvegarder) + croix (supprimer) — partagé par les deux types de lignes.
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
            if hover {
                Button(action: onDelete) { Image(systemName: "xmark") }
                    .buttonStyle(.plain).foregroundStyle(PixelTheme.dim)
            }
        }
    }

    private var standardRow: some View {
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

            trailing
        }
    }

    private var imageRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(String(format: "%02d", index + 1))
                    .font(PixelTheme.font(9))
                    .foregroundStyle(PixelTheme.accent2)
                Image(systemName: "photo.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(PixelTheme.dim)
                Text(item.preview)
                    .font(PixelTheme.font(10, .regular))
                    .foregroundStyle(PixelTheme.dim)
                    .lineLimit(1)
                Spacer()
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
