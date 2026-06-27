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
    var body: some View {
        VStack(spacing: 4) {
            PixelCatView(
                state: .idle, facing: .right, tick: 0,
                bodyColor: Color(hex: preset.body),
                bellyColor: Color(hex: preset.belly),
                stripeColor: Color(hex: preset.stripe),
                eyeColor: Color(hex: preset.eye),
                noseColor: Color(hex: preset.nose)
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
