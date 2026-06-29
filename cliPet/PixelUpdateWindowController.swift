import SwiftUI
import AppKit
import Sparkle

// MARK: - Window Controller

final class PixelUpdateWindowController: NSWindowController {

    init(state: PixelUpdateState) {
        let hostView = PixelUpdateView(state: state)
        let host = NSHostingController(rootView: hostView)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 440),
            styleMask: [.titled, .closable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = NSColor(PixelTheme.bg)
        panel.level = .floating
        panel.center()
        panel.contentViewController = host

        super.init(window: panel)
    }

    required init?(coder: NSCoder) { fatalError() }
}

// MARK: - Root View

struct PixelUpdateView: View {
    @ObservedObject var state: PixelUpdateState

    var body: some View {
        ZStack {
            PixelTheme.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                // Decorative top strip
                HStack(spacing: 4) {
                    ForEach(0..<18, id: \.self) { i in
                        Rectangle()
                            .fill(i % 2 == 0 ? PixelTheme.accent : PixelTheme.panel)
                            .frame(height: 4)
                    }
                }

                Spacer().frame(height: 24)

                // Pet sprite animé
                PixelCatView(
                    state: .idle,
                    facing: .right,
                    tick: state.tick,
                    bodyColor: PetSettings().bodyColor,
                    bellyColor: PetSettings().bellyColor,
                    stripeColor: PetSettings().stripeColor,
                    eyeColor: PetSettings().eyeColor,
                    noseColor: PetSettings().noseColor
                )
                .frame(width: 72, height: 72)

                Spacer().frame(height: 20)

                // Phase content
                Group {
                    switch state.phase {
                    case .checking:
                        checkingContent
                    case .found(let item, _, let reply):
                        foundContent(item: item, reply: reply)
                    case .notFound:
                        notFoundContent
                    case .downloading(let total, let received):
                        progressContent(
                            label: "DOWNLOADING",
                            fraction: total > 0 ? Double(received) / Double(total) : nil
                        )
                    case .extracting(let p):
                        progressContent(label: "EXTRACTING", fraction: p)
                    case .readyToInstall(let reply):
                        readyContent(reply: reply)
                    case .installing:
                        progressContent(label: "INSTALLING", fraction: nil)
                    case .done:
                        doneContent
                    case .error(let msg):
                        errorContent(msg: msg)
                    }
                }
                .padding(.horizontal, 24)

                Spacer()

                // Bottom strip
                HStack(spacing: 4) {
                    ForEach(0..<18, id: \.self) { i in
                        Rectangle()
                            .fill(i % 2 == 0 ? PixelTheme.panel : PixelTheme.accent)
                            .frame(height: 4)
                    }
                }
            }
        }
        .frame(width: 360, height: 440)
    }

    // MARK: - Checking

    var checkingContent: some View {
        VStack(spacing: 12) {
            Text("CHECKING FOR UPDATES")
                .font(PixelTheme.font(11))
                .foregroundStyle(PixelTheme.accent)
                .tracking(1)

            PixelProgressBar(fraction: nil)
                .frame(height: 12)
        }
    }

    // MARK: - Found

    func foundContent(item: SUAppcastItem, reply: @escaping (SPUUserUpdateChoice) -> Void) -> some View {
        let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        let next = item.displayVersionString

        return VStack(spacing: 16) {
            Text("UPDATE AVAILABLE")
                .font(PixelTheme.font(13))
                .foregroundStyle(PixelTheme.text)
                .tracking(2)

            // Version badge
            HStack(spacing: 10) {
                versionBadge(current, color: PixelTheme.dim)
                PixelIcon(rows: [
                    ".......",
                    "...#...",
                    "....##.",
                    "#######",
                    "....##.",
                    "...#...",
                    ".......",
                ], color: PixelTheme.accent2, size: 16)
                versionBadge(next, color: PixelTheme.accent2)
            }

            if let notes = item.itemDescription, !notes.isEmpty {
                let cleaned = notes
                    .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                    .prefix(120)
                Text(String(cleaned))
                    .font(PixelTheme.font(10, .regular))
                    .foregroundStyle(PixelTheme.dim)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }

            Spacer().frame(height: 4)

            // Buttons
            VStack(spacing: 8) {
                Button(action: { reply(.install) }) {
                    Text("INSTALL NOW")
                        .font(PixelTheme.font(12))
                        .foregroundStyle(PixelTheme.bg)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(PixelTheme.accent2)
                        .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 2))
                }
                .buttonStyle(.plain)

                Button(action: { reply(.dismiss) }) {
                    Text("REMIND ME LATER")
                        .font(PixelTheme.font(11))
                        .foregroundStyle(PixelTheme.dim)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(PixelTheme.panel)
                        .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 2))
                }
                .buttonStyle(.plain)

                Button(action: { reply(.skip) }) {
                    Text("Skip this version")
                        .font(PixelTheme.font(9, .regular))
                        .foregroundStyle(PixelTheme.dim.opacity(0.6))
                }
                .buttonStyle(.plain)
            }
        }
    }

    func versionBadge(_ v: String, color: Color) -> some View {
        Text("v\(v)")
            .font(PixelTheme.font(11))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(PixelTheme.panel)
            .overlay(Rectangle().strokeBorder(color.opacity(0.5), lineWidth: 1))
    }

    // MARK: - Not found

    var notFoundContent: some View {
        VStack(spacing: 10) {
            Text("YOU'RE UP TO DATE")
                .font(PixelTheme.font(12))
                .foregroundStyle(PixelTheme.accent2)
                .tracking(1)
            Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                .font(PixelTheme.font(11, .regular))
                .foregroundStyle(PixelTheme.dim)
        }
    }

    // MARK: - Progress

    func progressContent(label: String, fraction: Double?) -> some View {
        VStack(spacing: 12) {
            Text(label)
                .font(PixelTheme.font(11))
                .foregroundStyle(PixelTheme.accent)
                .tracking(1)

            PixelProgressBar(fraction: fraction)
                .frame(height: 12)

            if let f = fraction {
                Text("\(Int(f * 100))%")
                    .font(PixelTheme.font(10, .regular))
                    .foregroundStyle(PixelTheme.dim)
            }
        }
    }

    // MARK: - Ready to install

    func readyContent(reply: @escaping (SPUUserUpdateChoice) -> Void) -> some View {
        VStack(spacing: 14) {
            Text("READY TO INSTALL")
                .font(PixelTheme.font(12))
                .foregroundStyle(PixelTheme.text)
                .tracking(1)

            Button(action: { reply(.install) }) {
                Text("INSTALL & RELAUNCH")
                    .font(PixelTheme.font(12))
                    .foregroundStyle(PixelTheme.bg)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 9)
                    .background(PixelTheme.accent2)
                    .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 2))
            }
            .buttonStyle(.plain)

            Button(action: { reply(.dismiss) }) {
                Text("LATER")
                    .font(PixelTheme.font(11))
                    .foregroundStyle(PixelTheme.dim)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 7)
                    .background(PixelTheme.panel)
                    .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 2))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Installing

    var installingContent: some View {
        VStack(spacing: 10) {
            Text("INSTALLING…")
                .font(PixelTheme.font(12))
                .foregroundStyle(PixelTheme.accent)
                .tracking(1)
            PixelProgressBar(fraction: nil)
                .frame(height: 12)
        }
    }

    // MARK: - Done

    var doneContent: some View {
        VStack(spacing: 10) {
            Text("UPDATE COMPLETE")
                .font(PixelTheme.font(12))
                .foregroundStyle(PixelTheme.accent2)
                .tracking(1)
            Text("Relaunching…")
                .font(PixelTheme.font(10, .regular))
                .foregroundStyle(PixelTheme.dim)
        }
    }

    // MARK: - Error

    func errorContent(msg: String) -> some View {
        VStack(spacing: 10) {
            Text("UPDATE ERROR")
                .font(PixelTheme.font(12))
                .foregroundStyle(PixelTheme.accent)
                .tracking(1)
            Text(msg)
                .font(PixelTheme.font(9, .regular))
                .foregroundStyle(PixelTheme.dim)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
    }
}

// MARK: - Pixel Progress Bar

struct PixelProgressBar: View {
    var fraction: Double?
    @State private var shimmer: Double = 0

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(PixelTheme.panel)
                    .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 2))

                // Fill
                if let f = fraction {
                    Rectangle()
                        .fill(PixelTheme.accent2)
                        .frame(width: geo.size.width * CGFloat(max(0, min(1, f))))
                        .animation(.linear(duration: 0.2), value: f)
                } else {
                    // Indeterminate: sliding block
                    Rectangle()
                        .fill(PixelTheme.accent2.opacity(0.7))
                        .frame(width: geo.size.width * 0.3)
                        .offset(x: shimmer * (geo.size.width * 0.7))
                        .onAppear {
                            withAnimation(.linear(duration: 1).repeatForever(autoreverses: true)) {
                                shimmer = 1
                            }
                        }
                }
            }
        }
    }
}
