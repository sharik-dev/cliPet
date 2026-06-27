import SwiftUI

/// Fenêtre pixel-art : choix du pet (presets + couleurs) et réglages de comportement.
struct SettingsView: View {
    @EnvironmentObject var settings: PetSettings
    @State private var tab: Tab = .pet

    enum Tab { case pet, behavior }

    var body: some View {
        VStack(spacing: 0) {
            header
            tabBar
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    switch tab {
                    case .pet:      petTab
                    case .behavior: behaviorTab
                    }
                }
                .padding(14)
            }
        }
        .frame(width: 380, height: 600)
        .background(PixelTheme.bg)
        .foregroundStyle(PixelTheme.text)
        .font(PixelTheme.font(12, .regular))
    }

    // MARK: - En-tête avec aperçu animé

    private var header: some View {
        VStack(spacing: 8) {
            Text("🐾 cliPet")
                .font(PixelTheme.font(16))
                .tracking(2)
            TimelineView(.animation) { timeline in
                let tick = Int(timeline.date.timeIntervalSinceReferenceDate * 30)
                PixelCatView(
                    state: .walk, facing: .right, tick: tick,
                    bodyColor: settings.bodyColor, bellyColor: settings.bellyColor,
                    stripeColor: settings.stripeColor, eyeColor: settings.eyeColor,
                    noseColor: settings.noseColor
                )
                .frame(width: 96, height: 96)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(PixelTheme.panel)
        .overlay(Rectangle().fill(PixelTheme.border).frame(height: 2), alignment: .bottom)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton("MON CHAT", .pet)
            tabButton("RÉGLAGES", .behavior)
        }
        .overlay(Rectangle().fill(PixelTheme.border).frame(height: 2), alignment: .bottom)
    }

    private func tabButton(_ label: String, _ value: Tab) -> some View {
        Button { tab = value } label: {
            Text(label)
                .font(PixelTheme.font(11))
                .tracking(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundStyle(tab == value ? PixelTheme.accent : PixelTheme.dim)
                .background(tab == value ? PixelTheme.panelHi : PixelTheme.panel)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Onglet "Mon chat"

    private var petTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            PixelSectionHeader(title: "Robes")
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                      spacing: 8) {
                ForEach(PetCatalog.presets) { preset in
                    Button { settings.apply(preset) } label: {
                        PetSwatch(preset: preset, selected: isSelected(preset))
                    }
                    .buttonStyle(.plain)
                }
            }

            PixelSectionHeader(title: "Couleurs perso")
            colorRow("Pelage", $settings.bodyColor)
            colorRow("Ventre / pattes", $settings.bellyColor)
            colorRow("Rayures / contour", $settings.stripeColor)
            colorRow("Yeux", $settings.eyeColor)
            colorRow("Nez / oreilles", $settings.noseColor)

            PixelSectionHeader(title: "Taille")
            sliderRow(value: $settings.scale, range: 0.5...1.8, label: "Taille")
        }
    }

    // MARK: - Onglet "Réglages"

    private var behaviorTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            PixelSectionHeader(title: "Mouvement")
            sliderRow(value: $settings.speed, range: 0.5...2.5, label: "Vitesse")

            PixelSectionHeader(title: "Comportement")
            toggleRow("Faire des bêtises", $settings.mischiefEnabled)
            toggleRow("Poursuivre le curseur", $settings.chaseCursor)

            PixelSectionHeader(title: "Presse-papiers")
            HStack {
                Text("Garder \(settings.maxHistory) éléments")
                    .font(PixelTheme.font(11, .regular))
                Spacer()
                Stepper("", value: $settings.maxHistory, in: 5...200, step: 5)
                    .labelsHidden()
            }
            .padding(10).pixelPanel()

            Button("RÉINITIALISER") { settings.resetToDefaults() }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent.darkened(0.3)))
                .padding(.top, 6)
        }
    }

    // MARK: - Lignes réutilisables

    private func colorRow(_ label: String, _ binding: Binding<Color>) -> some View {
        HStack {
            Text(label).font(PixelTheme.font(11, .regular))
            Spacer()
            ColorPicker("", selection: binding, supportsOpacity: false)
                .labelsHidden()
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .pixelPanel()
    }

    private func sliderRow(value: Binding<Double>, range: ClosedRange<Double>, label: String) -> some View {
        HStack(spacing: 10) {
            Text(label).font(PixelTheme.font(11, .regular)).frame(width: 60, alignment: .leading)
            Slider(value: value, in: range).tint(PixelTheme.accent)
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .pixelPanel()
    }

    private func toggleRow(_ label: String, _ binding: Binding<Bool>) -> some View {
        HStack {
            Text(label).font(PixelTheme.font(11, .regular))
            Spacer()
            Toggle("", isOn: binding).labelsHidden().tint(PixelTheme.accent)
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .pixelPanel()
    }

    private func isSelected(_ p: PetPreset) -> Bool {
        settings.bodyColor.hexString.uppercased() == p.body.uppercased()
    }
}
