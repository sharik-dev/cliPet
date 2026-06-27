import AppKit
import Combine

/// Un élément d'historique du presse-papiers.
struct ClipItem: Identifiable, Equatable, Codable {
    let id: UUID
    let text: String
    let date: Date

    init(text: String, date: Date = Date()) {
        self.id = UUID()
        self.text = text
        self.date = date
    }

    /// Aperçu sur une ligne pour l'affichage.
    var preview: String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let oneLine = trimmed.replacingOccurrences(of: "\n", with: " ")
        return oneLine.count > 120 ? String(oneLine.prefix(120)) + "…" : oneLine
    }
}

/// Surveille NSPasteboard et garde un historique des textes copiés.
final class ClipboardManager: ObservableObject {
    @Published private(set) var history: [ClipItem] = []

    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private var timer: Timer?
    private weak var settings: PetSettings?

    /// Drapeau pour ignorer le changement qu'on provoque nous-mêmes en re-copiant.
    private var ignoreNextChange = false

    init(settings: PetSettings) {
        self.settings = settings
        self.lastChangeCount = pasteboard.changeCount
        loadPersisted()
    }

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: true) { [weak self] _ in
            self?.poll()
        }
        RunLoop.main.add(timer!, forMode: .common)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func poll() {
        let current = pasteboard.changeCount
        guard current != lastChangeCount else { return }
        lastChangeCount = current

        if ignoreNextChange {
            ignoreNextChange = false
            return
        }

        guard let str = pasteboard.string(forType: .string),
              !str.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        // Dédup : si déjà en tête, on ne fait rien.
        if history.first?.text == str { return }
        // Retire un doublon existant plus bas dans la liste.
        history.removeAll { $0.text == str }
        history.insert(ClipItem(text: str), at: 0)

        let cap = settings?.maxHistory ?? 50
        if history.count > cap { history = Array(history.prefix(cap)) }
        persist()
    }

    /// Re-copie un élément dans le presse-papiers (clic sur un item de l'historique).
    func copyToPasteboard(_ item: ClipItem) {
        ignoreNextChange = true
        pasteboard.clearContents()
        pasteboard.setString(item.text, forType: .string)
        lastChangeCount = pasteboard.changeCount
        // Remonte l'item en tête.
        history.removeAll { $0.id == item.id }
        history.insert(ClipItem(text: item.text), at: 0)
        persist()
    }

    func remove(_ item: ClipItem) {
        history.removeAll { $0.id == item.id }
        persist()
    }

    func clear() {
        history.removeAll()
        persist()
    }

    // MARK: - Persistance légère

    private static let key = "cliPet.clipboard.v1"

    private func persist() {
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: Self.key)
        }
    }

    private func loadPersisted() {
        guard let data = UserDefaults.standard.data(forKey: Self.key),
              let items = try? JSONDecoder().decode([ClipItem].self, from: data) else { return }
        history = items
    }
}
