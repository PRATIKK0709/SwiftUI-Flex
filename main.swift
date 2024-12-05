import SwiftUI
import AppKit
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    private let _persistentContainer: NSPersistentContainer
    
    // Change this to internal or public
    let persistentContainer: NSPersistentContainer
    
    private init() {
        _persistentContainer = NSPersistentContainer(name: "ClipboardModel")
        _persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data load error: \(error.localizedDescription)")
            }
        }
        
        // Initialize the publicly accessible persistentContainer
        persistentContainer = _persistentContainer
    }
    
    var context: NSManagedObjectContext {
        return _persistentContainer.viewContext
    }
    
    func saveContext() {
        let context = _persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Core Data save error: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

struct ClipboardItem: Identifiable, Equatable {
    let id: UUID
    let content: String
    let timestamp: Date
    let type: ClipboardType
    let imageData: Data?
    var starred: Bool

    enum ClipboardType {
        case text
        case image
    }

    // Update initializer to include starred
    init(id: UUID = UUID(), content: String, timestamp: Date, type: ClipboardType, imageData: Data?, starred: Bool = false) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
        self.type = type
        self.imageData = imageData
        self.starred = starred
    }
}

class ClipboardManager: ObservableObject {
    @Published var clipboardItems: [ClipboardItem] = []
    @Published var monitoringInterval: Double = 0.5
    @Published var maxClipboardItems: Int = 100
    
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private var pasteboard = NSPasteboard.general
    private let context = CoreDataManager.shared.context
    
    init() {
        loadClipboardItems()
        startMonitoring()
    }
        
    func startMonitoring() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: monitoringInterval, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    private func checkClipboard() {
        let changeCount = pasteboard.changeCount
        
        guard changeCount != lastChangeCount else { return }
        lastChangeCount = changeCount
        
        // Check for text
        if let string = pasteboard.string(forType: .string), !string.isEmpty {
            addClipboardItem(content: string, type: .text, imageData: nil)
        }
        
        // Check for image
        if let imageData = pasteboard.data(forType: .tiff) {
            if let image = NSImage(data: imageData) {
                let contentDescription = "Image (\(image.size.width)x\(image.size.height))"
                addClipboardItem(content: contentDescription, type: .image, imageData: imageData)
            }
        }
    }
    
    private func addClipboardItem(content: String, type: ClipboardItem.ClipboardType, imageData: Data? = nil) {
        let newItem = ClipboardItem(content: content, timestamp: Date(), type: type, imageData: imageData)

        // Prevent duplicate entries
        if !clipboardItems.contains(where: { $0.content == content && $0.type == type }) {
            clipboardItems.insert(newItem, at: 0)
            saveToDatabase(newItem)

            // Trim clipboard history if it exceeds max items
            if clipboardItems.count > maxClipboardItems {
                clipboardItems = Array(clipboardItems.prefix(maxClipboardItems))
                trimDatabase(maxCount: maxClipboardItems)
            }
        }
    }


    
    private func saveToDatabase(_ item: ClipboardItem) {
        let entity = ClipboardItemEntity(context: context)
        entity.id = item.id
        entity.content = item.content
        entity.timestamp = item.timestamp
        entity.type = item.type == .text ? "text" : "image"
        entity.imageData = item.imageData
        entity.starred = item.starred  // Add this line

        CoreDataManager.shared.saveContext()
    }

    
    private func loadClipboardItems() {
        let fetchRequest: NSFetchRequest<ClipboardItemEntity> = ClipboardItemEntity.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "starred", ascending: false),
            NSSortDescriptor(key: "timestamp", ascending: false)
        ]
        
        do {
            let entities = try context.fetch(fetchRequest)
            clipboardItems = entities.map { entity in
                ClipboardItem(
                    id: entity.id ?? UUID(),
                    content: entity.content ?? "",
                    timestamp: entity.timestamp ?? Date(),
                    type: entity.type == "text" ? .text : .image,
                    imageData: entity.imageData,
                    starred: entity.starred
                )
            }
        } catch {
            print("Failed to fetch clipboard items: \(error)")
        }
    }

    
    private func trimDatabase(maxCount: Int) {
        let fetchRequest: NSFetchRequest<ClipboardItemEntity> = ClipboardItemEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchOffset = maxCount
        
        do {
            let itemsToDelete = try context.fetch(fetchRequest)
            for item in itemsToDelete {
                context.delete(item)
            }
            CoreDataManager.shared.saveContext()
        } catch {
            print("Failed to trim clipboard items: \(error)")
        }
    }
    
    func deleteItem(_ item: ClipboardItem) {
        clipboardItems.removeAll { $0.id == item.id }
        let fetchRequest: NSFetchRequest<ClipboardItemEntity> = ClipboardItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        do {
            if let entity = try context.fetch(fetchRequest).first {
                context.delete(entity)
                CoreDataManager.shared.saveContext()
            }
        } catch {
            print("Failed to delete clipboard item: \(error)")
        }
    }
    
    func clearAllItems() {
        clipboardItems.removeAll()
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ClipboardItemEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            CoreDataManager.shared.saveContext()
        } catch {
            print("Failed to clear clipboard items: \(error)")
        }
    }
}
extension ClipboardManager {
    func copyToClipboard(_ item: ClipboardItem) {
        pasteboard.clearContents()
        switch item.type {
        case .text:
            pasteboard.setString(item.content, forType: .string)
        case .image:
            if let imageData = item.imageData {
                pasteboard.setData(imageData, forType: .tiff)
            }
        }
    }
}

