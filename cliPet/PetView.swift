import SwiftUI
import AppKit

/// Vue affichée dans la fenêtre flottante du pet.
/// Clic = ouvre/ferme l'historique du presse-papiers. Glisser = soulève le chat.
struct PetView: View {
    @ObservedObject var engine: PetEngine
    @ObservedObject var settings: PetSettings
    let onTap: () -> Void

    // Décalage entre le curseur et l'origine de la fenêtre au moment de la prise.
    @State private var grabOffset: CGSize? = nil

    var body: some View {
        PixelCatView(
            state: engine.state,
            facing: engine.facing,
            tick: engine.animTick,
            bodyColor: settings.bodyColor,
            bellyColor: settings.bellyColor,
            stripeColor: settings.stripeColor,
            eyeColor: settings.eyeColor,
            noseColor: settings.noseColor
        )
        .frame(width: engine.spriteSize, height: engine.spriteSize)
        .contentShape(Rectangle())
        .onHover { inside in
            if inside { NSCursor.openHand.push() } else { NSCursor.pop() }
        }
        .gesture(
            // On suit la position réelle du curseur (coordonnées écran), pas la
            // translation : la fenêtre bouge pendant le drag, ce qui rendrait la
            // translation instable.
            DragGesture(minimumDistance: 4, coordinateSpace: .global)
                .onChanged { _ in
                    let mouse = NSEvent.mouseLocation
                    if grabOffset == nil {
                        grabOffset = CGSize(width: mouse.x - engine.position.x,
                                            height: mouse.y - engine.position.y)
                        engine.beginDrag()
                    }
                    engine.setDraggedOrigin(origin(mouse))
                }
                .onEnded { _ in
                    engine.endDrag(at: origin(NSEvent.mouseLocation))
                    grabOffset = nil
                }
        )
        .simultaneousGesture(TapGesture().onEnded { onTap() })
    }

    private func origin(_ mouse: NSPoint) -> CGPoint {
        let off = grabOffset ?? .zero
        return CGPoint(x: mouse.x - off.width, y: mouse.y - off.height)
    }
}
