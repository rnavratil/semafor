import SwiftUI

@available(macOS 14.0, *)
struct MenuBarView: View {
    @EnvironmentObject var state: SemaforState
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        if state.items.isEmpty {
            Text("All clear ✅")
        } else {
            ForEach(state.items) { item in
                if let urlString = item.url, let url = URL(string: urlString) {
                    // Item with clickable link
                    Button(action: {
                        print("Opening URL: \(url)")
                        NSWorkspace.shared.open(url)
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "link.circle.fill")
                            Text(item.text)
                        }
                    }
                    .buttonStyle(.plain) // Makes it look like regular menu item but clickable
                } else {
                    // Item without link
                    Text(item.text)
                }
            }
        }
        
        Divider()
        
        if !state.updated.isEmpty {
            Text("Updated: \(state.updated)")
                .foregroundColor(.secondary)
        }
        
        Divider()
        
        Button("Settings…") {
            // Close the settings window if it's open
            if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "settings" }) {
                window.close()
            }
            
            // Cjheck if we're in a fullscreen space and move away if needed
            if let frontmostApp = NSWorkspace.shared.frontmostApplication,
               frontmostApp != NSRunningApplication.current {
                // Activate our app first to leave fullscreen context
                NSApp.activate(ignoringOtherApps: true)
            }
            
            // Small delay before reopening
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                openWindow(id: "settings")
                // Ensure activation after window opens
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    NSApp.activate(ignoringOtherApps: true)
                    if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "settings" }) {
                        window.makeKeyAndOrderFront(nil)
                    }
                }
            }
        }
        .keyboardShortcut(",")
        
        Button("Quit Semafor") {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
    
}
