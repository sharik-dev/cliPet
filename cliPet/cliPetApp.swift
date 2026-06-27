import SwiftUI

@main
struct cliPetApp: App {
    // Pilote l'app via AppKit : pas de fenêtre principale, juste un pet flottant.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // L'app est "agent" (LSUIElement) : pas de fenêtre principale ni d'icône Dock.
        // Le pet, la status bar et l'historique sont gérés par l'AppDelegate.
        // On expose quand même une scène Settings pour la fenêtre de réglages native.
        Settings {
            SettingsView()
                .environmentObject(appDelegate.settings)
        }
    }
}
