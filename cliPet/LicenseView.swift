import SwiftUI
import AppKit

/// Écran de licence / paywall. Sert à la fois pendant l'essai (bandeau + saisie
/// facultative) et une fois l'essai terminé (paywall bloquant).
struct LicenseView: View {
    @ObservedObject var license: LicenseManager
    let l10n: L10n
    /// Appelé quand l'utilisateur peut continuer (licence activée ou essai en cours).
    var onContinue: () -> Void = {}

    @State private var key = ""
    @State private var isWorking = false

    private var trialEnded: Bool { !license.isTrialActive && !license.isLicensed }

    var body: some View {
        VStack(spacing: 16) {
            // En-tête
            Text("🐾 " + l10n.licenseTitle)
                .font(PixelTheme.font(18))
                .tracking(2)

            // Statut essai / paywall
            statusBadge

            // Saisie de clé
            VStack(alignment: .leading, spacing: 8) {
                Text(l10n.licenseEnterKey)
                    .font(PixelTheme.font(11, .regular))
                    .foregroundStyle(PixelTheme.dim)
                HStack(spacing: 6) {
                    TextField(l10n.licenseKeyPlaceholder, text: $key)
                        .textFieldStyle(.plain)
                        .font(PixelTheme.font(12, .regular))
                        .foregroundStyle(PixelTheme.text)
                        .padding(.horizontal, 10).padding(.vertical, 8)
                        .pixelPanel()
                        .onSubmit(activate)
                        .disabled(isWorking)
                }
                if case let .invalid(reason) = license.state {
                    Text(reason.isEmpty ? l10n.licenseInvalid : reason)
                        .font(PixelTheme.font(10, .regular))
                        .foregroundStyle(PixelTheme.accent)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            // Actions
            Button(isWorking ? l10n.licenseChecking : l10n.licenseActivate, action: activate)
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent2.darkened(0.35)))
                .disabled(isWorking || key.trimmingCharacters(in: .whitespaces).isEmpty)

            Button("\(l10n.licenseBuy) — \(LicenseConfig.localizedPrice())") { openBuyPage() }
                .buttonStyle(PixelButtonStyle())

            // Pied : continuer l'essai ou quitter
            if trialEnded {
                Button(l10n.licenseQuit) { NSApp.terminate(nil) }
                    .buttonStyle(.plain)
                    .font(PixelTheme.font(10))
                    .foregroundStyle(PixelTheme.dim)
            } else {
                Button(l10n.licenseContinueTrial) { onContinue() }
                    .buttonStyle(.plain)
                    .font(PixelTheme.font(10))
                    .foregroundStyle(PixelTheme.dim)
            }
        }
        .padding(24)
        .frame(width: 340)
        .background(PixelTheme.bg)
        .foregroundStyle(PixelTheme.text)
        .onChange(of: license.state) { _, new in
            if case .valid = new { onContinue() }
        }
    }

    @ViewBuilder private var statusBadge: some View {
        if license.isLicensed {
            label(l10n.licenseActive, color: PixelTheme.accent2)
        } else if trialEnded {
            label(l10n.licenseTrialEnded, color: PixelTheme.accent)
        } else {
            label(l10n.licenseTrial(license.trialDaysRemaining), color: PixelTheme.accent2)
        }
    }

    private func label(_ text: String, color: Color) -> some View {
        Text(text)
            .font(PixelTheme.font(11))
            .foregroundStyle(color)
            .padding(.horizontal, 12).padding(.vertical, 6)
            .pixelPanel()
    }

    private func activate() {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isWorking else { return }
        isWorking = true
        Task {
            await license.activate(key: trimmed)
            isWorking = false
        }
    }

    private func openBuyPage() {
        Analytics.track("app_buy_click")
        if let url = URL(string: LicenseConfig.buyURL) { NSWorkspace.shared.open(url) }
    }
}
