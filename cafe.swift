import SwiftUI

// NBCApp.swift
@main
struct NBCApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// MARK: - Custom Colors
struct CafeTheme {
    static let background = Color(hex: "FAF3E0")
    static let primary = Color(hex: "7B4B2A")
    static let secondary = Color(hex: "D4A574")
    static let accent = Color(hex: "BB9457")
    static let text = Color(hex: "3E2723")
    static let lightText = Color(hex: "8D6E63")
}

// MARK: - Models
struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: Double
    let imageUrl: String
    let category: String
}

struct SpecialItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: Double
    let imageUrl: String
}

// MARK: - Main View
struct ContentView: View {
    @State private var currentSpecialIndex = 0
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    
    let specialItems = [
        SpecialItem(
            name: "Signature Mocha",
            description: "Rich chocolate combined with our premium espresso",
            price: 5.99,
            imageUrl:"https://images.unsplash.com/photo-1642647390911-77934bc6bc33?q=80&w=2944&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
        ),
        SpecialItem(
            name: "Caramel Macchiato",
            description: "Smooth vanilla-flavored drink marked with espresso",
            price: 6.49,
            imageUrl: "https://images.unsplash.com/photo-1485808191679-5f86510681a2"
        ),
        SpecialItem(
            name: "Artisan Pastry Box",
            description: "Selection of our finest freshly baked pastries",
            price: 12.99,
            imageUrl: "https://images.unsplash.com/photo-1483695028939-5bb13f8648b0"
        )
    ]
    
    let cafeItems = [
        MenuItem(
            name: "Cappuccino",
            description: "Rich espresso with silky steamed milk foam",
            price: 4.99,
            imageUrl: "https://images.unsplash.com/photo-1572442388796-11668a67e53d",
            category: "Coffee"
        ),
        MenuItem(
            name: "Butter Croissant",
            description: "Flaky layers of buttery goodness",
            price: 3.99,
            imageUrl: "https://images.unsplash.com/photo-1555507036-ab1f4038808a",
            category: "Pastry"
        ),
        MenuItem(
            name: "Vanilla Latte",
            description: "Smooth espresso with vanilla and steamed milk",
            price: 4.49,
            imageUrl: "https://images.unsplash.com/photo-1561047029-3000c68339ca",
            category: "Coffee"
        ),
        MenuItem(
            name: "Blueberry Muffin",
            description: "Fresh-baked muffin loaded with wild blueberries",
            price: 3.49,
            imageUrl:"https://images.unsplash.com/photo-1722251172903-cc8774501df7?q=80&w=2400&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
            category: "Pastry"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HeaderView()
                SpecialsCarouselView(
                    items: specialItems,
                    currentIndex: $currentSpecialIndex
                )
                MenuSectionView(items: cafeItems)
            }
        }
        .background(CafeTheme.background)
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentSpecialIndex = (currentSpecialIndex + 1) % specialItems.count
            }
        }
    }
}

// MARK: - Header View
struct HeaderView: View {
    @State private var isAnimating = false
    @State private var currentImageIndex = 0
    let timer = Timer.publish(every: 8, on: .main, in: .common).autoconnect()
    
    let backgroundImageUrls = [
        "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb",
        "https://images.unsplash.com/photo-1445116572660-236099ec97a0",
        "https://images.unsplash.com/photo-1554118811-1e0d58224f24",
        "https://images.unsplash.com/photo-1493857671505-72967e2e2760",
        "https://images.unsplash.com/photo-1521017432531-fbd92d768814"
    ]
    
    var body: some View {
        ZStack {
            // Background Image Carousel
            TabView(selection: $currentImageIndex) {
                ForEach(0..<backgroundImageUrls.count, id: \.self) { index in
                    CachedAsyncImage(url: backgroundImageUrls[index]) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 260)
                            .clipped()
                    } placeholder: {
                        Rectangle()
                            .fill(CafeTheme.secondary.opacity(0.3))
                            .frame(height: 260)
                            .overlay(
                                ProgressView()
                                    .tint(CafeTheme.primary)
                            )
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 260)
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        CafeTheme.primary.opacity(0.8),
                        CafeTheme.primary.opacity(0.4)
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            
            // Image Indicators
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<backgroundImageUrls.count, id: \.self) { index in
                        Circle()
                            .fill(Color.white.opacity(currentImageIndex == index ? 1 : 0.5))
                            .frame(width: 6, height: 6)
                            .scaleEffect(currentImageIndex == index ? 1.2 : 1)
                            .animation(.spring(response: 0.3), value: currentImageIndex)
                    }
                }
                .padding(.bottom, 8)
            }
            
            // Content
            VStack(spacing: 16) {
                Text("Cozy Corner Café")
                    .font(.custom("Avenir-Heavy", size: 38))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
                
                Text("Handcrafted with Love")
                    .font(.custom("Avenir-Medium", size: 22))
                    .foregroundColor(.white.opacity(0.95))
                    .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                
                HStack(spacing: 20) {
                    HeaderInfoPill(icon: "clock.fill", text: "7AM - 8PM")
                    HeaderInfoPill(icon: "map.fill", text: "Downtown")
                }
                .padding(.top, 8)
            }
            .padding()
            .background(
                CafeTheme.primary
                    .opacity(0.5)
                    .blur(radius: 20)
            )
            .scaleEffect(isAnimating ? 1 : 0.9)
            .opacity(isAnimating ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 1.0)) {
                currentImageIndex = (currentImageIndex + 1) % backgroundImageUrls.count
            }
        }
    }
}

