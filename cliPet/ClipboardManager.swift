import AppKit
import SwiftUI
import Combine
import CryptoKit

/// Type de contenu d'un élément du presse-papiers.
enum ClipKind: String, Codable { case text, image, file, color }

/// Un élément d'historique du presse-papiers (texte, image, fichier ou couleur).
struct ClipItem: Identifiable, Equatable, Codable {
    let id: UUID
    let kind: ClipKind
    let text: String         // texte / chemin(s) fichier / hex couleur ; libellé pour image
    let imageFile: String?   // nom du fichier image stocké sur disque (kind == .image)
    let date: Date

    init(kind: ClipKind = .text, text: String = "", imageFile: String? = nil, date: Date = Date()) {
        self.id = UUID()
        self.kind = kind
        self.text = text
        self.imageFile = imageFile
        self.date = date
    }

    /// Aperçu sur une ou deux lignes selon le type.
    var preview: String {
        switch kind {
        case .file:  return (text as NSString).lastPathComponent
        case .image: return text.isEmpty ? "Image" : text
        default:
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let oneLine = trimmed.replacingOccurrences(of: "\n", with: " ")
            return oneLine.count > 120 ? String(oneLine.prefix(120)) + "…" : oneLine
        }
    }

    /// Couleur affichable (kind == .color uniquement).
    var swatch: Color? { kind == .color ? ClipItem.parseColor(text) : nil }

    // MARK: - Détection de couleur

    /// Renvoie une `Color` si la chaîne est un code couleur (#RGB, #RRGGBB[AA],
    /// hex brut, ou rgb(r,g,b)). Sinon `nil`.
    static func parseColor(_ raw: String) -> Color? {
        let s = raw.trimmingCharacters(in: .whitespacesAndNewlines)

        // Formes hexadécimales
        var hex = s.hasPrefix("#") ? String(s.dropFirst()) : s
        if hex.count == 3, hex.allSatisfy(\.isHexDigit) {
            hex = hex.map { "\($0)\($0)" }.joined()   // #RGB -> #RRGGBB
        }
        if (hex.count == 6 || hex.count == 8), hex.allSatisfy(\.isHexDigit) {
            return Color(hex: "#" + hex)
        }

        // rgb(r, g, b)
        if let c = parseRGB(s) { return c }
        return nil
    }

    private static func parseRGB(_ s: String) -> Color? {
        let lower = s.lowercased().replacingOccurrences(of: " ", with: "")
        guard lower.hasPrefix("rgb(") || lower.hasPrefix("rgba(") else { return nil }
        guard let open = lower.firstIndex(of: "("), let close = lower.firstIndex(of: ")") else { return nil }
        let inside = lower[lower.index(after: open)..<close]
        let parts = inside.split(separator: ",").map { Double($0) }
        guard parts.count >= 3, let r = parts[0], let g = parts[1], let b = parts[2] else { return nil }
        return Color(.sRGB, red: r / 255, green: g / 255, blue: b / 255, opacity: 1)
    }
}

/// Surveille NSPasteboard et garde un historique (texte, images, fichiers, couleurs).
final class ClipboardManager: ObservableObject {
    @Published private(set) var history: [ClipItem] = []

    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private var timer: Timer?
    private weak var settings: PetSettings?

    /// Drapeau pour ignorer le changement qu'on provoque nous-mêmes en re-copiant.
    private var ignoreNextChange = false

    init(settings: PetSettings) {
        self.settings = settings
        self.lastChangeCount = pasteboard.changeCount
        loadPersisted()
    }

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
            self?.poll()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Capture

