import Foundation
import Combine

/// Source unique des frames de sprites utilisées par le rendu.
/// Part des frames par défaut (CatSprites) et applique un override custom
/// sauvegardé sur disque (édité via l'outil dev), rechargé sans rebuild.
final class SpriteStore: ObservableObject {
    static let shared = SpriteStore()

    /// frames[nom] = lignes (ex: "idle", "walk1", "yarn1"…)
    @Published private(set) var frames: [String: [String]]

    private init() {
        frames = CatSprites.all
        if let custom = Self.loadFromDisk() {
            // Fusionne : on garde les défauts pour les frames non éditées.
            frames.merge(custom) { _, new in new }
        }
    }

    /// Frame courante par nom (fallback sur défaut puis idle).
    func frame(_ name: String) -> [String] {
        frames[name] ?? CatSprites.all[name] ?? CatSprites.idle
    }

    // MARK: - Édition (outil dev)

    func update(_ name: String, _ rows: [String]) {
        frames[name] = rows
    }

    func save() {
        guard let url = Self.fileURL() else { return }
        try? FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        if let data = try? JSONEncoder().encode(frames) {
            try? data.write(to: url)
        }
    }

    func resetToDefault() {
        frames = CatSprites.all
        if let url = Self.fileURL() { try? FileManager.default.removeItem(at: url) }
    }

    /// Chemin du fichier custom, exposé pour info dans l'éditeur.
    static var savePath: String { fileURL()?.path ?? "—" }

    // MARK: - Disque

    private static func fileURL() -> URL? {
        FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("cliPet/sprites_v2.json")
    }

    private static func loadFromDisk() -> [String: [String]]? {
        guard let url = fileURL(),
              let data = try? Data(contentsOf: url),
              let dict = try? JSONDecoder().decode([String: [String]].self, from: data)
        else { return nil }
        return dict
    }
}
