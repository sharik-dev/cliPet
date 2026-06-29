import Foundation

extension Notification.Name {
    /// Émise quand la liste des skins change (install marketplace, import, renommage, suppression).
    /// Les grilles de skins (Réglages + gestionnaire) s'y abonnent pour se rafraîchir.
    static let skinsChanged = Notification.Name("cliPet.skinsChanged")
}

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

    /// Tous les skins disponibles (intégrés + utilisateur), avec noms personnalisés appliqués.
    static func all() -> [Skin] {
        let overrides = loadNameOverrides()
        let named = builtins.map { skin -> Skin in
            guard let custom = overrides[skin.id] else { return skin }
            return Skin(id: skin.id, name: custom, builtin: true, frames: skin.frames)
        }
        return named + userSkins()
    }

    static func skin(_ id: String) -> Skin {
        all().first { $0.id == id } ?? builtins[0]
    }

    // MARK: - Renommage

    /// Renomme un skin. Pour les skins utilisateur : met à jour le fichier JSON.
    /// Pour les skins intégrés : sauvegarde le nom dans un fichier d'overrides.
    static func renameSkin(_ id: String, to newName: String) {
        if let dir = skinsDirectory,
           let urls = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) {
            for url in urls where url.pathExtension == "json" {
                if let data = try? Data(contentsOf: url),
                   let sf = try? JSONDecoder().decode(SkinFile.self, from: data),
                   sf.id == id {
                    let updated = SkinFile(id: sf.id, name: newName, frames: sf.frames)
                    if let newData = try? JSONEncoder().encode(updated) {
                        try? newData.write(to: url)
                    }
                    NotificationCenter.default.post(name: .skinsChanged, object: nil)
                    return
                }
            }
        }
        var overrides = loadNameOverrides()
        overrides[id] = newName
        saveNameOverrides(overrides)
        NotificationCenter.default.post(name: .skinsChanged, object: nil)
    }

    /// Supprime un skin utilisateur (fichier JSON + palette + retouches).
    /// Les skins intégrés ne peuvent pas être supprimés.
    static func deleteSkin(_ id: String) {
        if let dir = skinsDirectory,
           let urls = try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) {
            for url in urls where url.pathExtension == "json" {
                if let data = try? Data(contentsOf: url),
                   let sf = try? JSONDecoder().decode(SkinFile.self, from: data),
                   sf.id == id {
                    try? FileManager.default.removeItem(at: url)
                }
            }
        }
        if let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("cliPet", isDirectory: true) {
            try? FileManager.default.removeItem(at: base.appendingPathComponent("palette_\(id).json"))
            try? FileManager.default.removeItem(at: base.appendingPathComponent("edits_\(id).json"))
        }
        NotificationCenter.default.post(name: .skinsChanged, object: nil)
    }

    // MARK: - Overrides de noms (skins intégrés)

    private static var namesURL: URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("cliPet/skin_names.json")
    }

    private static func loadNameOverrides() -> [String: String] {
        guard let url = namesURL,
              let data = try? Data(contentsOf: url),
              let dict = try? JSONDecoder().decode([String: String].self, from: data)
        else { return [:] }
        return dict
    }

    private static func saveNameOverrides(_ dict: [String: String]) {
        guard let url = namesURL else { return }
        try? FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        if let data = try? JSONEncoder().encode(dict) { try? data.write(to: url) }
    }

    // MARK: - Skins utilisateur (JSON déposés dans Application Support/cliPet/skins/)

    static var skinsDirectory: URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("cliPet/skins", isDirectory: true)
    }

    struct SkinFile: Codable { let id: String; let name: String; let frames: [String: [String]] }

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
