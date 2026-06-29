import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: PetSettings
    @EnvironmentObject var clipboard: ClipboardManager
    @ObservedObject private var store = SpriteStore.shared
    @State private var tab: Tab = .pet
    @State private var launchAtLogin = LaunchAtLogin.isEnabled
    @State private var autoUpdate = UpdaterController.shared.automaticallyChecksForUpdates
    @State private var showLaunchHelp = false
    @State private var showClearConfirm = false
    @State private var skins: [Skin] = SkinCatalog.all()
    @State private var showSaveCoat = false
    @State private var newCoatName = ""
    @State private var renamingSkinID: String?
    @State private var renameText = ""
    @State private var showNewPet = false
    @State private var newPetName = ""
    @State private var headerName = ""
    @FocusState private var headerNameFocused: Bool

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
            // Nom du pet actuel — éditable (renomme le skin actif).
            HStack(spacing: 6) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(PixelTheme.accent)
                TextField("", text: $headerName)
                    .textFieldStyle(.plain)
                    .font(PixelTheme.font(16))
                    .tracking(2)
                    .multilineTextAlignment(.center)
                    .fixedSize()
                    .foregroundStyle(PixelTheme.text)
                    .focused($headerNameFocused)
                    .onSubmit { commitHeaderRename() }
                    .onChange(of: headerNameFocused) { focused in
                        if !focused { commitHeaderRename() }
                    }
                Image(systemName: "pencil")
                    .font(.system(size: 10))
                    .foregroundStyle(PixelTheme.dim)
            }
            .onAppear { headerName = activeDisplayName }
            .onChange(of: store.activeSkinId) { _ in headerName = activeDisplayName }
            .onChange(of: settings.currentCoatName) { _ in
                if !headerNameFocused { headerName = activeDisplayName }
            }
            .onReceive(NotificationCenter.default.publisher(for: .skinsChanged)) { _ in
                if !headerNameFocused { headerName = activeDisplayName }
            }

            TimelineView(.animation) { timeline in
                let tick = Int(timeline.date.timeIntervalSinceReferenceDate * 30)
                // Aperçu du pet réellement utilisé : skin actif + couleurs courantes.
                PixelSpriteView(
                    frame: activeSkin.frames[PixelCatView.frameName(for: .walk, tick: tick)]
                        ?? activeSkin.frames["idle1"] ?? activeSkin.frames["idle"] ?? [],
                    palette: skinPalette
                )
                .frame(width: 96, height: 96)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(PixelTheme.panel)
        .overlay(Rectangle().fill(PixelTheme.border).frame(height: 2), alignment: .bottom)
    }

    private func commitHeaderRename() {
        let newName = headerName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newName.isEmpty, newName != activeDisplayName else {
            headerName = activeDisplayName
            return
        }
        // Renomme le pet (skin). On purge la robe courante pour que le nom saisi
        // s'affiche réellement (sinon le nom de robe masquerait le nouveau nom).
        settings.currentCoatName = ""
        SkinCatalog.renameSkin(activeSkin.id, to: newName)
        skins = SkinCatalog.all()
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

            // 2) Couleurs / robes (= variantes : même pet, couleurs différentes)
            PixelSectionHeader(title: l10n.sectionCoats)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                      spacing: 8) {
                ForEach(PetCatalog.builtinCoats(for: store.activeSkinId)
                        + settings.coats(for: store.activeSkinId)) { preset in
                    Button { applyCoat(preset) } label: {
                        PetSwatch(preset: preset, selected: isSelected(preset),
                                  frame: store.frame("idle1"))
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        if preset.id.hasPrefix("user-") {
                            Button(role: .destructive) {
                                settings.removeCoat(preset, skinId: store.activeSkinId)
                            } label: {
                                Label(l10n.deleteVariant, systemImage: "trash")
                            }
                        }
                    }
                }
            }
            // Custom Colors = rendu dynamique des couleurs nommées (variables).
            // Éditer une couleur enregistre une variante par skin (via SpriteStore).
            PixelSectionHeader(title: l10n.sectionCustomColors)
            ForEach(variableChars, id: \.self) { customColorRow($0) }

            // Appliquer les couleurs courantes au pet sélectionné, sans créer de variante.
            Button { applyToSelectedPet() } label: {
                PixelButtonLabel(glyph: PixelGlyph.check, title: l10n.applyToPet)
            }
            .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent.darkened(0.3)))

            Button { showSaveCoat = true } label: {
                PixelButtonLabel(glyph: PixelGlyph.floppy, title: l10n.saveVariant)
            }
            .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent2.darkened(0.35)))
            .popover(isPresented: $showSaveCoat, arrowEdge: .bottom) { saveCoatPopover }

            // Éditer le pet actuel (dessin / couleurs).
            Button { PetController.requestOpenEditor() } label: {
                PixelButtonLabel(glyph: PixelGlyph.pencil, title: l10n.buttonOpenEditor)
            }
            .buttonStyle(PixelButtonStyle())

            // Créer un tout nouveau pet (skin vierge), puis ouvrir l'éditeur dessus.
            Button { newPetName = ""; showNewPet = true } label: {
                PixelButtonLabel(glyph: PixelGlyph.plus, title: l10n.editorNewPet)
            }
            .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent2.darkened(0.35)))
            .popover(isPresented: $showNewPet, arrowEdge: .bottom) { newPetPopover }

            PixelSectionHeader(title: l10n.sectionSize)
            sliderRow(value: $settings.scale, range: 0.5...1.8, label: l10n.labelSize)
        }
    }

    // MARK: - Skin picker (intègre le gestionnaire de skins)

    private var skinPalette: PixelPalette {
        PixelPalette(body: settings.bodyColor, belly: settings.bellyColor,
                     stripe: settings.stripeColor, eye: settings.eyeColor, nose: settings.noseColor,
                     customColors: store.customColors)
    }

    /// Palette d'aperçu propre à une carte : chaque skin avec SA palette, pas celle
    /// du skin actif (évite que tous les aperçus prennent les couleurs du skin courant).
    private func cardPalette(for skin: Skin) -> PixelPalette {
        PixelPalette(body: settings.bodyColor, belly: settings.bellyColor,
                     stripe: settings.stripeColor, eye: settings.eyeColor, nose: settings.noseColor,
                     customColors: store.previewColors(for: skin.id))
    }

    private var skinPicker: some View {
        VStack(spacing: 10) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2),
                      spacing: 10) {
                ForEach(skins) { skin in
                    skinCard(skin)
                }
            }
            .onAppear { skins = SkinCatalog.all() }
            .onReceive(NotificationCenter.default.publisher(for: .skinsChanged)) { _ in
                skins = SkinCatalog.all()
            }

            // Éditer / Supprimer le skin sélectionné
            HStack(spacing: 8) {
                Button {
                    renameText = activeSkin.name
                    renamingSkinID = activeSkin.id
                } label: {
                    PixelButtonLabel(glyph: PixelGlyph.pencil, title: l10n.skinEdit)
                }
                .buttonStyle(PixelButtonStyle())
                .popover(isPresented: Binding(
                    get: { renamingSkinID == activeSkin.id },
                    set: { if !$0 { renamingSkinID = nil } }
                ), arrowEdge: .top) {
                    renamePopover(for: activeSkin)
                }

                Button { deleteSkin(activeSkin) } label: {
                    PixelButtonLabel(glyph: PixelGlyph.trash, title: l10n.skinDelete)
                }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent.darkened(0.35)))
                .disabled(activeSkin.builtin)
            }

            // Import / Marketplace buttons
            HStack(spacing: 8) {
                Button(action: importPet) {
                    PixelButtonLabel(glyph: PixelGlyph.plus, title: l10n.skinAddPet)
                }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent2.darkened(0.35)))

                Button(action: { PetController.requestOpenMarketplace() }) {
                    PixelButtonLabel(glyph: PixelGlyph.store, title: l10n.skinTabMarket)
                }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent.darkened(0.3)))
            }
        }
    }

    /// Skin actuellement sélectionné (cible des actions Éditer / Supprimer).
    private var activeSkin: Skin { SkinCatalog.skin(store.activeSkinId) }

    /// Nom affiché en haut / sur la carte active : la robe (variante) courante si
    /// définie, sinon le nom du skin. Les deux doivent rester synchronisés.
    private var activeDisplayName: String {
        settings.currentCoatName.isEmpty ? activeSkin.name : settings.currentCoatName
    }

    private func skinCard(_ skin: Skin) -> some View {
        let active = store.activeSkinId == skin.id
        return Button {
            guard store.activeSkinId != skin.id else { return }
            // Le nom de robe courant appartient au skin précédent : on le purge
            // pour que la carte affiche le vrai nom du nouveau skin.
            settings.currentCoatName = ""
            store.setActiveSkin(skin.id)
        } label: {
            VStack(spacing: 6) {
                PixelSpriteView(frame: skin.frames["idle1"] ?? skin.frames["idle"] ?? [],
                                palette: cardPalette(for: skin))
                    .frame(width: 72, height: 72)
                // Skin actif : affiche le nom du coat (robe) courant si défini ; sinon le nom du skin.
                Text(active && !settings.currentCoatName.isEmpty ? settings.currentCoatName : skin.name)
                    .font(PixelTheme.font(10)).lineLimit(1)
                    .foregroundStyle(active ? PixelTheme.text : PixelTheme.dim)
                if active {
                    Text(l10n.skinActive).font(PixelTheme.font(8)).foregroundStyle(PixelTheme.accent2)
                } else {
                    // placeholder pour garder la hauteur constante
                    Text(" ").font(PixelTheme.font(8))
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity)
            .background(active ? PixelTheme.panelHi : PixelTheme.panel)
            .overlay(Rectangle().strokeBorder(active ? PixelTheme.accent : PixelTheme.border, lineWidth: 2))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(l10n.skinExport) { exportPet(skin) }
        }
    }

    private func deleteSkin(_ skin: Skin) {
        let alert = NSAlert()
        alert.messageText = l10n.skinDelete
        alert.informativeText = l10n.skinDeleteConfirm(skin.name)
        alert.alertStyle = .warning
        alert.addButton(withTitle: l10n.skinDelete)
        alert.addButton(withTitle: l10n.cancel)
        guard alert.runModal() == .alertFirstButtonReturn else { return }
        if store.activeSkinId == skin.id {
            store.setActiveSkin(SkinCatalog.builtins[0].id)
        }
        SkinCatalog.deleteSkin(skin.id)
        skins = SkinCatalog.all()
    }

    /// Popover de renommage pixel-art (remplace l'ancienne NSAlert).
    private func renamePopover(for skin: Skin) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(l10n.skinRename.replacingOccurrences(of: "…", with: ""))
                .font(PixelTheme.font(11)).foregroundStyle(PixelTheme.accent)
            HStack(spacing: 6) {
                TextField(skin.name, text: $renameText)
                    .textFieldStyle(.plain).font(PixelTheme.font(11, .regular))
                    .foregroundStyle(PixelTheme.text)
                    .padding(.horizontal, 8).padding(.vertical, 6)
                    .background(PixelTheme.bg)
                    .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
                    .onSubmit { commitRename(skin) }
                Button(action: { commitRename(skin) }) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(renameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                         ? PixelTheme.dim : PixelTheme.accent2)
                }
                .buttonStyle(.plain)
                .disabled(renameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(12).frame(width: 220).background(PixelTheme.panel)
    }

    private func commitRename(_ skin: Skin) {
        let newName = renameText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !newName.isEmpty else { return }
        SkinCatalog.renameSkin(skin.id, to: newName)
        skins = SkinCatalog.all()
        renamingSkinID = nil
    }

    // MARK: - Import / Export

    private func importPet() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = []
        panel.begin { resp in
            guard resp == .OK, let url = panel.url else { return }
            do {
                let pkg = try PetPackage.load(from: url)
                pkg.install()
                skins = SkinCatalog.all()
                showImportAlert(l10n.skinImported, isError: false)
            } catch {
                showImportAlert((error as? LocalizedError)?.errorDescription ?? l10n.skinImportError, isError: true)
            }
        }
    }

    private func exportPet(_ skin: Skin) {
        let pkg = PetPackage.forSkin(skin, settings: settings)
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "\(skin.name).\(PetPackage.fileExtension)"
        panel.begin { resp in
            guard resp == .OK, let url = panel.url else { return }
            try? pkg.encoded().write(to: url)
        }
    }

    private func showImportAlert(_ text: String, isError: Bool) {
        let alert = NSAlert()
        alert.messageText = text
        alert.alertStyle = isError ? .warning : .informational
        alert.runModal()
    }

    // MARK: - Settings tab

    private var behaviorTab: some View {
        VStack(alignment: .leading, spacing: 14) {
            PixelSectionHeader(title: l10n.sectionMovement)
            sliderRow(value: $settings.speed, range: 0.5...2.5, label: l10n.labelSpeed)

            PixelSectionHeader(title: l10n.sectionBehavior)
            toggleRow(l10n.toggleMischief, $settings.mischiefEnabled)
            toggleRow(l10n.toggleChaseCursor, $settings.chaseCursor)
            toggleRow(l10n.toggleToy, $settings.toyEnabled)

            PixelSectionHeader(title: l10n.sectionStartup)
            launchAtLoginRow
            toggleRow(l10n.toggleAutoUpdate, autoUpdateBinding)

            PixelSectionHeader(title: l10n.sectionClipboard)

            Button(l10n.clearHistory) { showClearConfirm = true }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent.darkened(0.3)))
                .alert(l10n.clearHistoryTitle, isPresented: $showClearConfirm) {
                    Button(l10n.cancel, role: .cancel) {}
                    Button(l10n.clearConfirm, role: .destructive) { clipboard.clear() }
                } message: {
                    Text(l10n.clearHistoryMessage)
                }

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

    /// Pilote l'opt-in Sparkle aux vérifs automatiques (persisté par Sparkle lui-même).
    private var autoUpdateBinding: Binding<Bool> {
        Binding(
            get: { autoUpdate },
            set: { newValue in
                UpdaterController.shared.automaticallyChecksForUpdates = newValue
                autoUpdate = newValue
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

    // MARK: - Coats / variantes

    /// Applique un coat et nettoie les overrides de base (sinon ils masqueraient le coat).
    private func applyCoat(_ preset: PetPreset) {
        settings.apply(preset)
        store.clearBaseOverrides()
    }

    private var saveCoatPopover: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(l10n.saveVariant).font(PixelTheme.font(11)).foregroundStyle(PixelTheme.accent)
            HStack(spacing: 6) {
                TextField(l10n.variantNamePlaceholder, text: $newCoatName)
                    .textFieldStyle(.plain).font(PixelTheme.font(11, .regular))
                    .foregroundStyle(PixelTheme.text)
                    .onSubmit(saveCoat)
                Button(action: saveCoat) { Image(systemName: "checkmark") }
                    .buttonStyle(.plain).foregroundStyle(PixelTheme.accent2)
            }
        }
        .padding(12).frame(width: 200).background(PixelTheme.panel)
    }

    private func saveCoat() {
        settings.saveCurrentAsCoat(name: newCoatName, skinId: store.activeSkinId)
        newCoatName = ""
        showSaveCoat = false
    }

    // MARK: - Nouveau pet

    private var newPetPopover: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(l10n.editorNewPet)
                .font(PixelTheme.font(11)).foregroundStyle(PixelTheme.accent)
            HStack(spacing: 6) {
                TextField(l10n.editorNewPetPlaceholder, text: $newPetName)
                    .textFieldStyle(.plain).font(PixelTheme.font(11, .regular))
                    .foregroundStyle(PixelTheme.text)
                    .padding(.horizontal, 8).padding(.vertical, 6)
                    .background(PixelTheme.bg)
                    .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
                    .onSubmit(createNewPet)
            }
            Button(l10n.editorCreate) { createNewPet() }
                .buttonStyle(PixelButtonStyle(tint: PixelTheme.accent2.darkened(0.35)))
                .disabled(newPetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(12).frame(width: 200).background(PixelTheme.panel)
    }

    /// Crée un skin utilisateur vierge (frames vides aux dimensions par défaut),
    /// l'active, puis ouvre l'éditeur dessus.
    private func createNewPet() {
        let name = newPetName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        let blank = CatSprites.all.mapValues { rows in
            rows.map { String(repeating: ".", count: $0.count) }
        }
        PetInstaller.install(name: name, frames: blank, palette: MarketPalette(), activate: true)
        skins = SkinCatalog.all()
        newPetName = ""
        showNewPet = false
        PetController.requestOpenEditor()
    }

    /// Épingle les couleurs courantes sur le pet (skin) sélectionné, sans créer de
    /// variante réutilisable : ces couleurs deviennent propres à ce pet.
    private func applyToSelectedPet() {
        store.applyBaseColorsToActiveSkin(
            body: settings.bodyColor, belly: settings.bellyColor,
            stripe: settings.stripeColor, eye: settings.eyeColor, nose: settings.noseColor)
    }

    // MARK: - Custom colors (rendu dynamique des couleurs nommées)

    /// Caractères affichés comme variables : couleurs de base portant un nom
    /// (explicite ou par défaut) + couleurs ajoutées nommées.
    private var variableChars: [Character] {
        let base = SpriteStore.baseChars.filter {
            store.colorName(for: $0) != nil || l10n.defaultColorName(for: $0) != nil
        }
        let added = store.addedChars.compactMap { $0.first }.filter { store.colorName(for: $0) != nil }
        return base + added
    }

    /// Une couleur custom : pastille + nom + sélecteur. La modifier enregistre une
    /// variante (surcharge la couleur du caractère pour le skin actif).
    private func customColorRow(_ ch: Character) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(skinPalette.color(for: ch) ?? .gray)
                .frame(width: 18, height: 18)
                .overlay(Rectangle().strokeBorder(PixelTheme.border, lineWidth: 1))
            Text(store.colorName(for: ch) ?? l10n.defaultColorName(for: ch) ?? String(ch))
                .font(PixelTheme.font(11, .regular))
            Spacer()
            ColorPicker("", selection: colorBinding(for: ch), supportsOpacity: false)
                .labelsHidden()
        }
    }

    /// Rôles de base → éditent le coat courant (`settings`) + nettoient l'override ;
    /// couleurs ajoutées → overrides par skin (`store`).
    private func colorBinding(for ch: Character) -> Binding<Color> {
        switch ch {
        case "g": return Binding(get: { settings.bodyColor },   set: { settings.bodyColor = $0;   store.clearColor(ch) })
        case "w": return Binding(get: { settings.bellyColor },  set: { settings.bellyColor = $0;  store.clearColor(ch) })
        case "d": return Binding(get: { settings.stripeColor }, set: { settings.stripeColor = $0; store.clearColor(ch) })
        case "o": return Binding(get: { settings.eyeColor },    set: { settings.eyeColor = $0;    store.clearColor(ch) })
        case "p": return Binding(get: { settings.noseColor },   set: { settings.noseColor = $0;   store.clearColor(ch) })
        default:  return Binding(get: { skinPalette.color(for: ch) ?? .gray }, set: { store.setColor(ch, $0) })
        }
    }

    // MARK: - Reusable rows

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
