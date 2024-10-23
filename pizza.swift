// PizzaApp.swift
import SwiftUI

@main
struct PizzaApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Models/Pizza.swift
struct Pizza: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let price: Double
    let imageUrl: String
}

// ViewModels/PizzaViewModel.swift
class PizzaViewModel: ObservableObject {
    @Published var pizzas = [
        Pizza(name: "Margherita",
              description: "Fresh tomatoes, mozzarella, basil",
              price: 12.99,
              imageUrl: "https://images.unsplash.com/photo-1574071318508-1cdbab80d002"),
        Pizza(name: "Pepperoni",
              description: "Spicy pepperoni, cheese, tomato sauce",
              price: 14.99,
              imageUrl: "https://images.unsplash.com/photo-1628840042765-356cda07504e"),
        Pizza(name: "Vegetarian",
              description: "Bell peppers, mushrooms, onions",
              price: 13.99,
              imageUrl: "https://images.unsplash.com/photo-1571407970349-bc81e7e96d47")
    ]
}

// Components/PizzaCard.swift
struct PizzaCard: View {
    let pizza: Pizza
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AsyncImage(url: URL(string: pizza.imageUrl)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                ProgressView()
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(pizza.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(pizza.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Text("$\(pizza.price, specifier: "%.2f")")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal)
            
            Button(action: {}) {
                Text("Add to Cart")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(15)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemBackground))
        .cornerRadius(25)
        .shadow(radius: 5)
    }
}

// Views/ContentView.swift
struct ContentView: View {
    @StateObject private var viewModel = PizzaViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HeaderView()
                    
                    LazyVStack(spacing: 20) {
                        ForEach(viewModel.pizzas) { pizza in
                            PizzaCard(pizza: pizza)
                                .padding(.horizontal)
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
        }
    }
}

// Components/HeaderView.swift
struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🍕 Slice of Heaven")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Choose your favorite pizza")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
