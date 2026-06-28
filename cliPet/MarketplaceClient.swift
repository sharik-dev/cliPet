import Foundation
import SwiftUI

// ============================================================================
// Marketplace : partage et téléchargement de pets via l'API clipet.sharik.fr.
//
// Un pet partagé = { name, frames, palette }. Au partage, on « cuit » les
// couleurs effectives dans la palette pour que le pet s'affiche à l'identique
// chez le téléchargeur (indépendamment de ses réglages).
// ============================================================================

enum MarketAPI {
    static let base = URL(string: "https://clipet.sharik.fr/api")!
}

/// Palette portable d'un pet (miroir de SpriteStore.PaletteData).
struct MarketPalette: Codable {
    var customColors: [String: String]
    var addedChars: [String]
    var colorNames: [String: String]

    init(customColors: [String: String] = [:], addedChars: [String] = [], colorNames: [String: String] = [:]) {
        self.customColors = customColors; self.addedChars = addedChars; self.colorNames = colorNames
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        customColors = (try? c.decode([String: String].self, forKey: .customColors)) ?? [:]
        addedChars   = (try? c.decode([String].self, forKey: .addedChars)) ?? []
        colorNames   = (try? c.decode([String: String].self, forKey: .colorNames)) ?? [:]
    }
}

struct MarketPreview: Codable { var frame: [String]; var palette: MarketPalette }

struct MarketPet: Codable, Identifiable {
    var id: String
    var name: String
    var author: String
    var downloads: Int
    var createdAt: String
    var preview: MarketPreview
}

struct MarketPetFull: Codable {
    var id: String
    var name: String
    var author: String
    var frames: [String: [String]]
    var palette: MarketPalette
}

enum MarketError: LocalizedError {
    case http(Int), decode, network
    var errorDescription: String? {
        switch self {
        case .http(let c): return "Server error (\(c))."
        case .decode: return "Unexpected response."
        case .network: return "Could not reach the marketplace."
        }
    }
}

enum MarketplaceClient {

    static func list() async throws -> [MarketPet] {
        let (data, resp) = try await URLSession.shared.data(from: MarketAPI.base.appending(path: "pets"))
        try ensureOK(resp)
        do { return try JSONDecoder().decode([MarketPet].self, from: data) }
        catch { throw MarketError.decode }
    }

    static func fetch(_ id: String) async throws -> MarketPetFull {
        let (data, resp) = try await URLSession.shared.data(from: MarketAPI.base.appending(path: "pets/\(id)"))
        try ensureOK(resp)
        do { return try JSONDecoder().decode(MarketPetFull.self, from: data) }
        catch { throw MarketError.decode }
    }

    @discardableResult
    static func publish(name: String, frames: [String: [String]], palette: MarketPalette, author: String) async throws -> String {
        var req = URLRequest(url: MarketAPI.base.appending(path: "pets"))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode([
            "name": AnyEnc(name), "author": AnyEnc(author),
            "frames": AnyEnc(frames), "palette": AnyEnc(palette),
        ])
        let (data, resp) = try await URLSession.shared.data(for: req)
        try ensureOK(resp)
        let obj = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
        guard let id = obj?["id"] as? String else { throw MarketError.decode }
        return id
    }

    static func report(_ id: String, reason: String) async throws {
        try await post("pets/\(id)/report", body: ["reason": reason])
    }

    static func markDownloaded(_ id: String) async {
        try? await post("pets/\(id)/download", body: [:])
    }

    // MARK: - Helpers

    private static func post(_ path: String, body: [String: String]) async throws {
        var req = URLRequest(url: MarketAPI.base.appending(path: path))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: body)
        let (_, resp) = try await URLSession.shared.data(for: req)
        try ensureOK(resp)
    }

    private static func ensureOK(_ resp: URLResponse) throws {
        guard let http = resp as? HTTPURLResponse else { throw MarketError.network }
        guard (200..<300).contains(http.statusCode) else { throw MarketError.http(http.statusCode) }
    }
}

/// Encodeur hétérogène minimal pour assembler le corps JSON de publication.
struct AnyEnc: Encodable {
    private let enc: (Encoder) throws -> Void
    init<T: Encodable>(_ value: T) { enc = value.encode }
    func encode(to encoder: Encoder) throws { try enc(encoder) }
}

// MARK: - Pont avec SpriteStore (partage / téléchargement)

enum MarketBridge {
    /// Construit le pet partageable depuis le skin actif (couleurs cuites).
    /// Réutilise le format `.clipet` (PetPackage) — une seule source de vérité.
    @MainActor
    static func currentPet(settings: PetSettings) -> (frames: [String: [String]], palette: MarketPalette) {
        let frames = SpriteStore.shared.frames
        return (frames, PetPackage.bakedPalette(frames: frames, settings: settings))
    }

    /// Installe un pet téléchargé comme nouveau skin utilisateur et l'active.
    @MainActor
    static func install(_ pet: MarketPetFull) {
        PetInstaller.install(name: pet.name, frames: pet.frames, palette: pet.palette, idPrefix: "market")
    }
}
