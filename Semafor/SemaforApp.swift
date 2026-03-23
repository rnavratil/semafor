import SwiftUI

@available(macOS 14.0, *)
@main
struct SemaforApp: App {
    @StateObject private var state = SemaforState()
    @AppStorage("emoji.green") var greenEmoji: String = "🟢"
    @AppStorage("emoji.red") var redEmoji: String = "🔴"
    @AppStorage("hasPromptedCLIInstall") private var hasPromptedCLIInstall = false

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(state)
                .task {
                    // Check CLI installation on first launch
                    if !hasPromptedCLIInstall {
                        try? await Task.sleep(for: .seconds(1))
                        await MainActor.run {
                            CLIInstaller.shared.checkAndPromptInstallation()
                            hasPromptedCLIInstall = true
                        }
                    }
                }
        } label: {
            Text(state.color == "red" ? redEmoji : greenEmoji)
        }
        .menuBarExtraStyle(.menu)

        Window("Settings", id: "settings") {
            SettingsView()
        }
        .windowResizability(.contentSize)
        .defaultPosition(.center)
        .windowStyle(.hiddenTitleBar)
        .commandsRemoved()
    }
}
