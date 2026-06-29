import SwiftUI

/// Thème pixel-art rétro partagé par toutes les interfaces.
enum PixelTheme {
    static let bg      = Color(hex: "#1E1E2E")
    static let panel   = Color(hex: "#2A2A40")
    static let panelHi = Color(hex: "#33334F")
    static let border  = Color(hex: "#12121C")
    static let bevel   = Color(hex: "#5A5A82")
    static let text    = Color(hex: "#ECECF4")
    static let dim     = Color(hex: "#9A9AB8")
    static let accent  = Color(hex: "#E0708A")
    static let accent2 = Color(hex: "#7BE0B0")

    static func font(_ size: CGFloat, _ weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

/// Bordure "pixel" : contour foncé net + léger biseau clair en haut/gauche.
struct PixelBorder: ViewModifier {
    var fill: Color = PixelTheme.panel
    func body(content: Content) -> some View {
        content
            .background(fill)
            .overlay(Rectangle().strokeBorder(PixelTheme.bevel.opacity(0.5), lineWidth: 1).padding(1))
            .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 2))
    }
}

extension View {
    func pixelPanel(_ fill: Color = PixelTheme.panel) -> some View {
        modifier(PixelBorder(fill: fill))
    }
}

/// Bouton chunky pixel-art.
struct PixelButtonStyle: ButtonStyle {
    var tint: Color = PixelTheme.panelHi
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(PixelTheme.font(12))
            .foregroundStyle(PixelTheme.text)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? tint.darkened(0.2) : tint)
            .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 2))
            .offset(y: configuration.isPressed ? 1 : 0)
    }
}

/// Icône pixel-art monochrome : une grille de caractères où `#` = pixel plein.
/// Rendue dans une couleur unique, alignée sur la grille (look 8-bit net).
struct PixelIcon: View {
    let rows: [String]
    var color: Color = PixelTheme.text
    var size: CGFloat = 14

    var body: some View {
        Canvas { ctx, canvas in
            let h = rows.count
            guard h > 0 else { return }
            let w = rows.map { $0.count }.max() ?? 0
            guard w > 0 else { return }
            let cell = min(canvas.width / CGFloat(w), canvas.height / CGFloat(h))
            let ox = (canvas.width - cell * CGFloat(w)) / 2
            let oy = (canvas.height - cell * CGFloat(h)) / 2
            for (gy, row) in rows.enumerated() {
                for (gx, ch) in row.enumerated() where ch == "#" {
                    let rect = CGRect(x: ox + CGFloat(gx) * cell, y: oy + CGFloat(gy) * cell,
                                      width: cell + 0.5, height: cell + 0.5)
                    ctx.fill(Path(rect), with: .color(color))
                }
            }
        }
        .frame(width: size, height: size)
    }
}

/// Glyphes pixel-art réutilisables (7×7), pensés pour les boutons.
enum PixelGlyph {
    /// Coche (« appliquer »).
    static let check = [
        ".......",
        "......#",
        ".....##",
        "#...##.",
        "##.##..",
        ".###...",
        "..#....",
    ]
    /// Disquette (« sauvegarder »).
    static let floppy = [
        "#######",
        "#..##.#",
        "#..##.#",
        "#######",
        "#.....#",
        "#.###.#",
        "#######",
    ]
    /// Crayon (« éditer »).
    static let pencil = [
        ".....##",
        "....###",
        "...###.",
        "..###..",
        ".###...",
        "###....",
        "##.....",
    ]
    /// Poubelle (« supprimer »).
    static let trash = [
        "..###..",
        "#######",
        ".......",
        ".#####.",
        ".#.#.#.",
        ".#.#.#.",
        ".#####.",
    ]
    /// Plus (« ajouter »).
    static let plus = [
        "...#...",
        "...#...",
        "...#...",
        "#######",
        "...#...",
        "...#...",
        "...#...",
    ]
    /// Boutique (« marketplace »).
    static let store = [
        "#######",
        "#.#.#.#",
        "#######",
        "#.....#",
        "#.###.#",
        "#.###.#",
        "#.###.#",
    ]
    /// Dossier (« ouvrir le dossier »).
    static let folder = [
        "###....",
        "#######",
        "#.....#",
        "#.....#",
        "#.....#",
        "#.....#",
        "#######",
    ]
}

/// Label de bouton pixel : icône (largeur fixe) + texte, centré comme un bloc.
/// La largeur fixe de l'icône garantit l'alignement des trois boutons entre eux.
struct PixelButtonLabel: View {
    let glyph: [String]
    let title: String
    var body: some View {
        HStack(spacing: 8) {
            PixelIcon(rows: glyph, color: PixelTheme.text, size: 18)
                .frame(width: 20)
            Text(title)
                .font(PixelTheme.font(12))
                .tracking(1)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
    }
}

/// Petit titre de section façon retro.
struct PixelSectionHeader: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(PixelTheme.font(10))
            .foregroundStyle(PixelTheme.accent)
            .tracking(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 4)
    }
}

/// Échantillon d'aperçu d'un preset de chat.
struct PetSwatch: View {
    let preset: PetPreset
    let selected: Bool
    /// Frame du skin actif, passée explicitement : sans cette dépendance, SwiftUI ne
    /// voit changer ni `preset` ni `selected` au changement de skin et ne réévalue pas
    /// le `body` → l'aperçu garde la silhouette de l'ancien skin (lecture cachée de
    /// `SpriteStore.shared` non suivie par SwiftUI).
    var frame: [String] = []
    var body: some View {
        VStack(spacing: 4) {
            PixelSpriteView(
                frame: frame,
                palette: PixelPalette(
                    body: Color(hex: preset.body),
                    belly: Color(hex: preset.belly),
                    stripe: Color(hex: preset.stripe),
                    eye: Color(hex: preset.eye),
                    nose: Color(hex: preset.nose)
                )
            )
            .frame(width: 56, height: 56)
            Text(preset.name)
                .font(PixelTheme.font(9))
                .foregroundStyle(selected ? PixelTheme.text : PixelTheme.dim)
                .lineLimit(1)
        }
        .padding(6)
        .frame(maxWidth: .infinity)
        .background(selected ? PixelTheme.panelHi : PixelTheme.panel)
        .overlay(Rectangle().strokeBorder(selected ? PixelTheme.accent : PixelTheme.border,
                                          lineWidth: 2))
    }
}
