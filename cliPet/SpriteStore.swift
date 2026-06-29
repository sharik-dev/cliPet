import Foundation
import Combine
import SwiftUI

/// Source unique des frames de sprites utilisées par le rendu.
/// Gère le skin actif (parmi le catalogue), les retouches faites dans l'éditeur
/// et la palette de couleurs personnalisée (pour créer ses propres pets).
/// Tout est sauvegardé par skin sur disque, automatiquement, rechargé sans rebuild.
final class SpriteStore: ObservableObject {
    static let shared = SpriteStore()

    @Published private(set) var activeSkinId: String
    @Published private(set) var frames: [String: [String]] = [:]

    /// Couleurs personnalisées : char -> hex. Surcharge le rendu par défaut.
    @Published private(set) var customColors: [String: String] = [:]
    /// Couleurs ajoutées par l'utilisateur (chars hors palette de base), dans l'ordre.
    @Published private(set) var addedChars: [String] = []
    /// Noms donnés aux couleurs : char -> nom (ex. "fourrure", "contour").
    /// Ces noms deviennent des variables modifiables dans la gestion des couleurs.
    @Published private(set) var colorNames: [String: String] = [:]

    private struct PaletteData: Codable {
        var customColors: [String: String]
        var addedChars: [String]
        var colorNames: [String: String]?   // optionnel : compat anciens fichiers

        enum CodingKeys: String, CodingKey { case customColors, addedChars, colorNames }
    }

    private init() {
        activeSkinId = UserDefaults.standard.string(forKey: Self.skinKey)
            ?? SkinCatalog.builtins[0].id
        reloadFrames()
        reloadPalette()
    }

    // MARK: - Skin actif

    func setActiveSkin(_ id: String) {
        activeSkinId = id
        UserDefaults.standard.set(id, forKey: Self.skinKey)
        reloadFrames()
        reloadPalette()
    }

    private func reloadFrames() {
        var f = SkinCatalog.skin(activeSkinId).frames
        // Niche par défaut : tout skin (même importé) peut afficher / éditer sa maison.
        if f["niche"] == nil { f["niche"] = CatSprites.niche }
        if let custom = loadCustom(for: activeSkinId) {
            f.merge(custom) { _, new in new }   // retouches éditeur par-dessus
        }
        frames = f
    }

    /// Frame courante par nom (fallback sur défaut du skin actif puis idle).
    func frame(_ name: String) -> [String] {
        if let r = frames[name] { return r }
        let skin = SkinCatalog.skin(activeSkinId)
        return skin.frames[name] ?? skin.frames["idle1"] ?? CatSprites.idle
    }

    var catSize: Int { frames["idle1"]?.first?.count ?? 33 }
    var yarnSize: Int { frames["yarn1"]?.first?.count ?? 12 }

    // MARK: - Édition des frames (auto-sauvegardée)

    func update(_ name: String, _ rows: [String]) {
        frames[name] = rows
        scheduleSave()
    }

    // MARK: - Palette de couleurs personnalisée

    /// Palette de base (rôles historiques du chat) — toujours disponible.
    static let baseChars: [Character] = ["X", "g", "d", "w", "o", "h", "p", "r"]

    /// Surcharges de couleurs à utiliser pour l'APERÇU d'un skin donné.
    /// Le skin actif renvoie la palette en mémoire (reflète les retouches en cours) ;
    /// les autres sont lus sur disque. Permet d'afficher chaque carte avec SA palette
    /// au lieu de celle du skin actif.
    func previewColors(for skinId: String) -> [String: String] {
        skinId == activeSkinId ? customColors : Self.diskColors(for: skinId)
    }

    private static func diskColors(for skinId: String) -> [String: String] {
        guard let url = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
                .appendingPathComponent("cliPet/palette_\(skinId).json"),
              let data = try? Data(contentsOf: url),
              let payload = try? JSONDecoder().decode(PaletteData.self, from: data)
        else { return [:] }
        return payload.customColors
    }

    /// Couleur personnalisée pour un caractère (nil si non surchargé).
    func customColor(for ch: Character) -> Color? {
        guard let hex = customColors[String(ch)] else { return nil }
        return Color(hex: hex)
    }

    /// Définit / surcharge la couleur d'un caractère.
    func setColor(_ ch: Character, _ color: Color) {
        customColors[String(ch)] = color.hexString
        scheduleSave()
    }

    /// Nom donné à une couleur (nil si non nommée).
    func colorName(for ch: Character) -> String? {
        let n = colorNames[String(ch)]
        return (n?.isEmpty == false) ? n : nil
    }

    /// Nomme une couleur (vide = retire le nom). Le nom devient une variable
    /// modifiable dans la gestion des couleurs pour produire des variantes.
    func setColorName(_ ch: Character, _ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { colorNames[String(ch)] = nil }
        else { colorNames[String(ch)] = trimmed }
        scheduleSave()
    }

