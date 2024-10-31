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


struct ContentView: View {
    let products = [
        Product(name: "Matcha Latte",
               price: "$5.50",
               imageUrl: "https://images.unsplash.com/photo-1525873997897-06394acfbd35",
               description: "Ceremonial grade matcha, oat milk",
               category: "Signature"),
        Product(name: "Pour Over",
               price: "$6.00",
               imageUrl: "https://images.unsplash.com/photo-1545665225-b23b99e4d45e",
               description: "Single origin Ethiopian beans",
               category: "Coffee"),
        Product(name: "Hojicha Latte",
               price: "$5.50",
               imageUrl: "https://images.unsplash.com/photo-1544787219-7f47ccb76574",
               description: "Roasted green tea, honey",
               category: "Signature"),
        Product(name: "Vanilla Bean Scone",
               price: "$4.00",
               imageUrl: "https://images.unsplash.com/photo-1586444248902-2f64eddc13df",
               description: "Made fresh daily",
               category: "Pastries")
    ]
    
    let events = [
        CafeEvent(
            title: "Matcha Brewing Workshop",
            date: "Nov 2",
            time: "2:00 PM - 3:30 PM",
            description: "Learn the art of preparing the perfect matcha from our tea master. Includes tasting session.",
            spots: 6
        ),
        CafeEvent(
            title: "Coffee Cupping Experience",
            date: "Nov 8",
            time: "10:30 AM - 12:00 PM",
            description: "Explore different coffee origins and learn to identify subtle flavor notes.",
            spots: 8
        ),
        CafeEvent(
            title: "Mindful Morning Meditation",
            date: "Nov 15",
            time: "8:00 AM - 9:00 AM",
            description: "Start your day with guided meditation and a complimentary signature drink.",
            spots: 10
        )
    ]
    
    let coffeeQuotes = [
        "Life begins after coffee",
        "Coffee: a hug in a mug",
        "But first, coffee",
        "Today's mood: Coffee & Kindness",
        "Coffee is always a good idea",
        "May your coffee be strong & your day be light"
    ]
    
    @State private var selectedCategory: String = "All"
    @State private var currentQuote: String
    @State private var quoteOpacity: Double = 1
    @State private var contentChangeIndex: Int = 0
    @State private var cartItems: [Product: Int] = [:]
    @State private var showingProductDetail: Product?
    @State private var showingCart: Bool = false
    
    let categories = ["All", "Signature", "Coffee", "Pastries"]
    let timer = Timer.publish(every: 7, on: .main, in: .common).autoconnect()
    
    init() {
        _currentQuote = State(initialValue: coffeeQuotes[0])
    }
    
    var cartTotal: Double {
        cartItems.reduce(0) { total, item in
            let price = Double(item.key.price.dropFirst()) ?? 0 // Remove $ and convert to Double
            return total + (price * Double(item.value))
        }
    }
    
    var totalItemsInCart: Int {
        cartItems.values.reduce(0, +)
    }
    
    var body: some View {
        ZStack {
            Color(red: 244/255, green: 242/255, blue: 237/255)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 35) {
                    // Hero Section
                    VStack(alignment: .leading, spacing: 15) {
                        Text("さくら茶房")
                            .tracking(8)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.textSecondary)
                        
                        Text("Mindful Moments,\nCrafted Daily")
                            .font(.system(size: 40, weight: .light))
                            .foregroundColor(Theme.text)
                            .lineSpacing(10)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 25)
                    .padding(.top, 40)
                    
                    // Enhanced Quote Card with Animation
                    Text(currentQuote)
                        .font(.system(size: 18, weight: .light, design: .serif))
                        .italic()
                        .foregroundColor(Color(red: 120/255, green: 110/255, blue: 100/255))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 25)
                        .cornerRadius(20)
                        .padding(.horizontal, 25)
                        .opacity(quoteOpacity)
                    
                    // Seasonal Special Section
                    SeasonalSpecialView()
                    
                    // Customer Reviews Section
                    ReviewCarousel()
                    