extension ClipboardManager {
    func toggleStarredStatus(for item: ClipboardItem) {
        // Find the index of the item
        guard let index = clipboardItems.firstIndex(where: { $0.id == item.id }) else {
            return
        }
        
        // Toggle starred status
        var updatedItem = item
        updatedItem.starred.toggle()
        
        // Remove the item from its current position
        clipboardItems.remove(at: index)
        
        // Reinsert the item based on its starred status
        if updatedItem.starred {
            // Move to the top if starred
            clipboardItems.insert(updatedItem, at: 0)
        } else {
            // Find the correct chronological position for non-starred items
            let nonStarredIndex = clipboardItems.firstIndex { !$0.starred } ?? clipboardItems.count
            clipboardItems.insert(updatedItem, at: nonStarredIndex)
        }
        
        // Update in database
        updateStarredStatusInDatabase(updatedItem)
    }
    
    private func updateStarredStatusInDatabase(_ item: ClipboardItem) {
        let fetchRequest: NSFetchRequest<ClipboardItemEntity> = ClipboardItemEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", item.id as CVarArg)
        
        do {
            if let entity = try context.fetch(fetchRequest).first {
                entity.starred = item.starred
                CoreDataManager.shared.saveContext()
            }
        } catch {
            print("Failed to update starred status: \(error)")
        }
    }
    
}
struct ItemCountBadge: View {
    let systemImage: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
                .foregroundColor(color)
                .font(.system(size: 12))

            Text("\(count)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(color)
        }
        .padding(6)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ContentView: View {
    @StateObject private var clipboardManager = ClipboardManager()
    @State private var searchText = ""
    @State private var selectedPreviewItem: ClipboardItem?
    @State private var isPreviewVisible = false
    @State private var isSettingsVisible = false

    var filteredItems: [ClipboardItem] {
        guard !searchText.isEmpty else { return clipboardManager.clipboardItems }
        return clipboardManager.clipboardItems.filter {
            $0.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            Color(white: 0.95)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 0) {
                HStack {
                    SearchBar(text: $searchText)

                    Button(action: {
                        isSettingsVisible = true
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(16)

                ClipboardItemsList(
                    items: filteredItems,
                    clipboardManager: clipboardManager,
                    onPreview: { item in
                        selectedPreviewItem = item
                        isPreviewVisible = true
                    }
                )
            }

            if isPreviewVisible, let previewItem = selectedPreviewItem {
                PreviewView(
                    item: previewItem,
                    isPreviewVisible: $isPreviewVisible
                )
            }

            if isSettingsVisible {
                SettingsView(
                    clipboardManager: clipboardManager,
                    isSettingsVisible: $isSettingsVisible
                )
            }
        }
        .frame(minWidth: 380, minHeight: 600)
    }
}
struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search clipboard...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.black)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct ClearAllButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "trash")
                .foregroundColor(.red)
                .padding(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ClipboardItemsList: View {
    let items: [ClipboardItem]
    let clipboardManager: ClipboardManager
    let onPreview: (ClipboardItem) -> Void
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 12) {
                ForEach(items) { item in
                    ClipboardItemView(
                        item: item,
                        onCopy: { clipboardManager.copyToClipboard(item) },
                        onDelete: {
                            showDeleteConfirmation(for: item)
                        },
                        onPreview: { onPreview(item) },
                        onToggleStar: {
                            clipboardManager.toggleStarredStatus(for: item)
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .scale.combined(with: .opacity)
                    ))
                }
            }
            .padding(16)
        }
    }
    
    private func showDeleteConfirmation(for item: ClipboardItem) {
        let alert = NSAlert()
        alert.messageText = "Delete Clipboard Item"
        alert.informativeText = "Are you sure you want to remove this item?"
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Delete")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            clipboardManager.deleteItem(item)
        }
    }
}

