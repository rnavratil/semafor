import SwiftUI

@available(macOS 14.0, *)
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        TabView {
            HelpTab()
                .tabItem { Label("Help", systemImage: "questionmark.circle") }

            AppearanceTab()
                .tabItem { Label("Appearance", systemImage: "paintbrush") }

            AboutTab()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .padding()
        .frame(width: 500, height: 450)
    }
}

// MARK: - Help

struct HelpTab: View {
    @State private var showCopiedConfirmation = false
    @ObservedObject private var cliInstaller = CLIInstaller.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // CLI Installation status
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: cliInstaller.isInstalled ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .foregroundColor(cliInstaller.isInstalled ? .green : .orange)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cliInstaller.isInstalled ? "CLI tool is installed" : "CLI tool is not installed")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if cliInstaller.isInstalled {
                            Text("Installed at: /usr/local/bin/semafor")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Install the CLI tool to use commands in Terminal")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                HStack(spacing: 8) {
                    if !cliInstaller.isInstalled {
                        Button("Install CLI Tool") {
                            CLIInstaller.shared.installCLI()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    } else {
                        Button("Reinstall") {
                            CLIInstaller.shared.installCLI()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("Uninstall") {
                            CLIInstaller.shared.uninstall()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        .tint(.red)
                    }
                }
            }
            .padding(12)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(8)
            
            HStack {
                Text("Bash commands")
                    .font(.headline)
                
                Spacer()
                
                Button(action: copyAllCommands) {
                    HStack(spacing: 4) {
                        Image(systemName: showCopiedConfirmation ? "checkmark" : "doc.on.doc")
                        Text(showCopiedConfirmation ? "Copied!" : "Copy all")
                    }
                    .font(.caption)
                    .foregroundColor(showCopiedConfirmation ? .green : .blue)
                }
                .buttonStyle(.plain)
            }

            VStack(alignment: .leading, spacing: 12) {
                CommandRow(
                    command: "semafor red \"reason\"",
                    description: "Set red and add an item (e.g. what needs attention)"
                )
                CommandRow(
                    command: "semafor red \"text\" \"url\"",
                    description: "Add an item with a clickable URL"
                )
                CommandRow(
                    command: "semafor add \"reason\"",
                    description: "Add another item without clearing existing ones"
                )
                CommandRow(
                    command: "semafor green",
                    description: "Clear all items and set back to green"
                )
                CommandRow(
                    command: "semafor status",
                    description: "Print current state.json to terminal"
                )
            }

            Divider()

            Text("State file: ~/.semafor/state.json")
                .font(.caption)
                .foregroundColor(.secondary)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(.top, 24)
        .padding(.bottom, 16)
    }
    
    private func copyAllCommands() {
        let commands = """
        # Semafor CLI Commands
        
        # Set red and add an item (e.g. what needs attention)
        semafor red "reason"
        
        # Add an item with a clickable URL
        semafor red "text" "url"
        
        # Add another item without clearing existing ones
        semafor add "reason"
        
        # Clear all items and set back to green
        semafor green
        
        # Print current state.json to terminal
        semafor status
        
        # State file location
        ~/.semafor/state.json
        """
        
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(commands, forType: .string)
        
        // Show confirmation
        showCopiedConfirmation = true
        
        // Reset after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showCopiedConfirmation = false
        }
    }
}

struct CommandRow: View {
    let command: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(command)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.15))
                .cornerRadius(4)
                .textSelection(.enabled)
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
                .textSelection(.enabled)
        }
    }
}

// MARK: - Appearance

struct AppearanceTab: View {
    @AppStorage("emoji.green") var greenEmoji: String = "🟢"
    @AppStorage("emoji.red") var redEmoji: String = "🔴"

    var body: some View {
        VStack(spacing: 20) {
            Text("Menu bar icons")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 24) {
                EmojiPicker(label: "Green (all clear)", emoji: $greenEmoji)
                EmojiPicker(label: "Red (needs attention)", emoji: $redEmoji)
            }

            Text("Click 'Change' to pick an emoji.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct EmojiPicker: View {
    let label: String
    @Binding var emoji: String
    @FocusState private var focused: Bool
    @State private var tempEmoji: String = ""

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)

            ZStack {
                // Visual display (read-only)
                Text(emoji)
                    .font(.system(size: 32))
                    .frame(width: 60, height: 60)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                
                // Hidden TextField for emoji picker input only
                TextField("", text: $tempEmoji)
                    .font(.system(size: 32))
                    .multilineTextAlignment(.center)
                    .frame(width: 60, height: 60)
                    .opacity(0.01)
                    .focused($focused)
                    .onChange(of: tempEmoji) { oldValue, newValue in
                        // Only accept new emoji, ignore deletions
                        if !newValue.isEmpty {
                            // Take only first character
                            emoji = String(newValue.prefix(1))
                            // Reset temp field
                            tempEmoji = ""
                        }
                    }
            }

            Button("Change") {
                focused = true
                tempEmoji = "" // Clear temp field
                NSApp.orderFrontCharacterPalette(nil)
            }
            .font(.caption)
        }
    }
}

// MARK: - About

struct AboutTab: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🚦")
                    .font(.system(size: 48))
                VStack(alignment: .leading) {
                    Text("Semafor")
                        .font(.title2.bold())
                    Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            Text("Semafor was created as a personal tool that helps focus on work and not deal with every notification separately. Instead of constantly checking Slack, just a glance at the menu bar is enough — red means something is waiting, green means all is clear.")
                .fixedSize(horizontal: false, vertical: true)

            Spacer()

            HStack(spacing: 4) {
                Text("Author: Rostislav Navrátil")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("—")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Link("e6n.cz/semafor", destination: URL(string: "https://e6n.cz/semafor")!)
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
