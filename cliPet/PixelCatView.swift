import SwiftUI

/// Palette partagée char -> couleur, recolorée via les réglages.
struct PixelPalette {
    let body, belly, stripe, eye, nose: Color
    /// Surcharges utilisateur (char -> hex), prioritaires sur le mapping par défaut.
    /// Doit être passée explicitement : on ne lit PAS `SpriteStore.shared` dans le
    /// rendu, sinon (1) la palette du skin actif déteindrait sur l'aperçu des autres
    /// skins, et (2) le `Canvas` ne se redessinerait pas au changement (dépendance
    /// cachée non suivie par SwiftUI → aperçus qui « traînent »).
    var customColors: [String: String] = [:]

    func color(for ch: Character) -> Color? {
        if ch == "." { return nil }
        // Couleur personnalisée (palette utilisateur) prioritaire.
        if let hex = customColors[String(ch)] { return Color(hex: hex) }
        switch ch {
        case ".":  return nil
        case "X":  return stripe.darkened(0.6)   // contour
        case "g":  return body
        case "d":  return stripe
        case "w":  return belly
        case "o":  return eye
        case "h":  return .white                  // reflet
        case "p":  return nose                    // oreille (rouge)
        case "r":  return Color(hex: "#F2A24C")   // cœur orange de l'oreille
        default:   return nil
        }
    }
}

/// Rendu générique d'une frame pixel-art (largeur/hauteur déduites des lignes).
struct PixelSpriteView: View {
    let frame: [String]
    let palette: PixelPalette
    var flipped: Bool = false

    var body: some View {
        Canvas { ctx, size in
            let rows = frame.count
            guard rows > 0 else { return }
            let cols = frame[0].count
            let cell = size.width / CGFloat(cols)

            for (gy, row) in frame.enumerated() {
                let chars = Array(row)
                for gx in 0..<cols {
                    guard gx < chars.count else { continue }
                    let ch = flipped ? chars[cols - 1 - gx] : chars[gx]
                    guard let color = palette.color(for: ch) else { continue }
                    let rect = CGRect(x: CGFloat(gx) * cell, y: CGFloat(gy) * cell,
                                      width: cell + 0.5, height: cell + 0.5)
                    ctx.fill(Path(rect), with: .color(color))
                }
            }
        }
    }
}

/// Le chat : choisit la frame selon l'état + le tick, depuis le SpriteStore.
struct PixelCatView: View {
    let state: PetState
    let facing: Facing
    let tick: Int
    let bodyColor: Color
    let bellyColor: Color
    let stripeColor: Color
    let eyeColor: Color
    let noseColor: Color

    var body: some View {
        PixelSpriteView(
            frame: SpriteStore.shared.frame(Self.frameName(for: state, tick: tick)),
            palette: PixelPalette(body: bodyColor, belly: bellyColor,
                                  stripe: stripeColor, eye: eyeColor, nose: noseColor,
                                  customColors: SpriteStore.shared.customColors),
            flipped: facing == .left
        )
    }

    static func frameName(for state: PetState, tick: Int) -> String {
        switch state {
        case .walk, .pounce, .chaseToy, .travel:
            return "walk\((tick / 6) % 4 + 1)"
        case .run, .chase:
            return "walk\((tick / 3) % 4 + 1)"
        case .sit:
            return "sit"
        case .sleep:
            return "sleep"
        case .play:
            return "play"
        case .held:
            // gigotement pendant qu'on le tient
            return (tick / 5) % 2 == 0 ? "held1" : "held2"
        case .falling:
            return "fall"
        case .land:
            return "land"
        case .idle:
            // Cycle d'attente : queue qui ondule + oreille qui frémit (idle1 domine).
            let seq = ["idle1", "idle2", "idle1", "idle3", "idle1", "idle4"]
            return seq[(tick / 18) % seq.count]
        }
    }
}

/// La pelote de laine (jouet) : cycle de roulement.
struct ToyView: View {
    let tick: Int
    let rolling: Bool
    let bodyColor: Color
    let bellyColor: Color
    let stripeColor: Color
    let eyeColor: Color
    let noseColor: Color

    var body: some View {
        let idx = rolling ? (tick / 4) % 4 + 1 : 1
        return PixelSpriteView(
            frame: SpriteStore.shared.frame("yarn\(idx)"),
            palette: PixelPalette(body: bodyColor, belly: bellyColor,
                                  stripe: stripeColor, eye: eyeColor, nose: noseColor,
                                  customColors: SpriteStore.shared.customColors)
        )
    }
}

/// La niche (maison du pet) : décor affiché à droite pendant que le pet se cache /
/// réapparaît. Rendue depuis le `SpriteStore` (frame « niche ») avec la palette
/// standard du pet → entièrement éditable dans l'éditeur de sprite, par skin.
struct NicheView: View {
    let bodyColor: Color
    let bellyColor: Color
    let stripeColor: Color
    let eyeColor: Color
    let noseColor: Color

    var body: some View {
        PixelSpriteView(
            frame: SpriteStore.shared.frame("niche"),
            palette: PixelPalette(body: bodyColor, belly: bellyColor,
                                  stripe: stripeColor, eye: eyeColor, nose: noseColor,
                                  customColors: SpriteStore.shared.customColors)
        )
    }
}

extension Color {
    /// Assombrit la couleur (0 = inchangé, 1 = noir).
    func darkened(_ amount: Double) -> Color {
        let ns = NSColor(self).usingColorSpace(.sRGB) ?? .black
        let f = 1 - amount
        return Color(.sRGB, red: Double(ns.redComponent) * f,
                     green: Double(ns.greenComponent) * f,
                     blue: Double(ns.blueComponent) * f,
                     opacity: Double(ns.alphaComponent))
    }

    func lightened(_ amount: Double) -> Color {
        let ns = NSColor(self).usingColorSpace(.sRGB) ?? .white
        return Color(.sRGB,
                     red: Double(ns.redComponent) + (1 - Double(ns.redComponent)) * amount,
                     green: Double(ns.greenComponent) + (1 - Double(ns.greenComponent)) * amount,
                     blue: Double(ns.blueComponent) + (1 - Double(ns.blueComponent)) * amount,
                     opacity: Double(ns.alphaComponent))
    }
}
