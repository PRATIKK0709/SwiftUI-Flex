import SwiftUI
import UniformTypeIdentifiers
import AppKit

@main
struct EasyDrop: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings { }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var eventMonitor: EventMonitor?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        setupEventMonitor()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "tray.fill", accessibilityDescription: "Storage")
            button.target = self
            button.action = #selector(togglePopover)
            
            let dropView = StatusItemDropView(frame: button.bounds)
            dropView.autoresizingMask = [.width, .height]
            dropView.statusItem = statusItem
            dropView.onTogglePopover = { [weak self] in
                self?.togglePopover()
            }
            button.addSubview(dropView)
        }
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 400)
        popover?.behavior = .transient
        popover?.animates = true
        popover?.contentViewController = NSHostingController(
            rootView: NotchStorageView(onDismiss: { [weak self] in
                self?.closePopover()
            })
        )
    }
    
    private func setupEventMonitor() {
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if self?.popover?.isShown == true {
                self?.closePopover()
            }
        }
        eventMonitor?.start()
    }
    
    @objc private func togglePopover() {
        if let button = statusItem?.button {
            if popover?.isShown == true {
                closePopover()
            } else {
                popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                eventMonitor?.start()
            }
        }
    }
    
    private func closePopover() {
        popover?.performClose(nil)
        eventMonitor?.stop()
    }
}

class EventMonitor {
    private var monitor: Any?
    private let mask: NSEvent.EventTypeMask
    private let handler: (NSEvent?) -> Void
    
    init(mask: NSEvent.EventTypeMask, handler: @escaping (NSEvent?) -> Void) {
        self.mask = mask
        self.handler = handler
    }
    
    deinit {
        stop()
    }
    
    func start() {
        monitor = NSEvent.addGlobalMonitorForEvents(matching: mask, handler: handler)
    }
    
    func stop() {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}



class StatusItemDropView: NSView {
    weak var statusItem: NSStatusItem?
    var onTogglePopover: (() -> Void)?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseDown(with event: NSEvent) {
        onTogglePopover?()
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let items = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] else { return false }
        
        for url in items {
            let newItem = StoredItem(url: url)
            NotificationCenter.default.post(name: .newItemAdded, object: newItem)
        }
        
        return true
    }
}

struct FileSize {
    static func string(from bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useBytes, .useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }
}

struct StoredItem: Identifiable, Codable, Equatable {
    let id = UUID()
    let urlString: String
    let createdAt: Date
    let fileSize: Int64
    
    var url: URL {
        URL(fileURLWithPath: urlString)
    }
    
    var name: String {
        url.lastPathComponent
    }
    
    var icon: NSImage? {
        NSWorkspace.shared.icon(forFile: url.path)
    }
    
    var formattedSize: String {
        FileSize.string(from: fileSize)
    }
    
    init(url: URL) {
        self.urlString = url.path
        self.createdAt = Date()
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            self.fileSize = attributes[.size] as? Int64 ?? 0
        } catch {
            self.fileSize = 0
        }
    }
}

struct StoredItemView: View {
    let item: StoredItem
    let onDelete: () -> Void
    @State private var isHovered = false
    @State private var isDragging = false
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = item.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .cornerRadius(6)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text(item.name)
                    .lineLimit(1)
                    .font(.system(size: 13, weight: .medium))
                
                HStack(spacing: 8) {
                    Text(item.createdAt, style: .relative)
                    Text("•")
                    Text(item.formattedSize)
                }
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red.opacity(0.8))
                    .font(.system(size: 12, weight: .medium))
            }
            .buttonStyle(PlainButtonStyle())
            .opacity(isHovered ? 1 : 0.8)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(isHovered ? Color(NSColor.selectedContentBackgroundColor).opacity(0.1) : Color.clear)
        .contentShape(Rectangle())
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            Button("Show in Finder") {
                NSWorkspace.shared.selectFile(item.url.path, inFileViewerRootedAtPath: "")
            }
            
            Button("Open") {
                NSWorkspace.shared.open(item.url)
            }
            
            Divider()
            
            Button("Delete", role: .destructive) {
                onDelete()
            }
        }
        .draggable(item.url) {
            HStack {
                if let icon = item.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 32, height: 32)
                }
                Text(item.name)
                    .font(.system(size: 12))
            }
            .padding(8)
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(8)
            .shadow(radius: 4)
        }
        .opacity(isDragging ? 0.5 : 1.0)
        .onChange(of: isDragging) { newValue in
            withAnimation(.easeInOut(duration: 0.2)) {
                isDragging = newValue
            }
        }
    }
}

