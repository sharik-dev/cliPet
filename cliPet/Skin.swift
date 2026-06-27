import Foundation

/// Un skin = un jeu complet de frames pixel-art pour le chat.
struct Skin: Identifiable, Equatable {
    let id: String
    let name: String
    let builtin: Bool
    let frames: [String: [String]]

    /// Taille de la grille du chat (déduite d'une frame).
    var catSize: Int { frames["idle1"]?.first?.count ?? frames["idle"]?.first?.count ?? 33 }
    var yarnSize: Int { frames["yarn1"]?.first?.count ?? 12 }

    static func == (a: Skin, b: Skin) -> Bool { a.id == b.id }
}

/// Catalogue des skins : intégrés + ceux déposés en JSON sur disque.
enum SkinCatalog {
    /// Skins fournis avec l'app.
    static let builtins: [Skin] = [
        Skin(id: "coeur", name: "Cœur gris", builtin: true, frames: CatSprites.all),
    ]

    /// Tous les skins disponibles (intégrés + utilisateur).
    static func all() -> [Skin] {
        builtins + userSkins()
    }

    static func skin(_ id: String) -> Skin {
        all().first { $0.id == id } ?? builtins[0]
    }

    // MARK: - Skins utilisateur (JSON déposés dans Application Support/cliPet/skins/)

    static var skinsDirectory: URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("cliPet/skins", isDirectory: true)
    }

    private struct SkinFile: Codable { let id: String; let name: String; let frames: [String: [String]] }

    static func userSkins() -> [Skin] {
        guard let dir = skinsDirectory,
              let urls = try? FileManager.default.contentsOfDirectory(
                at: dir, includingPropertiesForKeys: nil) else { return [] }
        var result: [Skin] = []
        for url in urls where url.pathExtension == "json" {
            if let data = try? Data(contentsOf: url),
               let f = try? JSONDecoder().decode(SkinFile.self, from: data) {
                result.append(Skin(id: f.id, name: f.name, builtin: false, frames: f.frames))
            }
        }
        return result.sorted { $0.name < $1.name }
    }
}