    private func poll() {
        let current = pasteboard.changeCount
        guard current != lastChangeCount else { return }
        lastChangeCount = current

        if ignoreNextChange {
            ignoreNextChange = false
            return
        }

        // 1) Fichiers (priorité — un fichier copié dans le Finder).
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self],
                options: [.urlReadingFileURLsOnly: true]) as? [URL], !urls.isEmpty {
            let paths = urls.map(\.path).joined(separator: "\n")
            add(ClipItem(kind: .file, text: paths))
            return
        }

        // 2) Image (capture d'écran, image copiée depuis le web…).
        if let img = NSImage(pasteboard: pasteboard),
           let png = Self.pngData(img), let file = saveImage(png) {
            add(ClipItem(kind: .image, text: Self.dimensions(png), imageFile: file))
            return
        }

        // 3) Texte — détecté comme couleur si applicable.
        if let str = pasteboard.string(forType: .string),
           !str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            let kind: ClipKind = ClipItem.parseColor(str) != nil ? .color : .text
            add(ClipItem(kind: kind, text: str))
            return
        }
    }

    /// Ajoute un item avec déduplication et plafonnement.
    private func add(_ item: ClipItem) {
        let sig = Self.signature(item)
        if let first = history.first, Self.signature(first) == sig { return }
        history.removeAll { existing in
            let drop = Self.signature(existing) == sig
            if drop, existing.kind == .image { deleteImageFile(existing.imageFile) }
            return drop
        }
        history.insert(item, at: 0)
        enforceCap()
        persist()
    }

    private static func signature(_ i: ClipItem) -> String {
        i.kind == .image ? "img:\(i.imageFile ?? i.id.uuidString)" : "\(i.kind.rawValue):\(i.text)"
    }

    private func enforceCap() {
        // No limit — history grows unbounded
    }

    // MARK: - Re-copie

    /// Remet un élément dans le presse-papiers (clic sur un item de l'historique).
    func copyToPasteboard(_ item: ClipItem) {
        placeOnPasteboard(kind: item.kind, text: item.text, imageURL: imageURL(for: item))

        // Remonte l'item en tête.
        history.removeAll { $0.id == item.id }
        history.insert(item, at: 0)
        persist()
    }

    /// Écrit un contenu brut dans le presse-papiers (utilisé aussi par les clips sauvegardés).
    func placeOnPasteboard(kind: ClipKind, text: String, imageURL: URL?) {
        ignoreNextChange = true
        pasteboard.clearContents()
        switch kind {
        case .image:
            if let url = imageURL, let img = NSImage(contentsOf: url) {
                pasteboard.writeObjects([img])
            }
        case .file:
            let urls = text.split(separator: "\n").map { URL(fileURLWithPath: String($0)) as NSURL }
            if !urls.isEmpty { pasteboard.writeObjects(urls) }
        case .text, .color:
            pasteboard.setString(text, forType: .string)
        }
        lastChangeCount = pasteboard.changeCount
    }

    func remove(_ item: ClipItem) {
        if item.kind == .image { deleteImageFile(item.imageFile) }
        history.removeAll { $0.id == item.id }
        persist()
    }

    func clear() {
        for item in history where item.kind == .image { deleteImageFile(item.imageFile) }
        history.removeAll()
        persist()
    }

    // MARK: - Stockage des images sur disque

    private func clipImagesDir() -> URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("cliPet/clipboard", isDirectory: true)
    }

    /// URL du fichier image associé à un item (kind == .image).
    func imageURL(for item: ClipItem) -> URL? {
        guard item.kind == .image, let file = item.imageFile else { return nil }
        return clipImagesDir()?.appendingPathComponent(file)
    }

    /// Sauvegarde une image PNG (nommage par hash → dédup naturelle). Renvoie le nom.
    private func saveImage(_ data: Data) -> String? {
        guard let dir = clipImagesDir() else { return nil }
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let name = Self.hash(data) + ".png"
        let url = dir.appendingPathComponent(name)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? data.write(to: url)
        }
        return name
    }

    private func deleteImageFile(_ file: String?) {
        guard let file, let dir = clipImagesDir() else { return }
        try? FileManager.default.removeItem(at: dir.appendingPathComponent(file))
    }

    private static func pngData(_ image: NSImage) -> Data? {
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff) else { return nil }
        return rep.representation(using: .png, properties: [:])
    }

    private static func dimensions(_ pngData: Data) -> String {
        guard let rep = NSBitmapImageRep(data: pngData) else { return "Image" }
        return "Image \(rep.pixelsWide)×\(rep.pixelsHigh)"
    }

    private static func hash(_ data: Data) -> String {
        SHA256.hash(data: data).prefix(8).map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Persistance légère (métadonnées ; les images vivent sur disque)

    private static let key = "cliPet.clipboard.v2"

    private func persist() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    private func loadPersisted() {
        guard let data = UserDefaults.standard.data(forKey: Self.key),
              let items = try? JSONDecoder().decode([ClipItem].self, from: data) else { return }
        history = items
    }
}