    /// Caractères de palette qui portent un nom (= variables nommées), base + ajoutées.
    var namedChars: [Character] {
        (Self.baseChars + addedChars.map { Character($0) }).filter { colorName(for: $0) != nil }
    }

    /// Ajoute une nouvelle couleur à la palette. Renvoie le caractère alloué.
    @discardableResult
    func addColor(_ color: Color) -> Character {
        let ch = nextFreeChar()
        customColors[String(ch)] = color.hexString
        addedChars.append(String(ch))
        scheduleSave()
        return ch
    }

    /// Retire l'override de couleur d'un caractère (sans toucher au nom ni à addedChars).
    func clearColor(_ ch: Character) {
        guard customColors[String(ch)] != nil else { return }
        customColors[String(ch)] = nil
        scheduleSave()
    }

    /// Épingle le jeu de couleurs courant (rôles de base) comme overrides propres au
    /// skin actif : applique ces couleurs sur CE pet précis, sans créer de variante
    /// réutilisable dans la grille des coats.
    func applyBaseColorsToActiveSkin(body: Color, belly: Color, stripe: Color,
                                     eye: Color, nose: Color) {
        customColors["g"] = body.hexString
        customColors["w"] = belly.hexString
        customColors["d"] = stripe.hexString
        customColors["o"] = eye.hexString
        customColors["p"] = nose.hexString
        scheduleSave()
    }

    /// Retire les overrides des couleurs de base (rôles) : ils masqueraient les coats.
    func clearBaseOverrides() {
        var changed = false
        for ch in Self.baseChars where customColors[String(ch)] != nil {
            customColors[String(ch)] = nil
            changed = true
        }
        if changed { scheduleSave() }
    }

    /// Retire une couleur ajoutée par l'utilisateur.
    func removeColor(_ ch: Character) {
        customColors[String(ch)] = nil
        colorNames[String(ch)] = nil
        addedChars.removeAll { $0 == String(ch) }
        scheduleSave()
    }

    private func nextFreeChar() -> Character {
        let reserved = Set<Character>(Self.baseChars + ["."])
        let pool = Array("123456789abcefijklmnqstuvyzABCDEFGHIJKLMNOPQRSTUVWYZ")
        for c in pool where !reserved.contains(c)
            && customColors[String(c)] == nil && !addedChars.contains(String(c)) {
            return c
        }
        return "?"
    }

    // MARK: - Sauvegarde (auto, débouncée)

    private var saveWork: DispatchWorkItem?

    private func scheduleSave() {
        saveWork?.cancel()
        let work = DispatchWorkItem { [weak self] in self?.save() }
        saveWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: work)
    }

    func save() {
        saveFrames()
        savePalette()
    }

    private func saveFrames() {
        guard let url = customURL(for: activeSkinId) else { return }
        try? FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        if let data = try? JSONEncoder().encode(frames) { try? data.write(to: url) }
    }

    private func savePalette() {
        guard let url = paletteURL(for: activeSkinId) else { return }
        try? FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let payload = PaletteData(customColors: customColors, addedChars: addedChars,
                                  colorNames: colorNames)
        if let data = try? JSONEncoder().encode(payload) { try? data.write(to: url) }
    }

    func resetToDefault() {
        if let url = customURL(for: activeSkinId) { try? FileManager.default.removeItem(at: url) }
        if let url = paletteURL(for: activeSkinId) { try? FileManager.default.removeItem(at: url) }
        reloadFrames()
        reloadPalette()
    }

    var savePath: String { customURL(for: activeSkinId)?.path ?? "—" }

    // MARK: - Disque

    private static let skinKey = "cliPet.activeSkin"

    private func appSupport() -> URL? {
        FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first?
            .appendingPathComponent("cliPet", isDirectory: true)
    }

    private func customURL(for skin: String) -> URL? {
        appSupport()?.appendingPathComponent("edits_\(skin).json")
    }

    private func paletteURL(for skin: String) -> URL? {
        appSupport()?.appendingPathComponent("palette_\(skin).json")
    }

    private func loadCustom(for skin: String) -> [String: [String]]? {
        guard let url = customURL(for: skin),
              let data = try? Data(contentsOf: url),
              let dict = try? JSONDecoder().decode([String: [String]].self, from: data)
        else { return nil }
        return dict
    }

    private func reloadPalette() {
        guard let url = paletteURL(for: activeSkinId),
              let data = try? Data(contentsOf: url),
              let payload = try? JSONDecoder().decode(PaletteData.self, from: data) else {
            customColors = [:]
            addedChars = []
            colorNames = [:]
            return
        }
        customColors = payload.customColors
        addedChars = payload.addedChars
        colorNames = payload.colorNames ?? [:]
    }
}
