import Foundation
import SwiftUI
import AppKit

// ============================================================================
// Format de pet portable « .clipet » — un fichier unique, autosuffisant.
//
// Contient TOUT ce qu'il faut pour reconstituer le pet à l'identique :
//   • name      : nom du pet
//   • frames    : tous les états / toutes les frames ([nom → grille de chars])
//   • palette   : couleurs CUITES (chaque char utilisé → hex), + chars ajoutés
//                 et noms de couleurs, pour un rendu indépendant des réglages.
//
// Ce même modèle sert au partage par fichier ET à la marketplace.
// ============================================================================

struct PetPackage: Codable {
    var format: String
    var version: Int
    var name: String
    var frames: [String: [String]]
    var palette: MarketPalette

    static let currentFormat = "clipet-pet"
    static let currentVersion = 1
    static let fileExtension = "clipet"

    init(name: String, frames: [String: [String]], palette: MarketPalette) {
        self.format = Self.currentFormat
        self.version = Self.currentVersion
        self.name = name
        self.frames = frames
        self.palette = palette
    }

    // Décodage tolérant : accepte aussi un ancien skin {id?, name, frames} sans palette.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        format  = (try? c.decode(String.self, forKey: .format)) ?? Self.currentFormat
        version = (try? c.decode(Int.self, forKey: .version)) ?? Self.currentVersion
        name    = (try? c.decode(String.self, forKey: .name)) ?? "Imported pet"
        frames  = (try? c.decode([String: [String]].self, forKey: .frames)) ?? [:]
        palette = (try? c.decode(MarketPalette.self, forKey: .palette)) ?? MarketPalette()
    }

    // MARK: - Construction depuis le pet actif (couleurs cuites)

    /// Paquet du pet courant : frames du skin actif + palette effective cuite.
    @MainActor
    static func fromCurrent(name: String, settings: PetSettings) -> PetPackage {
        let store = SpriteStore.shared
        let frames = store.frames
        let palette = bakedPalette(frames: frames, settings: settings)
        return PetPackage(name: name, frames: frames, palette: palette)
    }

    /// Cuit les couleurs effectives de chaque char utilisé (rôles recolorés
    /// depuis les réglages + surcharges utilisateur) pour un pet autosuffisant.
    @MainActor
    static func bakedPalette(frames: [String: [String]], settings: PetSettings) -> MarketPalette {
        let store = SpriteStore.shared
        let pal = PixelPalette(body: settings.bodyColor, belly: settings.bellyColor,
                               stripe: settings.stripeColor, eye: settings.eyeColor, nose: settings.noseColor)
        var used = Set<Character>()
        for rows in frames.values { for row in rows { for ch in row where ch != "." { used.insert(ch) } } }
        var baked = store.customColors
        for ch in used where baked[String(ch)] == nil {
            if let c = pal.color(for: ch) { baked[String(ch)] = c.hexString }
        }
        let baseSet = Set(SpriteStore.baseChars)
        let added = used.filter { !baseSet.contains($0) }.map { String($0) }
        return MarketPalette(customColors: baked, addedChars: added, colorNames: store.colorNames)
    }

    /// Paquet exportable pour un skin donné (lit ses retouches + sa palette sur
    /// disque ; replie sur la cuisson depuis les réglages si pas de palette).
    @MainActor
    static func forSkin(_ skin: Skin, settings: PetSettings) -> PetPackage {
        var frames = skin.frames
        if let edits = loadAppSupportJSON([String: [String]].self, "edits_\(skin.id).json") {
            frames.merge(edits) { _, new in new }
        }
        let palette = loadAppSupportJSON(MarketPalette.self, "palette_\(skin.id).json")
            ?? bakedPalette(frames: frames, settings: settings)
        return PetPackage(name: skin.name, frames: frames, palette: palette)
    }

    private static func loadAppSupportJSON<T: Decodable>(_ type: T.Type, _ file: String) -> T? {
        guard let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        else { return nil }
        let url = base.appendingPathComponent("cliPet/\(file)")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - Sérialisation fichier

    func encoded() throws -> Data {
        let enc = JSONEncoder()
        enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try enc.encode(self)
    }

    /// Charge un pet depuis une URL : fichier `.clipet`/`.json`, ou un DOSSIER
    /// contenant un tel fichier (on prend le premier trouvé).
    static func load(from url: URL) throws -> PetPackage {
        var fileURL = url
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
            let items = (try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) ?? []
            guard let found = items.first(where: { ["clipet", "json"].contains($0.pathExtension.lowercased()) }) else {
                throw PetPackageError.notFound
            }
            fileURL = found
        }
        let data = try Data(contentsOf: fileURL)
        do { return try JSONDecoder().decode(PetPackage.self, from: data) }
        catch { throw PetPackageError.invalid }
    }

    // MARK: - Installation comme skin utilisateur

    /// Écrit le pet comme skin utilisateur (frames + palette) et l'active.
    @discardableResult
    @MainActor
    func install(activate: Bool = true) -> String {
        PetInstaller.install(name: name, frames: frames, palette: palette, activate: activate)
    }
}

enum PetPackageError: LocalizedError {
    case notFound, invalid
    var errorDescription: String? {
        switch self {
        case .notFound: return "No pet file found."
        case .invalid:  return "This file is not a valid cliPet pet."
        }
    }
}

/// Installe un pet (frames + palette) comme skin utilisateur sur disque.
/// Partagé entre l'import fichier et le téléchargement marketplace.
enum PetInstaller {
    @discardableResult
    @MainActor
    static func install(name: String, frames: [String: [String]], palette: MarketPalette,
                        idPrefix: String = "pet", activate: Bool = true) -> String {
        let skinId = "\(idPrefix)-\(UUID().uuidString.prefix(8))"
        if let dir = SkinCatalog.skinsDirectory {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
            let skinFile = SkinCatalog.SkinFile(id: skinId, name: name, frames: frames)
            if let data = try? JSONEncoder().encode(skinFile) {
                try? data.write(to: dir.appendingPathComponent("\(skinId).json"))
            }
        }
        if let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
            let url = appSupport.appendingPathComponent("cliPet/palette_\(skinId).json")
            let payload: [String: Any] = [
                "customColors": palette.customColors,
                "addedChars": palette.addedChars,
                "colorNames": palette.colorNames,
            ]
            try? FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            if let data = try? JSONSerialization.data(withJSONObject: payload) { try? data.write(to: url) }
        }
        if activate { SpriteStore.shared.setActiveSkin(skinId) }
        return skinId
    }
}
