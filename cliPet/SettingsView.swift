import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: PetSettings
    @ObservedObject private var store = SpriteStore.shared
    @State private var tab: Tab = .pet
    @State private var launchAtLogin = LaunchAtLogin.isEnabled
    @State private var showLaunchHelp = false
    @State private var skins: [Skin] = SkinCatalog.all()

    enum Tab { case pet, behavior }

    private var l10n: L10n {
        L10n.for_(L10n.Language(rawValue: settings.language) ?? .en)
    }

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

    // MARK: - Header

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
            tabButton(l10n.tabMyCat, .pet)
            tabButton(l10n.tabSettings, .behavior)
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

    // MARK: - Pet tab

    private var petTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            // 1) Choix du skin
            PixelSectionHeader(title: l10n.sectionSkins)
            skinPicker

            // 2) Couleurs / robes
            PixelSectionHeader(title: l10n.sectionCoats)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                      spacing: 8) {
                ForEach(PetCatalog.presets) { preset in
                    Button { settings.apply(preset) } label: {
                        PetSwatch(preset: preset, selected: isSelected(preset))
                    }
                    .buttonStyle(.plain)
                }
            }

            PixelSectionHeader(title: l10n.sectionCustomColors)
            colorRow(l10n.colorFur, $settings.bodyColor)
            colorRow(l10n.colorBelly, $settings.bellyColor)
            colorRow(l10n.colorStripes, $settings.stripeColor)
            colorRow(l10n.colorEyes, $settings.eyeColor)
            colorRow(l10n.colorNose, $settings.noseColor)

            PixelSectionHeader(title: l10n.sectionSize)
            sliderRow(value: $settings.scale, range: 0.5...1.8, label: l10n.labelSize)

            // 3) Éditeur de pet
            Button(l10n.buttonOpenEditor) { PetController.requestOpenEditor() }
                .buttonStyle(PixelButtonStyle())
                .padding(.top, 6)
        }
    }

    // MARK: - Skin picker (intègre le gestionnaire de skins)

    private var skinPalette: PixelPalette {
        PixelPalette(body: settings.bodyColor, belly: settings.bellyColor,
                     stripe: settings.stripeColor, eye: settings.eyeColor, nose: settings.noseColor)
    }

    private var skinPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2),
                  spacing: 10) {
            ForEach(skins) { skin in
                Button { store.setActiveSkin(skin.id) } label: {
                    skinCard(skin)
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear { skins = SkinCatalog.all() }
    }

    private func skinCard(_ skin: Skin) -> some View {
        let active = store.activeSkinId == skin.id
        return VStack(spacing: 6) {
            PixelSpriteView(frame: skin.frames["idle1"] ?? skin.frames["idle"] ?? [],
                            palette: skinPalette)
                .frame(width: 72, height: 72)
            Text(skin.name).font(PixelTheme.font(10)).lineLimit(1)
                .foregroundStyle(active ? PixelTheme.text : PixelTheme.dim)
            if active {
                Text("● ACTIF").font(PixelTheme.font(8)).foregroundStyle(PixelTheme.accent2)
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .background(active ? PixelTheme.panelHi : PixelTheme.panel)
        .overlay(Rectangle().strokeBorder(active ? PixelTheme.accent : PixelTheme.border, lineWidth: 2))
    }

    // MARK: - Settings tab

    private var behaviorTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            PixelSectionHeader(title: l10n.sectionMovement)
            sliderRow(value: $settings.speed, range: 0.5...2.5, label: l10n.labelSpeed)

            PixelSectionHeader(title: l10n.sectionBehavior)
            toggleRow(l10n.toggleMischief, $settings.mischiefEnabled)
            toggleRow(l10n.toggleChaseCursor, $settings.chaseCursor)

            PixelSectionHeader(title: l10n.sectionStartup)
            launchAtLoginRow

            PixelSectionHeader(title: l10n.sectionClipboard)
            HStack {
                Text(l10n.keepItems(settings.maxHistory))
                    .font(PixelTheme.font(11, .regular))
                Spacer()
                Stepper("", value: $settings.maxHistory, in: 5...200, step: 5)
                    .labelsHidden()
            }
            .padding(10).pixelPanel()

            PixelSectionHeader(title: l10n.sectionLanguage)
            languagePicker

            Button(l10n.buttonReset) { settings.resetToDefaults() }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent.darkened(0.3)))
                .padding(.top, 6)
        }
    }

    // MARK: - Language picker

    private var languagePicker: some View {
        VStack(spacing: 4) {
            ForEach(L10n.Language.allCases) { lang in
                Button {
                    settings.language = lang.rawValue
                } label: {
                    HStack(spacing: 10) {
                        Text(lang.flag)
                            .font(.system(size: 16))
                        Text(lang.displayName)
                            .font(PixelTheme.font(11, .regular))
                        Spacer()
                        if settings.language == lang.rawValue {
                            Image(systemName: "checkmark")
                                .font(PixelTheme.font(10))
                                .foregroundStyle(PixelTheme.accent)
                        }
                    }
                    .padding(.horizontal, 10).padding(.vertical, 8)
                    .background(settings.language == lang.rawValue
                        ? PixelTheme.panelHi : PixelTheme.panel)
                }
                .buttonStyle(.plain)
                .overlay(Rectangle().strokeBorder(
                    settings.language == lang.rawValue ? PixelTheme.accent : PixelTheme.border,
                    lineWidth: 2))
            }
        }
    }

    // MARK: - Launch at login

    private var launchAtLoginRow: some View {
        HStack {
            Text(l10n.toggleLaunchAtLogin).font(PixelTheme.font(11, .regular))
            Spacer()
            Button { showLaunchHelp = true } label: {
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(PixelTheme.dim)
            }
            .buttonStyle(.plain)
            .popover(isPresented: $showLaunchHelp, arrowEdge: .bottom) { launchHelpPopover }
            Toggle("", isOn: launchBinding).labelsHidden().tint(PixelTheme.accent)
        }
        .padding(.horizontal, 10).padding(.vertical, 8)
        .pixelPanel()
    }

    private var launchBinding: Binding<Bool> {
        Binding(
            get: { launchAtLogin },
            set: { newValue in
                let ok = LaunchAtLogin.setEnabled(newValue)
                launchAtLogin = LaunchAtLogin.isEnabled  // relit l'état réel
                if !ok { showLaunchHelp = true }         // échec → guidage manuel
            }
        )
    }

    private var launchHelpPopover: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(l10n.launchPromptTitle)
                .font(PixelTheme.font(12)).foregroundStyle(PixelTheme.accent)
            Text(l10n.launchPromptBody)
                .font(PixelTheme.font(10, .regular))
                .foregroundStyle(PixelTheme.text)
                .fixedSize(horizontal: false, vertical: true)
            Button(l10n.launchOpenSettings) { LaunchAtLogin.openLoginItemsSettings() }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent2.darkened(0.35)))
        }
        .padding(14)
        .frame(width: 260)
        .background(PixelTheme.bg)
        .foregroundStyle(PixelTheme.text)
    }

    // MARK: - Reusable rows

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
            Text(label).font(PixelTheme.font(11, .regular)).frame(width: 70, alignment: .leading)
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