struct HeaderInfoPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(text)
                .font(.custom("Avenir-Medium", size: 14))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.2))
        .cornerRadius(20)
        .foregroundColor(.white)
    }
}
// MARK: - Specials Carousel
struct SpecialsCarouselView: View {
    let items: [SpecialItem]
    @Binding var currentIndex: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Specials")
                .font(.custom("Avenir-Heavy", size: 24))
                .foregroundColor(CafeTheme.text)
                .padding(.horizontal)
            
            TabView(selection: $currentIndex) {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    SpecialItemCard(item: item)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .frame(height: 300)
        }
        .padding(.vertical)
    }
}

struct SpecialItemCard: View {
    let item: SpecialItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            CachedAsyncImage(url: item.imageUrl) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(CafeTheme.secondary.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .tint(CafeTheme.primary)
                    )
            }
            .frame(height: 200)
            .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.custom("Avenir-Heavy", size: 20))
                    .foregroundColor(CafeTheme.text)
                
                Text(item.description)
                    .font(.custom("Avenir-Medium", size: 16))
                    .foregroundColor(CafeTheme.lightText)
                
                Text("$\(String(format: "%.2f", item.price))")
                    .font(.custom("Avenir-Heavy", size: 18))
                    .foregroundColor(CafeTheme.primary)
            }
            .padding()
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: CafeTheme.primary.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}

// MARK: - Menu Section
struct MenuSectionView: View {
    let items: [MenuItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Menu")
                .font(.custom("Avenir-Heavy", size: 24))
                .foregroundColor(CafeTheme.text)
                .padding(.horizontal)
            
            ForEach(items) { item in
                MenuItemView(item: item)
            }
        }
        .padding(.vertical)
    }
}

struct MenuItemView: View {
    let item: MenuItem
    
    var body: some View {
        HStack(spacing: 15) {
            CachedAsyncImage(url: item.imageUrl) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(CafeTheme.secondary.opacity(0.3))
                    .overlay(
                        ProgressView()
                            .tint(CafeTheme.primary)
                    )
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.custom("Avenir-Heavy", size: 18))
                    .foregroundColor(CafeTheme.text)
                
                Text(item.description)
                    .font(.custom("Avenir-Medium", size: 14))
                    .foregroundColor(CafeTheme.lightText)
                    .lineLimit(2)
                
                Text("$\(String(format: "%.2f", item.price))")
                    .font(.custom("Avenir-Heavy", size: 16))
                    .foregroundColor(CafeTheme.primary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: CafeTheme.primary.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}

// MARK: - Image Caching
actor ImageCache {
    static let shared = ImageCache()
    private var cache: [String: Image] = [:]
    
    func insert(_ image: Image, for key: String) {
        cache[key] = image
    }
    
    func get(_ key: String) -> Image? {
        cache[key]
    }
}

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: String
    private let scale: CGFloat
    private let content: (Image) -> Content
    private let placeholder: () -> Placeholder
    
    @State private var cachedImage: Image? = nil
    @State private var isLoading = true
    
    init(
        url: String,
        scale: CGFloat = 1.0,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.scale = scale
        self.content = content
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let cachedImage = cachedImage {
                content(cachedImage)
                    .transition(.opacity)
            } else {
                placeholder()
                    .transition(.opacity)
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        isLoading = true
        defer { isLoading = false }
        
        // Check cache first
        if let cached = await ImageCache.shared.get(url) {
            withAnimation(.easeIn(duration: 0.2)) {
                cachedImage = cached
            }
            return
        }
        
        // Download if not cached
        guard let imageUrl = URL(string: url),
              let (data, _) = try? await URLSession.shared.data(from: imageUrl),
              let uiImage = UIImage(data: data) else {
            return
        }
        
        let image = Image(uiImage: uiImage)
        await ImageCache.shared.insert(image, for: url)
        
        withAnimation(.easeIn(duration: 0.2)) {
            cachedImage = image
        }
    }
}