                    // Community Events Section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("COMMUNITY EVENTS")
                            .tracking(4)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Theme.textSecondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(events, id: \.id) { event in
                                    EventCard(event: event)
                                        .frame(width: 300)
                                }
                            }
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding(.horizontal, 25)
                    
                    // Product List Section
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Text("MENU")
                                .tracking(4)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color(red: 120/255, green: 110/255, blue: 100/255))
                            
                            Spacer()
                            
                            if totalItemsInCart > 0 {
                                Button(action: { showingCart = true }) {
                                    HStack(spacing: 5) {
                                        Image(systemName: "cart")
                                        Text("\(totalItemsInCart)")
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Theme.primary)
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                                }
                            }
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(categories, id: \.self) { category in
                                    CategoryPill(
                                        title: category,
                                        isSelected: selectedCategory == category
                                    ) {
                                        selectedCategory = category
                                    }
                                }
                            }
                            .padding(.horizontal, 5)
                        }
                        
                        ForEach(filteredProducts, id: \.id) { product in
                            ProductRow(product: product, cartItems: $cartItems, showingProductDetail: $showingProductDetail)
                        }
                    }
                    .padding(.horizontal, 25)
                }
                .padding(.bottom, 30)
                .onReceive(timer) { _ in
                    withAnimation(.easeOut(duration: 1)) {
                        quoteOpacity = 0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        contentChangeIndex = (contentChangeIndex + 1) % min(coffeeQuotes.count, 4)
                        currentQuote = coffeeQuotes[contentChangeIndex]
                        withAnimation(.easeIn(duration: 1)) {
                            quoteOpacity = 1
                        }
                    }
                }
            }
        }
        .sheet(item: $showingProductDetail) { product in
            NavigationView {
                ProductDetailView(product: product)
            }
        }
        .sheet(isPresented: $showingCart) {
            CartView(cartItems: $cartItems, total: cartTotal)
        }
    }
    
    var filteredProducts: [Product] {
        if selectedCategory == "All" {
            return products
        } else {
            return products.filter { $0.category == selectedCategory }
        }
    }
}

struct CartView: View {
    @Binding var cartItems: [Product: Int]
    let total: Double
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(Array(cartItems.keys), id: \.id) { product in
                        if let quantity = cartItems[product], quantity > 0 {
                            HStack {
                                AsyncImage(url: URL(string: product.imageUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } placeholder: {
                                    Rectangle()
                                        .foregroundColor(Theme.backgroundSecondary)
                                }
                                .frame(width: 60, height: 60)
                                .cornerRadius(10)
                                
                                VStack(alignment: .leading) {
                                    Text(product.name)
                                        .font(.system(size: 16, weight: .medium))
                                    Text(product.price)
                                        .font(.system(size: 14))
                                        .foregroundColor(Theme.textSecondary)
                                }
                                
                                Spacer()
                                
                                HStack(spacing: 15) {
                                    Button(action: {
                                        if cartItems[product, default: 0] > 0 {
                                            cartItems[product]! -= 1
                                            if cartItems[product] == 0 {
                                                cartItems.removeValue(forKey: product)
                                            }
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(Theme.textSecondary)
                                    }
                                    
                                    Text("\(quantity)")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Button(action: {
                                        cartItems[product]! += 1
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(Theme.primary)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(15)
                        }
                    }
                    
                    if !cartItems.isEmpty {
                        VStack(spacing: 10) {
                            HStack {
                                Text("Total")
                                    .font(.system(size: 18, weight: .medium))
                                Spacer()
                                Text(String(format: "$%.2f", total))
                                    .font(.system(size: 18, weight: .bold))
                            }
                            
                            Button(action: {
                                // Implement checkout functionality
                            }) {
                                Text("Checkout")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.primary)
                                    .cornerRadius(15)
                            }
                        }
                        .padding(.top, 20)
                    }
                }
                .padding()
            }
            .navigationTitle("Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Theme.textSecondary)
                    }
                }
            }
        }
    }
}

struct SeasonalSpecial {
    let title: String
    let subtitle: String
    let imageUrl: String
}
struct SeasonalSpecialView: View {
    let seasonalSpecial = SeasonalSpecial(
        title: "Autumn Collection",
        subtitle: "Pumpkin Spice & Everything Nice",
        imageUrl: "https://images.unsplash.com/photo-1512568400610-62da28bc8a13"
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("SEASONAL SPECIAL")
                .tracking(4)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.textSecondary)
            
            ZStack(alignment: .bottom) {
                AsyncImage(url: URL(string: seasonalSpecial.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .foregroundColor(Theme.backgroundSecondary)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure(_):
                        Rectangle()
                            .foregroundColor(Theme.backgroundSecondary)
                    @unknown default:
                        Rectangle()
                            .foregroundColor(Theme.backgroundSecondary)
                    }
                }
                .frame(height: 400)
                .clipped()
                .cornerRadius(30)
                
                // Overlay content
                VStack(alignment: .leading, spacing: 10) {
                    Text(seasonalSpecial.title)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(seasonalSpecial.subtitle)
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(25)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.black.opacity(0.7), .clear]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .cornerRadius(30)
            }
        }
        .padding(.horizontal, 25)
    }
}
struct ReviewCarousel: View {
    let reviews = [
        ("Autumn Ray", "Best matcha latte in town! The ambiance is perfect for both work and casual meetups."),
        ("Pratik Ray", "Their pour-over coffee is a game changer. Love the minimal aesthetic too!"),
        ("Pranav Ray", "Such a peaceful spot with amazing pastries. My new favorite café!")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("WHAT PEOPLE SAY")
                .tracking(4)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 120/255, green: 110/255, blue: 100/255))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(reviews, id: \.0) { review in
                        ReviewCard(name: review.0, text: review.1)
                    }
                }
                .padding(.horizontal, 5)
            }
        }
        .padding(.horizontal, 25)
    }
}

struct ReviewCard: View {
    let name: String
    let text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("★★★★★")
                .foregroundColor(Color(red: 180/255, green: 160/255, blue: 140/255))
            
