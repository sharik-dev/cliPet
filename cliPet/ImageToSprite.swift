import SwiftUI
import AppKit

/// Convertit une image bitmap en grille de caractères de la palette du chat.
///
/// Principe :
///  1. L'image est ré-échantillonnée à la résolution de la grille (cols × rows).
///  2. Détection « intelligente » du fond : tout pixel transparent, ou connecté
///     au bord par une zone de couleur quasi-uniforme (proche de la couleur
///     dominante des bords), est considéré comme fond → caractère vide « . ».
///  3. Les pixels restants (avant-plan) sont quantifiés vers la couleur de
///     palette la plus proche, pour rester compatibles avec le recolorage.
enum ImageToSprite {

    private struct RGBA { var r, g, b, a: Double }

    /// Point d'entrée. Renvoie `nil` si l'image n'est pas lisible.
    static func convert(_ image: NSImage, cols: Int, rows: Int,
                        palette: PixelPalette, tolerance: Double) -> [[Character]]? {
        guard cols > 0, rows > 0,
              let samples = downsample(image, cols: cols, rows: rows) else { return nil }

        // 1. Fond : couleur de référence des bords + remplissage par diffusion.
        var isBg = Array(repeating: Array(repeating: false, count: cols), count: rows)
        let bg = borderColor(samples, cols: cols, rows: rows)
        floodFillBackground(samples, into: &isBg, cols: cols, rows: rows,
                            bgColor: bg, tolerance: tolerance)

        // 2. Couleurs de palette (hors vide), en RGB.
        let entries = paletteRGB(palette)

        // 3. Construction de la grille.
        var grid: [[Character]] = []
        for r in 0..<rows {
            var line: [Character] = []
            for c in 0..<cols {
                let p = samples[r][c]
                if isBg[r][c] || p.a < 0.5 {
                    line.append(".")
                } else {
                    line.append(nearestChar(to: p, entries: entries))
                }
            }
            grid.append(line)
        }
        return grid
    }

    // MARK: - Ré-échantillonnage

    /// Dessine l'image dans un contexte cols × rows (interpolation = moyenne des pixels).
    private static func downsample(_ image: NSImage, cols: Int, rows: Int) -> [[RGBA]]? {
        guard let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let space = CGColorSpace(name: CGColorSpace.sRGB) else { return nil }
        let bpr = cols * 4
        var buf = [UInt8](repeating: 0, count: bpr * rows)
        guard let ctx = buf.withUnsafeMutableBytes({ ptr in
            CGContext(data: ptr.baseAddress, width: cols, height: rows, bitsPerComponent: 8,
                      bytesPerRow: bpr, space: space,
                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        }) else { return nil }
        ctx.interpolationQuality = .high
        ctx.clear(CGRect(x: 0, y: 0, width: cols, height: rows))
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: cols, height: rows))

        var out: [[RGBA]] = []
        for r in 0..<rows {
            let srcRow = rows - 1 - r   // CGContext a son origine en bas
            var line: [RGBA] = []
            for c in 0..<cols {
                let i = srcRow * bpr + c * 4
                let a = Double(buf[i + 3]) / 255
                // RGB pré-multiplié → on dé-multiplie.
                let r0 = a > 0 ? Double(buf[i])     / 255 / a : 0
                let g0 = a > 0 ? Double(buf[i + 1]) / 255 / a : 0
                let b0 = a > 0 ? Double(buf[i + 2]) / 255 / a : 0
                line.append(RGBA(r: r0, g: g0, b: b0, a: a))
            }
            out.append(line)
        }
        return out
    }

    // MARK: - Détection du fond

    /// Couleur moyenne des cellules de bord opaques (= fond présumé).
    private static func borderColor(_ s: [[RGBA]], cols: Int, rows: Int) -> RGBA {
        var rs = 0.0, gs = 0.0, bs = 0.0, n = 0.0
        func add(_ p: RGBA) { if p.a >= 0.5 { rs += p.r; gs += p.g; bs += p.b; n += 1 } }
        for c in 0..<cols { add(s[0][c]); add(s[rows - 1][c]) }
        for r in 0..<rows { add(s[r][0]); add(s[r][cols - 1]) }
        guard n > 0 else { return RGBA(r: 0, g: 0, b: 0, a: 0) }
        return RGBA(r: rs / n, g: gs / n, b: bs / n, a: 1)
    }

    /// Remplissage par diffusion depuis les bords : marque comme fond toute
    /// cellule transparente ou proche de `bgColor`, connectée au bord.
    private static func floodFillBackground(_ s: [[RGBA]], into bg: inout [[Bool]],
            cols: Int, rows: Int, bgColor: RGBA, tolerance: Double) {
        var queue: [(Int, Int)] = []
        func consider(_ r: Int, _ c: Int) {
            guard r >= 0, r < rows, c >= 0, c < cols, !bg[r][c] else { return }
            let p = s[r][c]
            if p.a < 0.5 || dist(p, bgColor) <= tolerance {
                bg[r][c] = true
                queue.append((r, c))
            }
        }
        for c in 0..<cols { consider(0, c); consider(rows - 1, c) }
        for r in 0..<rows { consider(r, 0); consider(r, cols - 1) }
        var idx = 0
        while idx < queue.count {
            let (r, c) = queue[idx]; idx += 1
            consider(r - 1, c); consider(r + 1, c); consider(r, c - 1); consider(r, c + 1)
        }
    }

    // MARK: - Quantification vers la palette

    private static func paletteRGB(_ palette: PixelPalette) -> [(Character, RGBA)] {
        let chars: [Character] = ["X", "g", "d", "w", "o", "h", "p", "r"]
        return chars.compactMap { ch in
            guard let col = palette.color(for: ch) else { return nil }
            return (ch, rgba(of: col))
        }
    }

    private static func rgba(of color: Color) -> RGBA {
        let ns = NSColor(color).usingColorSpace(.sRGB) ?? .black
        return RGBA(r: Double(ns.redComponent), g: Double(ns.greenComponent),
                    b: Double(ns.blueComponent), a: 1)
    }

    private static func nearestChar(to p: RGBA, entries: [(Character, RGBA)]) -> Character {
        var best: Character = "g"
        var bestD = Double.infinity
        for (ch, col) in entries {
            let d = dist(p, col)
            if d < bestD { bestD = d; best = ch }
        }
        return best
    }

    /// Distance euclidienne RGB, ramenée sur 0…255 (tolérance lisible).
    private static func dist(_ a: RGBA, _ b: RGBA) -> Double {
        let dr = a.r - b.r, dg = a.g - b.g, db = a.b - b.b
        return (dr * dr + dg * dg + db * db).squareRoot() * 255
    }
}
