import AppKit
import Combine

/// États possibles du chat.
enum PetState: Equatable {
    case idle      // immobile, cligne des yeux
    case walk      // se balade le long du sol
    case run       // court
    case sit       // assis
    case sleep     // dort
    case chase     // poursuit le curseur
    case pounce    // bond
    case play      // assis, joue avec la pelote (pose portrait)
    case chaseToy  // court après la pelote qui roule
    case held      // soulevé par l'utilisateur
    case falling   // relâché, retombe vers le sol
    case land      // atterrissage (impact bref)
    case travel    // marche dirigée vers une cible précise (niche), callback à l'arrivée
}

enum Facing { case left, right }

/// Cerveau du pet : marche le long du bas de l'écran (~30 fps).
/// `position` = origine bas-gauche de la fenêtre, en coordonnées écran AppKit.
final class PetEngine: ObservableObject {

    // Vue chat
    @Published private(set) var state: PetState = .idle
    @Published private(set) var facing: Facing = .right
    @Published private(set) var animTick: Int = 0
    @Published private(set) var position: CGPoint = .zero
    @Published private(set) var spriteSize: CGFloat = 72
    /// Largeur de la niche (maison) ; la hauteur en découle via le ratio du sprite.
    @Published private(set) var nicheSize: CGFloat = 144

    // Jouet (pelote)
    @Published private(set) var toyVisible = false
    @Published private(set) var toyRolling = false
    @Published private(set) var toyPosition: CGPoint = .zero
    @Published private(set) var toySize: CGFloat = 56

    var isPaused = false
    /// Gèle entièrement le pet (déplacement ET animation du sprite). Utilisé quand
    /// le panneau presse-papiers est ouvert : le chat doit rester parfaitement immobile.
    private(set) var isFrozen = false

    private weak var settings: PetSettings?
    private var timer: Timer?
    private let fps: Double = 30
    private let basePixelScale: CGFloat = 4

    private var targetX: CGFloat?
    private var arrivalCallback: (() -> Void)?    // appelé à l'arrivée d'un `.travel`
    private var stateEnd: TimeInterval = 0
    private var hop: CGFloat = 0
    private var pounceStart: TimeInterval = 0
    private var toyVel: CGFloat = 0
    private var batsLeft = 0
    private var vy: CGFloat = 0                 // vitesse verticale (chute)
    private let gravity: CGFloat = 1.7          // px / tick²

    // Sol dynamique : remonte au-dessus du Dock s'il est visible.
    private var currentFloor: CGFloat = 0
    private var lastDockCheck = -100
    private var cachedDockTop: CGFloat? = nil

    init(settings: PetSettings) {
        self.settings = settings
        recomputeSize()
        let area = Self.visibleFrame()
        currentFloor = area.minY
        position = CGPoint(x: area.midX, y: area.minY)
    }

