import SwiftUI
import CryptoKit

/// Un dossier (catégorie) personnalisable dans lequel l'utilisateur range ses clips favoris.
struct ClipFolder: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var colorHex: String   // couleur du dossier pixel-art

    init(id: UUID = UUID(), name: String, colorHex: String) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }

    var color: Color { Color(hex: colorHex) }
}

/// Un clip sauvegardé de façon permanente dans un dossier (≠ historique éphémère).
struct SavedClip: Identifiable, Codable, Equatable {
    let id: UUID
    var folderID: UUID
    let kind: ClipKind
    let text: String
    let imageFile: String?   // nom du fichier image dans le dossier `saved/`
    let date: Date

    init(id: UUID = UUID(), folderID: UUID, kind: ClipKind, text: String,
         imageFile: String? = nil, date: Date = Date()) {
        self.id = id
        self.folderID = folderID
        self.kind = kind
        self.text = text
        self.imageFile = imageFile
        self.date = date
    }

    /// Signature de contenu — pour savoir si un clip de l'historique est déjà sauvegardé.
    var signature: String {
        kind == .image ? "img:\(imageFile ?? id.uuidString)" : "\(kind.rawValue):\(text)"
    }
}

/// Calcule la signature de contenu d'un `ClipItem` (même logique que `SavedClip`).
func clipSignature(kind: ClipKind, text: String, imageFile: String?) -> String {
    kind == .image ? "img:\(imageFile ?? "")" : "\(kind.rawValue):\(text)"
}

/// Gère les dossiers personnalisés + les clips qu'ils contiennent (persistés, jamais purgés).
final class ClipFolderStore: ObservableObject {
    @Published private(set) var folders: [ClipFolder] = []
    @Published private(set) var saved: [SavedClip] = []

    /// Palette par défaut pour les nouveaux dossiers (cyclée).
    private static let palette = ["#E0708A", "#7BE0B0", "#E0C36B", "#6BAEE0", "#C58BE0", "#E08B6B"]

    init() { load() }

    // MARK: - Dossiers

    @discardableResult
    func addFolder(name: String) -> ClipFolder {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeName = trimmed.isEmpty ? "Folder \(folders.count + 1)" : trimmed
        let hex = Self.palette[folders.count % Self.palette.count]
        let folder = ClipFolder(name: safeName, colorHex: hex)
        folders.append(folder)
        persist()
        return folder
    }

    func renameFolder(_ folder: ClipFolder, to name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let i = folders.firstIndex(where: { $0.id == folder.id }),
              folders[i].name != trimmed else { return }
        folders[i].name = trimmed
        persist()
    }

    func setFolderColor(_ folder: ClipFolder, _ color: Color) {
        let hex = color.hexString
        guard let i = folders.firstIndex(where: { $0.id == folder.id }), folders[i].colorHex != hex else { return }
        folders[i].colorHex = hex
        persist()
    }

    func removeFolder(_ folder: ClipFolder) {
        // Supprime les clips du dossier (et leurs images si plus référencées).
        for clip in saved where clip.folderID == folder.id {
            removeSavedImageIfOrphan(clip)
        }
        saved.removeAll { $0.folderID == folder.id }
        folders.removeAll { $0.id == folder.id }
        persist()
    }

    // MARK: - Clips sauvegardés

    func saved(in folderID: UUID) -> [SavedClip] {
        saved.filter { $0.folderID == folderID }.sorted { $0.date > $1.date }
    }

    /// Le contenu (par signature) est-il déjà sauvegardé dans ce dossier ?
    func isSaved(signature: String, in folderID: UUID) -> Bool {
        saved.contains { $0.folderID == folderID && $0.signature == signature }
    }

    /// Le contenu est-il sauvegardé dans au moins un dossier ?
    func isSavedAnywhere(signature: String) -> Bool {
        saved.contains { $0.signature == signature }
    }

