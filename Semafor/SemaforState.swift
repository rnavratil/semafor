import Foundation

struct SemaforItem: Codable, Hashable, Identifiable {
    var id: String { text + (url ?? "") }
    var text: String
    var url: String?
    
    // Support decoding from both String and object format
    init(from decoder: Decoder) throws {
        let container = try? decoder.singleValueContainer()
        
        if let string = try? container?.decode(String.self) {
            // Legacy format: just a string
            self.text = string
            self.url = nil
        } else {
            // New format: object with text and optional url
            let objContainer = try decoder.container(keyedBy: CodingKeys.self)
            self.text = try objContainer.decode(String.self, forKey: .text)
            self.url = try objContainer.decodeIfPresent(String.self, forKey: .url)
        }
    }
    
    init(text: String, url: String? = nil) {
        self.text = text
        self.url = url
    }
    
    enum CodingKeys: String, CodingKey {
        case text, url
    }
}

struct SemaforData: Codable {
    var color: String
    var items: [SemaforItem]
    var updated: String

    enum CodingKeys: String, CodingKey {
        case color, items, updated
    }
}

class SemaforState: ObservableObject {
    @Published var color: String = "green"
    @Published var items: [SemaforItem] = []
    @Published var updated: String = ""

    private var stateURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".semafor/state.json")
    }

    private var fileWatcher: DispatchSourceFileSystemObject?

    init() {
        load()
        startFileWatcher()
    }

    func load() {
        guard let data = try? Data(contentsOf: stateURL),
              let parsed = try? JSONDecoder().decode(SemaforData.self, from: data)
        else { return }

        DispatchQueue.main.async {
            self.color = parsed.color
            self.items = parsed.items
            self.updated = parsed.updated
        }
    }

    private func startFileWatcher() {
        let dir = stateURL.deletingLastPathComponent().path
        try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true)

        // Touch the file if it doesn't exist so we can open it
        if !FileManager.default.fileExists(atPath: stateURL.path) {
            try? "{}".write(to: stateURL, atomically: true, encoding: .utf8)
        }

        // Watch the directory instead of the file to catch file replacements
        let dirURL = stateURL.deletingLastPathComponent()
        let fd = open(dirURL.path, O_EVTONLY)
        guard fd >= 0 else { return }

        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd,
            eventMask: [.write, .delete, .rename, .extend],
            queue: DispatchQueue.global()
        )
        source.setEventHandler { [weak self] in
            // Small delay to ensure file write is complete
            usleep(50000) // 50ms
            self?.load()
        }
        source.setCancelHandler {
            close(fd)
        }
        source.resume()
        fileWatcher = source
    }

    func deleteItem(_ item: SemaforItem) {
        let newItems = items.filter { $0.id != item.id }
        let newColor = newItems.isEmpty ? "green" : color

        // Update in-memory state immediately to avoid flicker
        self.items = newItems
        self.color = newColor

        // Write back to file
        let newData = SemaforData(color: newColor, items: newItems, updated: updated)
        guard let data = try? JSONEncoder().encode(newData) else { return }
        try? data.write(to: stateURL, options: .atomic)
    }

    deinit {
        fileWatcher?.cancel()
    }
}
