// ColorTheme.swift
import SwiftUI

@main
struct CafeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct Theme {
    static let primary = Color(hex: "A67356")       // Warm brown
    static let secondary = Color(hex: "DED1BD")     // Light beige
    static let background = Color(hex: "FAF7F2")    // Cream white
    static let text = Color(hex: "2C1810")          // Dark brown
    static let accent = Color(hex: "E8B298")        // Peachy brown
}

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
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// ContentView.swift
struct ContentView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                HeaderView()
                FeaturedItemsView()
                MenuSectionView(title: "Signature Drinks", items: mockDrinks)
                MenuSectionView(title: "Artisanal Pastries", items: mockPastries)
            }
            .padding(.bottom, 30)
        }
        .background(Theme.background)
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

struct HeaderView: View {
    var body: some View {
        VStack(spacing: 15) {
            Circle()
                .fill(Theme.secondary)
                .frame(width: 80, height: 80)
                .overlay(
                    Text("B&B")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(Theme.primary)
                )
            
            Text("Brew & Bake")
                .font(.system(size: 32, weight: .bold, design: .serif))
                .foregroundColor(Theme.text)
            
            Text("EST. 2024")
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundColor(Theme.primary)
                .tracking(2)
        }
        .padding(.vertical, 30)
    }
}

struct FeaturedItemsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Featured")
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(Theme.text)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(mockFeatured) { item in
                        FeaturedItemCard(item: item)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct FeaturedItemCard: View {
    let item: MenuItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: URL(string: item.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Theme.secondary)
            }
            .frame(width: 300, height: 200)
            .clipped()
            .cornerRadius(20)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(Theme.text)
                
                Text(item.description)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(Theme.text.opacity(0.8))
                    .lineLimit(2)
                
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.primary)
            }
            .padding(.horizontal, 8)
        }
        .frame(width: 300)
        .background(Theme.background)
        .cornerRadius(20)
        .shadow(color: Theme.text.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct MenuSectionView: View {
    let title: String
    let items: [MenuItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .serif))
                .foregroundColor(Theme.text)
                .padding(.horizontal)
            
            VStack(spacing: 15) {
                ForEach(items) { item in
                    MenuItemCard(item: item)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct MenuItemCard: View {
    let item: MenuItem
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: item.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Theme.secondary)
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 15))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(item.name)
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundColor(Theme.text)
                
                Text(item.description)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.text.opacity(0.8))
                    .lineLimit(2)
                
                Text("$\(item.price, specifier: "%.2f")")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(Theme.background)
        .cornerRadius(20)
        .shadow(color: Theme.text.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// Models
struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: Double
    let imageUrl: String
}

// Mock Data with Unsplash Images
let mockFeatured: [MenuItem] = [
    MenuItem(
        name: "Signature Latte",
        description: "House-made vanilla syrup, espresso, steamed milk",
        price: 4.99,
        imageUrl: "https://images.unsplash.com/photo-1541167760496-1628856ab772"
    ),
    MenuItem(
        name: "Almond Croissant",
        description: "Flaky croissant filled with almond cream",
        price: 3.99,
        imageUrl: "https://images.unsplash.com/photo-1509440159596-0249088772ff"
    )
]

let mockDrinks: [MenuItem] = [
    MenuItem(
        name: "Cappuccino",
        description: "Classic Italian coffee with equal parts espresso, steamed milk, and foam",
        price: 4.49,
        imageUrl: "https://images.unsplash.com/photo-1572442388796-11668a67e53d"
    ),
    MenuItem(
        name: "Cold Brew",
        description: "Smooth, slow-steeped cold coffee",
        price: 4.29,
        imageUrl: "https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5"
    )
]

let mockPastries: [MenuItem] = [
    MenuItem(
        name: "Pain au Chocolat",
        description: "Chocolate-filled croissant",
        price: 3.79,
        imageUrl: "https://images.unsplash.com/photo-1555507036-ab1f4038808a"
    ),
    MenuItem(
        name: "Blueberry Muffin",
        description: "Fresh-baked muffin with wild blueberries",
        price: 3.29,
        imageUrl: "https://images.unsplash.com/photo-1587830076878-36cb8c1f6513"
    )
]
