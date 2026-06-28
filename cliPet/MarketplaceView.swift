import SwiftUI
import AppKit

/// Onglet Marketplace du gestionnaire de skins : parcourir les pets de la
/// communauté, télécharger, partager le sien, signaler.
struct MarketplaceView: View {
    @EnvironmentObject var settings: PetSettings
    let l10n: L10n
    var onInstalled: () -> Void

    @State private var pets: [MarketPet] = []
    @State private var loading = false
    @State private var error: String?
    @State private var status: String?
    @State private var busyId: String?

    var body: some View {
        VStack(spacing: 0) {
            // Barre : partager mon pet + recharger
            HStack(spacing: 8) {
                Button(l10n.marketShare) { promptShare() }
                    .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent2.darkened(0.35)))
                Spacer()
                Button { Task { await load() } } label: { Image(systemName: "arrow.clockwise") }
                    .buttonStyle(.plain).foregroundStyle(PixelTheme.dim)
            }
            .padding(.horizontal, 14).padding(.vertical, 10)

            if let status {
                Text(status).font(PixelTheme.font(10)).foregroundStyle(PixelTheme.accent2)
                    .padding(.bottom, 6)
            }

            content
        }
        .onAppear { if pets.isEmpty { Task { await load() } } }
    }

    @ViewBuilder private var content: some View {
        if loading {
            Spacer(); ProgressView().controlSize(.small); Spacer()
        } else if let error {
            Spacer()
            VStack(spacing: 8) {
                Text(error).font(PixelTheme.font(11, .regular)).foregroundStyle(PixelTheme.dim)
                Button(l10n.marketRetry) { Task { await load() } }.buttonStyle(PixelButtonStyle())
            }
            Spacer()
        } else if pets.isEmpty {
            Spacer()
            Text(l10n.marketEmpty).font(PixelTheme.font(11, .regular)).foregroundStyle(PixelTheme.dim)
            Spacer()
        } else {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(pets) { pet in petCard(pet) }
                }
                .padding(14)
            }
        }
    }

    private func petCard(_ pet: MarketPet) -> some View {
        VStack(spacing: 6) {
            MarketSpriteView(frame: pet.preview.frame, colors: pet.preview.palette.customColors)
                .frame(height: 64)
                .frame(maxWidth: .infinity)
                .background(PixelTheme.bg)
            Text(pet.name).font(PixelTheme.font(11)).lineLimit(1)
            Text("@\(pet.author)").font(PixelTheme.font(8, .regular)).foregroundStyle(PixelTheme.dim)
            HStack(spacing: 4) {
                Image(systemName: "arrow.down.circle").font(.system(size: 9))
                Text("\(pet.downloads)").font(PixelTheme.font(9, .regular))
            }.foregroundStyle(PixelTheme.dim)
            Button(busyId == pet.id ? l10n.marketWorking : l10n.marketDownload) {
                Task { await download(pet) }
            }
            .buttonStyle(PixelButtonStyle())
            .disabled(busyId != nil)
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(PixelTheme.panel)
        .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 2))
        .contextMenu {
            Button(l10n.marketReport, role: .destructive) { Task { await report(pet) } }
        }
    }

    // MARK: - Actions

    private func load() async {
        loading = true; error = nil
        do { pets = try await MarketplaceClient.list() }
        catch { self.error = (error as? LocalizedError)?.errorDescription ?? l10n.marketError }
        loading = false
    }

    private func download(_ pet: MarketPet) async {
        busyId = pet.id; defer { busyId = nil }
        do {
            let full = try await MarketplaceClient.fetch(pet.id)
            MarketBridge.install(full)
            await MarketplaceClient.markDownloaded(pet.id)
            onInstalled()
            flash(l10n.marketDownloaded)
        } catch {
            flash((error as? LocalizedError)?.errorDescription ?? l10n.marketError)
        }
    }

    private func report(_ pet: MarketPet) async {
        do { try await MarketplaceClient.report(pet.id, reason: ""); flash(l10n.marketReported) }
        catch { flash((error as? LocalizedError)?.errorDescription ?? l10n.marketError) }
    }

    private func promptShare() {
        let alert = NSAlert()
        alert.messageText = l10n.marketShareTitle
        alert.informativeText = l10n.marketShareBody
        alert.addButton(withTitle: l10n.marketShare)
        alert.addButton(withTitle: l10n.cancel)
        let tf = NSTextField(frame: NSRect(x: 0, y: 0, width: 260, height: 24))
        tf.stringValue = SkinCatalog.skin(SpriteStore.shared.activeSkinId).name
        alert.accessoryView = tf
        alert.window.initialFirstResponder = tf
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        let name = tf.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }

        let pet = MarketBridge.currentPet(settings: settings)
        let author = (Host.current().localizedName ?? "anon")
        Task {
            do {
                _ = try await MarketplaceClient.publish(name: name, frames: pet.frames,
                                                        palette: pet.palette, author: author)
                flash(l10n.marketShared)
                await load()
            } catch {
                flash((error as? LocalizedError)?.errorDescription ?? l10n.marketError)
            }
        }
    }

    private func flash(_ msg: String) {
        status = msg
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            if status == msg { status = nil }
        }
    }
}

/// Rendu pixel d'une frame avec une palette char→hex (couleurs cuites).
struct MarketSpriteView: View {
    let frame: [String]
    let colors: [String: String]

    // Repli sur les couleurs de base (miroir de PixelPalette) si non cuites.
    private static let base: [Character: String] = [
        "g": "#969BA1", "w": "#F5F5F5", "d": "#3C4045", "o": "#141414",
        "p": "#CE2828", "X": "#17191C", "h": "#FFFFFF", "r": "#F2A24C",
    ]

    private func color(_ c: Character) -> Color? {
        if c == "." || c == " " { return nil }
        if let hex = colors[String(c)] { return Color(hex: hex) }
        if let hex = Self.base[c] { return Color(hex: hex) }
        return Color.gray
    }

    var body: some View {
        Canvas { ctx, size in
            let h = frame.count
            let w = frame.map { $0.count }.max() ?? 0
            guard h > 0, w > 0 else { return }
            let cell = min(size.width / CGFloat(w), size.height / CGFloat(h))
            let ox = (size.width - cell * CGFloat(w)) / 2
            let oy = (size.height - cell * CGFloat(h)) / 2
            for (y, row) in frame.enumerated() {
                for (x, c) in row.enumerated() {
                    guard let col = color(c) else { continue }
                    ctx.fill(Path(CGRect(x: ox + CGFloat(x) * cell, y: oy + CGFloat(y) * cell,
                                         width: cell, height: cell)), with: .color(col))
                }
            }
        }
    }
}