            Text(text)
                .font(.system(size: 15))
                .foregroundColor(Color(red: 66/255, green: 66/255, blue: 66/255))
                .frame(width: 250)
            
            Text("- \(name)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(red: 120/255, green: 110/255, blue: 100/255))
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}


struct Product: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let price: String
    let imageUrl: String
    let description: String
    let category: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct ProductRow: View {
    let product: Product
    @Binding var cartItems: [Product: Int]
    @Binding var showingProductDetail: Product?
    
    var body: some View {
        HStack(spacing: 20) {
            AsyncImage(url: URL(string: product.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .foregroundColor(Color(red: 230/255, green: 228/255, blue: 223/255))
            }
            .frame(width: 80, height: 80)
            .cornerRadius(15)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(product.name)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color(red: 66/255, green: 66/255, blue: 66/255))
                
                Text(product.description)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 120/255, green: 110/255, blue: 100/255))
                
                Text(product.price)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(red: 120/255, green: 110/255, blue: 100/255))
            }
            
            Spacer()
            
            HStack(spacing: 15) {
                if cartItems[product, default: 0] > 0 {
                    Text("\(cartItems[product, default: 0])")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                }
                
                Button(action: {
                    cartItems[product, default: 0] += 1
                    // Add haptic feedback
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 120/255, green: 110/255, blue: 100/255))
                        .padding(12)
                        .background(Color(red: 236/255, green: 234/255, blue: 229/255))
                        .clipShape(Circle())
                }
            }
        }
        .padding(15)
        .background(Color.white)
        .cornerRadius(20)
        .onLongPressGesture {
            showingProductDetail = product
            // Add haptic feedback
            let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
            impactHeavy.impactOccurred()
        }
    }
}

// Add a new ProductDetailView:
struct ProductDetailView: View {
    let product: Product
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                AsyncImage(url: URL(string: product.imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(Theme.backgroundSecondary)
                }
                .frame(height: 300)
                .clipped()
                
                VStack(alignment: .leading, spacing: 15) {
                    Text(product.name)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Theme.text)
                    
                    Text(product.price)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(Theme.textSecondary)
                    
                    Text("Description")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Theme.text)
                        .padding(.top, 10)
                    
                    Text(product.description)
                        .font(.system(size: 16))
                        .foregroundColor(Theme.textSecondary)
                        .lineSpacing(4)
                    
                    Text("Category: \(product.category)")
                        .font(.system(size: 14))
                        .foregroundColor(Theme.textSecondary)
                        .padding(.top, 10)
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Theme.textSecondary)
                }
            }
        }
    }
}

struct CategoryPill: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 15, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color(red: 66/255, green: 66/255, blue: 66/255) : Color.clear)
                .foregroundColor(isSelected ? .white : Color(red: 66/255, green: 66/255, blue: 66/255))
                .cornerRadius(25)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color(red: 66/255, green: 66/255, blue: 66/255), lineWidth: 1)
                        .opacity(isSelected ? 0 : 1)
                )
        }
    }
}

struct Theme {
    static let primary = Color(red: 180/255, green: 160/255, blue: 140/255) // Light brown
    static let background = Color(red: 244/255, green: 242/255, blue: 237/255) // Light cream
    static let backgroundSecondary = Color(red: 230/255, green: 228/255, blue: 223/255) // Slightly darker cream
    static let text = Color(red: 66/255, green: 66/255, blue: 66/255) // Dark gray
    static let textSecondary = Color(red: 120/255, green: 110/255, blue: 100/255) // Medium brown
    static let white = Color.white
}

struct CafeEvent {
    let id = UUID()
    let title: String
    let date: String
    let time: String
    let description: String
    let spots: Int
}

struct EventCard: View {
    let event: CafeEvent
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(event.date)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Theme.textSecondary)
            
            Text(event.title)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(Theme.text)
            
            Text(event.description)
                .font(.system(size: 15))
                .foregroundColor(Theme.textSecondary)
                .lineLimit(2)
            
            HStack {
                Text(event.time)
                    .font(.system(size: 14))
                    .foregroundColor(Theme.textSecondary)
                
                Spacer()
                
                Text("\(event.spots) spots left")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Theme.primary)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

let events = [
    CafeEvent(
        title: "Matcha Brewing Workshop",
        date: "Nov 2",
        time: "2:00 PM - 3:30 PM",
        description: "Learn the art of preparing the perfect matcha from our tea master. Includes tasting session.",
        spots: 6
    ),
    CafeEvent(
        title: "Coffee Cupping Experience",
        date: "Nov 8",
        time: "10:30 AM - 12:00 PM",
        description: "Explore different coffee origins and learn to identify subtle flavor notes.",
        spots: 8
    ),
    CafeEvent(
        title: "Mindful Morning Meditation",
        date: "Nov 15",
        time: "8:00 AM - 9:00 AM",
        description: "Start your day with guided meditation and a complimentary signature drink.",
        spots: 10
    )
]