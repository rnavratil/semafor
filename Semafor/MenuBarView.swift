import SwiftUI

@available(macOS 14.0, *)
struct MenuBarView: View {
    @EnvironmentObject var state: SemaforState
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Items
            if state.items.isEmpty {
                Text("All clear ✅")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            } else {
                ForEach(state.items) { item in
                    HStack(spacing: 6) {
                        if let urlString = item.url, let url = URL(string: urlString) {
                            Button(action: { NSWorkspace.shared.open(url) }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "link.circle.fill")
                                        .foregroundColor(.accentColor)
                                    Text(item.text)
                                        .lineLimit(2)
                                }
                            }
                            .buttonStyle(.plain)
                        } else {
                            Text(item.text)
                                .lineLimit(2)
                        }
                        Spacer(minLength: 8)
                        Button(action: { state.deleteItem(item) }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .imageScale(.medium)
                        }
                        .buttonStyle(.plain)
                        .help("Remove")
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                }
            }

            Divider()

            // Footer
            if !state.updated.isEmpty {
                Text("Updated: \(state.updated)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
            }

            Divider()

            // Actions
            HStack {
                Button("Settings") {
                    if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "settings" }) {
                        window.close()
                    }
                    if let frontmostApp = NSWorkspace.shared.frontmostApplication,
                       frontmostApp != NSRunningApplication.current {
                        NSApp.activate(ignoringOtherApps: true)
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        openWindow(id: "settings")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            NSApp.activate(ignoringOtherApps: true)
                            if let window = NSApplication.shared.windows.first(where: { $0.identifier?.rawValue == "settings" }) {
                                window.makeKeyAndOrderFront(nil)
                            }
                        }
                    }
                }
                .keyboardShortcut(",")
                .buttonStyle(.plain)

                Spacer()

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .keyboardShortcut("q")
                .buttonStyle(.plain)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
        }
        .frame(minWidth: 260)
    }
}