    func start() {
        recomputeSize()
        scheduleNext(.idle, duration: 1.0)
        timer?.invalidate()
        let t = Timer(timeInterval: 1.0 / fps, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() { timer?.invalidate(); timer = nil }

    func recomputeSize() {
        let scale = settings?.scale ?? 1.0
        spriteSize = CGFloat(SpriteStore.shared.catSize) * basePixelScale * scale
        toySize = CGFloat(SpriteStore.shared.yarnSize) * basePixelScale * scale * 0.85
        // Niche rendue à 2× l'échelle pixel pour rester comparable à la taille du pet.
        nicheSize = CGFloat(CatSprites.nicheCols) * basePixelScale * 2 * scale
    }

    // MARK: - Interaction

    func beginDrag() {
        isPaused = true       // on suspend l'IA ; la position suit le curseur
        state = .held
        vy = 0
        toyVisible = false
    }

    func endDrag(at origin: CGPoint) {
        let area = Self.visibleFrame()
        let now = Date().timeIntervalSinceReferenceDate
        let ground = groundY(area: area)
        position = CGPoint(x: clampX(origin.x, area: area), y: max(origin.y, ground))
        isPaused = false
        vy = 0
        if position.y <= ground + 1 {
            // déjà au sol → petit impact direct
            position.y = ground
            state = .land; stateEnd = now + 0.18
        } else {
            state = .falling; stateEnd = now + 6   // la chute se termine à l'atterrissage
        }
    }

    func setDraggedOrigin(_ origin: CGPoint) { position = origin }

    /// Immobilise totalement le pet : pose neutre, plus aucun déplacement ni animation.
    func freeze() {
        isFrozen = true
        isPaused = true
        state = .idle
        toyVisible = false
    }

    func unfreeze() {
        isFrozen = false
        isPaused = false
    }

    // MARK: - Déplacement dirigé (vers la niche)

    /// Téléporte le pet à une abscisse donnée, posé au sol. Sert à le faire
    /// réapparaître pile devant la porte de la niche avant de l'en faire sortir.
    func placeAt(x: CGFloat) {
        let area = Self.visibleFrame()
        isFrozen = false
        isPaused = false
        position = CGPoint(x: clampX(x, area: area), y: groundY(area: area))
    }

    /// Fait marcher le pet jusqu'à `x` puis appelle `then` à l'arrivée.
    /// Utilisé pour l'entrée / la sortie de la niche.
    func walk(to x: CGFloat, then: @escaping () -> Void) {
        let area = Self.visibleFrame()
        isFrozen = false
        isPaused = false
        arrivalCallback = then
        let tx = clampX(x, area: area)
        targetX = tx
        facing = tx >= position.x ? .right : .left
        scheduleNext(.travel, duration: 12)   // garde-fou si la cible n'est jamais atteinte
    }

    /// Reprend le comportement autonome normal (après une sortie de niche).
    func resumeNormal() {
        arrivalCallback = nil
        isPaused = false
        isFrozen = false
        scheduleNext(.idle, duration: 0.5)
    }

    // MARK: - Boucle

    private func tick() {
        // Gelé (presse-papiers ouvert) : on n'avance même pas l'animation du sprite,
        // le chat reste parfaitement immobile. Le drag (`held`) reste animé, lui.
        guard !isFrozen else { return }
        animTick &+= 1
        guard !isPaused else { return }
        let now = Date().timeIntervalSinceReferenceDate
        let area = Self.visibleFrame()
        let floorY = groundY(area: area)
        let prevX = position.x

        switch state {
        case .idle, .sit, .sleep:
            position.y = floorY
            if now >= stateEnd { pickNextBehavior(area: area) }

        case .walk, .run:
            stepTowardX(targetX, speed: state == .run ? runSpeed : walkSpeed, area: area)
            // Petit rebond pour donner vie à la marche (le sprite n'a pas de cycle de pattes).
            let amp: CGFloat = state == .run ? 7 : 4
            position.y = floorY + abs(sin(Double(animTick) * 0.5)) * amp
            if reachedX() || now >= stateEnd { pickNextBehavior(area: area) }

        case .chase:
            stepTowardX(NSEvent.mouseLocation.x - spriteSize / 2, speed: runSpeed, area: area)
            position.y = floorY
            if now >= stateEnd { pickNextBehavior(area: area) }

        case .pounce:
            let p = min(1, (now - pounceStart) / 0.5)
            hop = CGFloat(sin(p * .pi)) * 70
            stepTowardX(targetX, speed: runSpeed * 1.3, area: area)
            position.y = floorY + hop
            if p >= 1 { hop = 0; pickNextBehavior(area: area) }

        case .play:
            position.y = floorY
            updatePlayToy(floorY: floorY, now: now)
            if now >= stateEnd { pickNextBehavior(area: area) }

        case .chaseToy:
            updateChaseToy(area: area, floorY: floorY)
            position.y = floorY
            if now >= stateEnd { pickNextBehavior(area: area) }

        case .falling:
            vy += gravity
            position.y -= vy
            position.x = clampX(position.x, area: area)
            if position.y <= floorY {        // touche le sol → atterrissage
                position.y = floorY
                vy = 0
                state = .land
                stateEnd = now + 0.20
            }

        case .land:
            position.y = floorY
            if now >= stateEnd {
                // Après avoir été reposé, le chat est attiré par la souris quelques secondes.
                scheduleNext(.chase, duration: .random(in: 3.0...5.0))
            }

        case .held:
            break   // la position suit le curseur (setDraggedOrigin) ; animTick anime le gigotement

        case .travel:
            stepTowardX(targetX, speed: runSpeed * 0.6, area: area)
            position.y = floorY + abs(sin(Double(animTick) * 0.5)) * 4
            if reachedX() || now >= stateEnd {
                let cb = arrivalCallback
                arrivalCallback = nil
                state = .idle
                stateEnd = now + 0.3
                cb?()
            }
        }

        // Le chat regarde toujours dans le sens de son déplacement réel
        // (jamais de marche arrière).
        let movedX = position.x - prevX
        if abs(movedX) > 0.3 { facing = movedX > 0 ? .right : .left }
    }

    // MARK: - Jouet

    private func updatePlayToy(floorY: CGFloat, now: TimeInterval) {
        // La pelote rebondit doucement devant le chat pendant qu'il la tape.
        let bob = abs(sin(now * 6)) * 6
        toyPosition.y = floorY + bob
        toyRolling = false
    }

    private func updateChaseToy(area: CGRect, floorY: CGFloat) {
        // Roule + friction + rebond sur les bords.
        toyPosition.x += toyVel
        toyVel *= 0.95
        if toyPosition.x <= area.minX {
            toyPosition.x = area.minX; toyVel = abs(toyVel) * 0.6
        } else if toyPosition.x >= area.maxX - toySize {
            toyPosition.x = area.maxX - toySize; toyVel = -abs(toyVel) * 0.6
        }
        toyPosition.y = floorY
        toyRolling = abs(toyVel) > 0.4

        // Le chat court vers la pelote.
        let tx = toyPosition.x + toySize / 2 - spriteSize / 2
        stepTowardX(tx, speed: runSpeed, area: area)

        // Assez proche → coup de patte.
        let catCenter = position.x + spriteSize / 2
        let toyCenter = toyPosition.x + toySize / 2
        if abs(catCenter - toyCenter) < spriteSize * 0.45, abs(toyVel) < 1.5, batsLeft > 0 {
            toyVel = CGFloat.random(in: 6...11) * (Bool.random() ? 1 : -1)
            batsLeft -= 1
        }
        if batsLeft <= 0 && abs(toyVel) < 0.4 { scheduleNext(.idle, duration: 0.6); hideToy() }
    }

    private func hideToy() { toyVisible = false; toyRolling = false }

    // MARK: - Déplacement horizontal

    private var walkSpeed: CGFloat { 55 * CGFloat(settings?.speed ?? 1) / CGFloat(fps) }
    private var runSpeed: CGFloat { 280 * CGFloat(settings?.speed ?? 1) / CGFloat(fps) }

    private func stepTowardX(_ tx: CGFloat?, speed: CGFloat, area: CGRect) {
        guard let tx else { return }
        let dx = tx - position.x
        if abs(dx) <= speed {
            position.x = clampX(tx, area: area)
        } else {
            position.x = clampX(position.x + (dx > 0 ? speed : -speed), area: area)
            facing = dx > 0 ? .right : .left
        }
    }

    private func reachedX() -> Bool {
        guard let tx = targetX else { return true }
        return abs(tx - position.x) < 2
    }

    private func clampX(_ x: CGFloat, area: CGRect) -> CGFloat {
        min(max(x, area.minX), area.maxX - spriteSize)
    }

    // MARK: - Comportements

    private func pickNextBehavior(area: CGRect) {
        hideToy()
        let mischief = settings?.mischiefEnabled ?? true
        let chase = settings?.chaseCursor ?? true
        let toy = settings?.toyEnabled ?? true

        // Balade, repos et (si activé) jeux avec la pelote.
        var bag: [PetState] = [.idle, .idle, .sit, .walk, .walk, .walk]
        if toy { bag += [.play, .play, .chaseToy] }
        if mischief { bag += [.run, .pounce, .sleep]; if toy { bag.append(.chaseToy) } }
        if mischief && chase { bag += [.chase] }
        let next = bag.randomElement() ?? .idle

        switch next {
        case .idle:  scheduleNext(.idle, duration: .random(in: 1.2...3.0))
        case .sit:   scheduleNext(.sit, duration: .random(in: 2.0...4.5))
        case .sleep: scheduleNext(.sleep, duration: .random(in: 4.0...9.0))
        case .walk:
            targetX = .random(in: area.minX...(area.maxX - spriteSize))
            scheduleNext(.walk, duration: 8.0)
        case .run:
            targetX = .random(in: area.minX...(area.maxX - spriteSize))
            scheduleNext(.run, duration: 4.0)
        case .chase: scheduleNext(.chase, duration: .random(in: 2.5...4.5))
        case .pounce:
            pounceStart = Date().timeIntervalSinceReferenceDate
            let jump = CGFloat.random(in: 90...220) * (Bool.random() ? 1 : -1)
            targetX = clampX(position.x + jump, area: area)
            facing = jump > 0 ? .right : .left
            scheduleNext(.pounce, duration: 0.5)
        case .play:
            setupPlay(area: area)
            scheduleNext(.play, duration: .random(in: 3.5...6.5))
        case .chaseToy:
            setupChaseToy(area: area)
            scheduleNext(.chaseToy, duration: .random(in: 5.0...8.0))
        case .held, .falling, .land, .travel: scheduleNext(.idle, duration: 1.0)
        }
    }

    private func setupPlay(area: CGRect) {
        toyVisible = true
        toyRolling = false
        // Pelote posée juste devant le chat.
        let rightSpot = position.x + spriteSize * 0.72
        if rightSpot + toySize <= area.maxX {
            toyPosition = CGPoint(x: rightSpot, y: area.minY); facing = .right
        } else {
            toyPosition = CGPoint(x: position.x - toySize * 0.8, y: area.minY); facing = .left
        }
    }

    private func setupChaseToy(area: CGRect) {
        toyVisible = true
        batsLeft = Int.random(in: 2...4)
        // La pelote part d'un point proche et roule.
        let startX = clampX(position.x + CGFloat.random(in: -200...200), area: area)
        toyPosition = CGPoint(x: startX, y: area.minY)
        toyVel = CGFloat.random(in: 6...11) * (Bool.random() ? 1 : -1)
    }

    private func scheduleNext(_ s: PetState, duration: TimeInterval) {
        state = s
        stateEnd = Date().timeIntervalSinceReferenceDate + duration
    }

    static func visibleFrame() -> CGRect {
        NSScreen.main?.visibleFrame ?? CGRect(x: 0, y: 0, width: 1440, height: 900)
    }

    // MARK: - Sol dynamique (au-dessus du Dock)

    /// Hauteur du sol : `visibleFrame.minY`, relevée au bord supérieur du Dock
    /// quand celui-ci est visible en bas (cas du Dock en auto-masquage révélé).
    /// Lissé pour que le chat « monte » avec le Dock plutôt que de sauter.
    private func groundY(area: CGRect) -> CGFloat {
        if animTick &- lastDockCheck >= 5 {
            cachedDockTop = Self.dockTopEdge()
            lastDockCheck = animTick
        }
        var target = area.minY
        if let d = cachedDockTop, d > target { target = d }
        let dy = target - currentFloor
        if abs(dy) < 0.75 { currentFloor = target } else { currentFloor += dy * 0.3 }
        return currentFloor
    }

    /// Bord supérieur du Dock en coordonnées Cocoa s'il est visible en bas, sinon nil.
    static func dockTopEdge() -> CGFloat? {
        guard let screen = NSScreen.main else { return nil }
        let H = screen.frame.height
        let Wd = screen.frame.width
        guard let infos = CGWindowListCopyWindowInfo(
            [.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] else { return nil }

        var best: CGFloat? = nil
        for w in infos {
            guard (w[kCGWindowOwnerName as String] as? String) == "Dock",
                  let bdAny = w[kCGWindowBounds as String],
                  let rect = CGRect(dictionaryRepresentation: bdAny as! CFDictionary)
            else { continue }
            // Bande horizontale collée en bas (on ignore un Dock latéral).
            guard rect.width >= Wd * 0.3, rect.height <= H * 0.4 else { continue }
            guard abs(rect.maxY - H) < 4 else { continue }   // bas du Dock = bas de l'écran
            let topCocoa = H - rect.minY                      // CG (origine haut) -> Cocoa
            if topCocoa > 1 { best = max(best ?? 0, topCocoa) }
        }
        return best
    }
}