struct PreviewView: View {
    let item: ClipboardItem
    @Binding var isPreviewVisible: Bool
    @State private var copyConfirmation = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .blur(radius: 10)
                .onTapGesture {
                    withAnimation {
                        isPreviewVisible = false
                    }
                }
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(item.type == .text ? "Text Preview" : "Image Preview")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Text(formatTimestamp(item.timestamp))
                            .font(.caption)
                        .foregroundColor(.black)
                    }
                    
                    Spacer()
                    
                    Text(item.type == .text
                         ? "\(item.content.count) characters"
                         : "Image Size: \(getImageSize())")
                        .font(.caption)
                        .foregroundColor(.black)  // Changed to black
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                
                // Content Area
                ScrollView {
                    if item.type == .text {
                        Text(item.content)
                            .font(.system(size: 16, weight: .regular, design: .monospaced))
                            .foregroundColor(.black)
                            .textSelection(.enabled)
                            .padding(20)
                    } else if item.type == .image,
                              let imageData = item.imageData,
                              let nsImage = NSImage(data: imageData) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 300)
                            .cornerRadius(10)
                            .padding(20)
                    }
                }
                .frame(maxHeight: 300)
                
                // Action Buttons
                HStack(spacing: 20) {
                    // Item details
                    HStack {
                        Image(systemName: item.type == .text ? "doc.text" : "photo")
                        Text(item.type == .text
                            ? "\(item.content.components(separatedBy: .whitespacesAndNewlines).count) words"
                            : "Image")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Copy Button
                    Button(action: {
                        NSPasteboard.general.clearContents()
                        
                        if item.type == .text {
                            NSPasteboard.general.setString(item.content, forType: .string)
                        } else if let imageData = item.imageData {
                            NSPasteboard.general.setData(imageData, forType: .tiff)
                        }
                        
                        copyConfirmation = true
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            copyConfirmation = false
                        }
                    }) {
                        HStack {
                            Image(systemName: copyConfirmation ? "checkmark" : "doc.on.clipboard")
                            Text(copyConfirmation ? "Copied!" : "Copy")
                        }
                        .padding(8)
                        .background(copyConfirmation ? Color.green.opacity(0.2) : Color.blue.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(copyConfirmation ? .green : .blue)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Close Button
                    Button("Close") {
                        withAnimation {
                            isPreviewVisible = false
                        }
                    }
                    .padding(8)
                    .background(Color.red.opacity(0.2))
                    .cornerRadius(8)
                    .foregroundColor(.red)
                    .buttonStyle(PlainButtonStyle())
                }
                .padding()
                .background(Color.gray.opacity(0.05))
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
            )
            .padding(20)
            .transition(.asymmetric(
                insertion: .scale.combined(with: .opacity),
                removal: .scale.combined(with: .opacity)
            ))
        }
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func getImageSize() -> String {
        guard let imageData = item.imageData,
              let nsImage = NSImage(data: imageData) else {
            return "Unknown"
        }
        return "\(Int(nsImage.size.width))x\(Int(nsImage.size.height))"
    }
}

struct SettingsView: View {
    @ObservedObject var clipboardManager: ClipboardManager
    @Binding var isSettingsVisible: Bool
    @State private var showClearAllConfirmation = false

    var body: some View {
        ZStack {
            Color(white: 0.95)
                .edgesIgnoringSafeArea(.all)

            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    Text("Clipboard Settings")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)

                    Spacer()

                    Button(action: {
                        withAnimation {
                            isSettingsVisible = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.bottom, 16)

                // Clear Clipboard History
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Clear Clipboard History")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Text("Permanently remove all saved clipboard items")
                            .font(.body)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Button(action: {
                        showClearAllConfirmation = true
                    }) {
                        Text("Clear All")
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.red)
                            .padding(10)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.vertical, 20)

                // Placeholder for future settings
                // You can add more settings here as needed

                Spacer()
            }
            .padding(24)
        }
        .confirmationDialog(
            "Clear Clipboard",
            isPresented: $showClearAllConfirmation,
            titleVisibility: .visible
        ) {
            Button("Clear All Items", role: .destructive) {
                clipboardManager.clearAllItems()
                isSettingsVisible = false
            }
        } message: {
            Text("This will permanently remove all clipboard history. Are you sure?")
                .foregroundColor(.gray)
        }
    }
}

struct ClipboardItemView: View {
    let item: ClipboardItem
    let onCopy: () -> Void
    let onDelete: () -> Void
    let onPreview: () -> Void
    let onToggleStar: () -> Void  // New parameter
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(item.content)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(2)
                    .foregroundColor(.black)
                
                Text(formatTimestamp(item.timestamp))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.gray.opacity(0.7))
            }
            Spacer()
            HStack(spacing: 16) {
                // Star button
                actionButton(
                    systemImage: item.starred ? "star.fill" : "star",
                    color: item.starred ? .yellow : .gray,
                    action: onToggleStar
                )
                actionButton(systemImage: "eye", color: .gray, action: onPreview)
                actionButton(systemImage: "doc.on.clipboard", color: .black, action: onCopy)
                actionButton(systemImage: "trash", color: .red, action: onDelete)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(item.starred ? Color.yellow.opacity(0.1) : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(item.starred ? Color.yellow.opacity(0.3) : Color.gray.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .gray.opacity(0.1), radius: 6, x: 0, y: 4)
        )
    }
    
    
    private func actionButton(systemImage: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .foregroundColor(color)
                .padding(8)
                .background(color.opacity(0.1))
                .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

@main
struct ClipboardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 600)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
    }
}
