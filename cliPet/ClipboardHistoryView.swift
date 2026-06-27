import SwiftUI

/// Panneau d'historique du presse-papiers (pixel-art) affiché près du chat.
struct ClipboardHistoryView: View {
    @ObservedObject var clipboard: ClipboardManager
    let onPick: (ClipItem) -> Void
    let onClose: () -> Void

    @State private var search = ""

    private var filtered: [ClipItem] {
        guard !search.isEmpty else { return clipboard.history }
        return clipboard.history.filter { $0.text.localizedCaseInsensitiveContains(search) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // En-tête
            HStack(spacing: 6) {
                Image(systemName: "doc.on.clipboard.fill")
                    .foregroundStyle(PixelTheme.accent)
                Text("PRESSE-PAPIERS")
                    .font(PixelTheme.font(11))
                    .foregroundStyle(PixelTheme.text)
                    .tracking(1)
                Spacer()
                Button(action: clipboard.clear) {
                    Image(systemName: "trash.fill")
                }
                .buttonStyle(.plain).foregroundStyle(PixelTheme.dim)
                .help("Vider")
                Button(action: onClose) {
                    Image(systemName: "xmark")
                }
                .buttonStyle(.plain).foregroundStyle(PixelTheme.dim)
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            .background(PixelTheme.panelHi)

            Rectangle().fill(PixelTheme.border).frame(height: 2)

            // Recherche
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass").foregroundStyle(PixelTheme.dim)
                TextField("rechercher…", text: $search)
                    .textFieldStyle(.plain)
                    .font(PixelTheme.font(11, .regular))
                    .foregroundStyle(PixelTheme.text)
            }
            .padding(.horizontal, 10).padding(.vertical, 7)

            Rectangle().fill(PixelTheme.border).frame(height: 2)

            // Liste
            if filtered.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 22)).foregroundStyle(PixelTheme.dim)
                    Text(clipboard.history.isEmpty ? "rien copié pour l'instant" : "aucun résultat")
                        .font(PixelTheme.font(10, .regular))
                        .foregroundStyle(PixelTheme.dim)
                }
                .frame(maxWidth: .infinity, minHeight: 120)
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(filtered.enumerated()), id: \.element.id) { idx, item in
                            ClipRow(item: item, index: idx,
                                    onPick: { onPick(item) },
                                    onDelete: { clipboard.remove(item) })
                            Rectangle().fill(PixelTheme.border.opacity(0.5)).frame(height: 1)
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
        }
        .frame(width: 300)
        .pixelPanel(PixelTheme.bg)
    }
}

private struct ClipRow: View {
    let item: ClipItem
    let index: Int
    let onPick: () -> Void
    let onDelete: () -> Void
    @State private var hover = false

    var body: some View {
        HStack(spacing: 8) {
            Text(String(format: "%02d", index + 1))
                .font(PixelTheme.font(9))
                .foregroundStyle(PixelTheme.accent2)
            Text(item.preview)
                .font(PixelTheme.font(11, .regular))
                .foregroundStyle(PixelTheme.text)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
            if hover {
                Button(action: onDelete) { Image(systemName: "xmark") }
                    .buttonStyle(.plain).foregroundStyle(PixelTheme.dim)
            }
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .background(hover ? PixelTheme.panelHi : Color.clear)
        .contentShape(Rectangle())
        .onHover { hover = $0 }
        .onTapGesture(perform: onPick)
    }
}