struct NotchStorageView: View {
    @State private var storedItems: [StoredItem] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    private let sharingCoordinator = SharingCoordinator()
    let onDismiss: () -> Void
    private var totalSize: Int64 {
        storedItems.reduce(0) { $0 + $1.fileSize }
    }
    let maxStorageSize: Int64 = 1024 * 1024 * 500 // 500 MB
    
    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            content
            Divider()
            footer
        }
        .background(Color(NSColor.windowBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
        .onAppear {
            loadItems()
            setupNotificationObserver()
        }
    }
    
    private var header: some View {
        HStack {
            Image(systemName: "tray.fill")
                .font(.system(size: 14))
                .foregroundColor(.blue)
            Text("Storage")
                .font(.system(size: 14, weight: .semibold))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var content: some View {
        Group {
            if storedItems.isEmpty {
                VStack(spacing: 12) {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Image(systemName: "arrow.up.doc.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.blue)
                        )
                    Text("Drop Files Here")
                        .font(.system(size: 14, weight: .medium))
                    Text("Maximum file size: 500MB")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(storedItems) { item in
                            StoredItemView(item: item) {
                                withAnimation {
                                    deleteItem(item)
                                }
                            }
                            
                            if item != storedItems.last {
                                Divider()
                                    .padding(.leading, 52)
                            }
                        }
                    }
                }
                .frame(maxHeight: 300)
            }
        }
    }
    
    private var footer: some View {
        HStack {
            if storedItems.isEmpty {
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                    Text("0 items")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            } else {
                Button(action: {
                    withAnimation {
                        storedItems.removeAll()
                        saveItems()
                    }
                }) {
                    Label("Clear All", systemImage: "trash")
                        .font(.system(size: 12))
                }
                .buttonStyle(BorderlessButtonStyle())
                
                Spacer()
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                    Text("\(storedItems.count) items • \(FileSize.string(from: totalSize))")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: shareViaAirDrop) {
                    Label("AirDrop", systemImage: "square.and.arrow.up")
                        .font(.system(size: 12))
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private func deleteItem(_ item: StoredItem) {
        if let index = storedItems.firstIndex(of: item) {
            storedItems.remove(at: index)
            saveItems()
        }
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: .newItemAdded,
            object: nil,
            queue: .main
        ) { notification in
            if let newItem = notification.object as? StoredItem {
                handleNewItem(newItem)
            }
        }
    }
    
    private func handleNewItem(_ newItem: StoredItem) {
        do {
            // Check file size
            let attributes = try FileManager.default.attributesOfItem(atPath: newItem.url.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            
            if fileSize > maxStorageSize {
                showAlert("File is too large (max 500MB)")
                return
            }
            
            // Simple duplicate check - if file already exists, just show alert
            if storedItems.contains(where: { $0.name == newItem.name }) {
                showAlert("This file is already in storage")
                return
            }
            
            // If no duplicate, add the new item
            withAnimation {
                storedItems.insert(newItem, at: 0)
                saveItems()
            }
            
        } catch {
            showAlert("Failed to add file")
        }
    }
    
    private func shareViaAirDrop() {
        guard !storedItems.isEmpty else { return }
        
        let urls = storedItems.map { $0.url }
        if let sharing = NSSharingService(named: NSSharingService.Name.sendViaAirDrop) {
            sharing.delegate = sharingCoordinator
            sharing.perform(withItems: urls)
        }
    }
    
    private func showAlert(_ message: String) {
        alertMessage = message
        showingAlert = true
    }
    
    private func saveItems() {
        if let data = try? JSONEncoder().encode(storedItems) {
            UserDefaults.standard.set(data, forKey: "storedItems")
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "storedItems"),
           let items = try? JSONDecoder().decode([StoredItem].self, from: data) {
            storedItems = items
        }
    }
}

class SharingCoordinator: NSObject, NSSharingServiceDelegate {
    func sharingService(_ sharingService: NSSharingService, willShareItems items: [Any]) {}
    
    func sharingService(_ sharingService: NSSharingService, didShareItems items: [Any]) {}
    
    func sharingService(_ sharingService: NSSharingService, didFailToShareItems items: [Any], error: Error) {
        print("Failed to share items: \(error.localizedDescription)")
    }
}

extension Notification.Name {
    static let newItemAdded = Notification.Name("newItemAdded")
}

extension URL: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .item) { url in
            SentTransferredFile(url)
        } importing: { received in
            let copy = URL(filePath: received.file.path)
            return copy
        }
    }
}