    /// Bascule l'appartenance d'un clip à un dossier (sauvegarde ↔ retire).
    /// `imageSource` = URL du PNG d'origine (historique) pour les clips image.
    func toggle(kind: ClipKind, text: String, imageFile: String?, imageSource: URL?, folder: ClipFolder) {
        let sig = clipSignature(kind: kind, text: text, imageFile: imageFile)
        if isSaved(signature: sig, in: folder.id) {
            if let clip = saved.first(where: { $0.folderID == folder.id && $0.signature == sig }) {
                removeSaved(clip)
            }
            return
        }
        // Sauvegarde : copie l'image sur disque dans `saved/` pour survivre à la purge.
        var storedImage: String? = nil
        if kind == .image, let src = imageSource {
            storedImage = copyImageToSaved(src)
        }
        let clip = SavedClip(folderID: folder.id, kind: kind, text: text, imageFile: storedImage)
        saved.insert(clip, at: 0)
        persist()
    }

    func removeSaved(_ clip: SavedClip) {
        saved.removeAll { $0.id == clip.id }
        removeSavedImageIfOrphan(clip)
        persist()
    }

    // MARK: - Images sauvegardées (dossier dédié, indépendant de l'historique)

    private func savedImagesDir() -> URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("cliPet/saved", isDirectory: true)
    }

    func savedImageURL(for clip: SavedClip) -> URL? {
        guard clip.kind == .image, let file = clip.imageFile else { return nil }
        return savedImagesDir()?.appendingPathComponent(file)
    }

    private func copyImageToSaved(_ src: URL) -> String? {
        guard let dir = savedImagesDir(), let data = try? Data(contentsOf: src) else { return nil }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let name = SHA256.hash(data: data).prefix(8).map { String(format: "%02x", $0) }.joined() + ".png"
        let dest = dir.appendingPathComponent(name)
        if !FileManager.default.fileExists(atPath: dest.path) {
            try? data.write(to: dest)
        }
        return name
    }

    /// Supprime le fichier image d'un clip seulement si aucun autre clip sauvegardé ne l'utilise.
    private func removeSavedImageIfOrphan(_ clip: SavedClip) {
        guard let file = clip.imageFile, let dir = savedImagesDir() else { return }
        let stillUsed = saved.contains { $0.id != clip.id && $0.imageFile == file }
        if !stillUsed {
            try? FileManager.default.removeItem(at: dir.appendingPathComponent(file))
        }
    }

    // MARK: - Persistance (métadonnées en UserDefaults ; images sur disque)

    private static let foldersKey = "cliPet.folders.v1"
    private static let savedKey   = "cliPet.saved.v1"

    private func persist() {
        if let d = try? JSONEncoder().encode(folders) { UserDefaults.standard.set(d, forKey: Self.foldersKey) }
        if let d = try? JSONEncoder().encode(saved)   { UserDefaults.standard.set(d, forKey: Self.savedKey) }
    }

    private func load() {
        if let d = UserDefaults.standard.data(forKey: Self.foldersKey),
           let f = try? JSONDecoder().decode([ClipFolder].self, from: d) { folders = f }
        if let d = UserDefaults.standard.data(forKey: Self.savedKey),
           let s = try? JSONDecoder().decode([SavedClip].self, from: d) { saved = s }
    }
}

// MARK: - Dossier pixel-art

/// Icône de dossier dessinée façon pixel-art (silhouette à onglet, contour net + biseau).
struct PixelFolderView: View {
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let x0 = w * 0.08, x1 = w * 0.92
            let tabRight = w * 0.46
            let yTabTop = h * 0.20, yTop = h * 0.34, yBot = h * 0.86

            let silhouette = Path { p in
                p.move(to: CGPoint(x: x0, y: yTabTop))
                p.addLine(to: CGPoint(x: tabRight, y: yTabTop))
                p.addLine(to: CGPoint(x: tabRight + w * 0.08, y: yTop))
                p.addLine(to: CGPoint(x: x1, y: yTop))
                p.addLine(to: CGPoint(x: x1, y: yBot))
                p.addLine(to: CGPoint(x: x0, y: yBot))
                p.closeSubpath()
            }

            ZStack {
                silhouette.fill(color)
                // Biseau clair en haut (effet relief pixel).
                Path { p in
                    p.move(to: CGPoint(x: x0, y: yTop + 1))
                    p.addLine(to: CGPoint(x: x1, y: yTop + 1))
                }
                .stroke(Color.white.opacity(0.25), lineWidth: 2)
                silhouette.stroke(PixelTheme.border, lineWidth: 2)
            }
        }
    }
}
