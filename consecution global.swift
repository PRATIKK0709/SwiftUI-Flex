import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
    }
}

// Updated ThemeColors for Client Section
struct ClientThemeColors {
    static let background = Color(red: 0.10, green: 0.12, blue: 0.16)
    static let secondaryBackground = Color(red: 0.15, green: 0.18, blue: 0.23)
    static let accent = Color(red: 0.4, green: 0.5, blue: 0.6)
    static let text = Color.white
    static let secondaryText = Color(red: 0.7, green: 0.75, blue: 0.8)
}

// Updated ThemeColors for Student Section
struct StudentThemeColors {
    static let background = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let secondaryBackground = Color.white
    static let accent = Color(red: 0.3, green: 0.4, blue: 0.5)
    static let text = Color.black
    static let secondaryText = Color(red: 0.4, green: 0.4, blue: 0.4)
}

struct ThemeColors {
    static let background = Color(red: 0.12, green: 0.12, blue: 0.12) // Darker background
    static let secondaryBackground = Color(red: 0.18, green: 0.18, blue: 0.18) // Slightly lighter for contrast
    static let accent = Color(red: 0.6, green: 0.6, blue: 0.6) // Light grey accent
    static let text = Color.white
    static let secondaryText = Color(red: 0.7, green: 0.7, blue: 0.7) // Light grey for secondary text
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                ThemeColors.background.edgesIgnoringSafeArea(.all)
                VStack(spacing: 50) {
                    Image(systemName: "circle.hexagongrid.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150, height: 150)
                        .foregroundColor(ThemeColors.accent)
                        .shadow(color: ThemeColors.accent.opacity(0.5), radius: 10, x: 0, y: 5)
                    
                    Text("Welcome")
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .foregroundColor(ThemeColors.text)
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)
                    
                    VStack(spacing: 30) {
                        NavigationLink(destination: ClientLoginView()) {
                            LoginButton(title: "Client Login", color: Color.blue.opacity(0.7))
                        }
                        
                        NavigationLink(destination: StudentLoginView()) {
                            LoginButton(title: "Student Login", color: Color.white.opacity(0.7))
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
            .navigationBarHidden(true)
        }
    }
}

struct LoginButton: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .foregroundColor(ThemeColors.background)
            .frame(height: 65)
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: color.opacity(0.5), radius: 10, x: 0, y: 5)
    }
}

// Updated ClientLoginView
struct ClientLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showingClientHome = false

    var body: some View {
        ZStack {
            ClientThemeColors.background.edgesIgnoringSafeArea(.all)
            VStack(spacing: 40) {
                Text("Client Login")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(ClientThemeColors.text)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 2)

                VStack(spacing: 25) {
                    ClientCustomTextField(text: $email, placeholder: "Email", imageName: "envelope")
                    ClientCustomTextField(text: $password, placeholder: "Password", imageName: "lock", isSecure: true)
                }

                Button(action: {
                    showingClientHome = true
                }) {
                    ClientLoginButton(title: "Login")
                }
            }
            .padding(.horizontal, 30)
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingClientHome) {
            ClientHomeView()
        }
    }
}

struct ClientCustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let imageName: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(ClientThemeColors.accent)
                .frame(width: 30)
            if isSecure {
                SecureField(placeholder, text: $text)
            } else {
                TextField(placeholder, text: $text)
            }
        }
        .padding()
        .background(ClientThemeColors.secondaryBackground.opacity(0.7))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(ClientThemeColors.accent.opacity(0.5), lineWidth: 1)
        )
        .foregroundColor(ClientThemeColors.text)
    }
}

struct ClientLoginButton: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .foregroundColor(ClientThemeColors.background)
            .frame(height: 65)
            .frame(maxWidth: .infinity)
            .background(ClientThemeColors.accent)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: ClientThemeColors.accent.opacity(0.5), radius: 10, x: 0, y: 5)
    }
}

// Updated StudentLoginView
struct StudentLoginView: View {
    @State private var collegeID = ""
    @State private var showingStudentHome = false

    var body: some View {
        ZStack {
            StudentThemeColors.background.edgesIgnoringSafeArea(.all)
            VStack(spacing: 40) {
                Text("Student Login")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundColor(StudentThemeColors.text)
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)

                StudentCustomTextField(text: $collegeID, placeholder: "College ID", imageName: "person.badge.key")
                    .padding(.horizontal, 20)

                Button(action: {
                    showingStudentHome = true
                }) {
                    StudentLoginButton(title: "Login")
                }
                .padding(.horizontal, 20)
            }
            .padding()
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showingStudentHome) {
            StudentHomeView()
        }
    }
}

struct StudentCustomTextField: View {
    @Binding var text: String
    let placeholder: String
    let imageName: String
    
    var body: some View {
        HStack {
            Image(systemName: imageName)
                .foregroundColor(StudentThemeColors.accent)
                .frame(width: 30)
            TextField(placeholder, text: $text)
        }
        .padding()
        .background(StudentThemeColors.secondaryBackground)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(StudentThemeColors.accent.opacity(0.5), lineWidth: 1)
        )
        .foregroundColor(StudentThemeColors.text)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StudentLoginButton: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(.system(size: 20, weight: .semibold, design: .rounded))
            .foregroundColor(StudentThemeColors.secondaryBackground)
            .frame(height: 65)
            .frame(maxWidth: .infinity)
            .background(StudentThemeColors.accent)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: StudentThemeColors.accent.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

struct ClientHomeView: View {
    var body: some View {
        TabView {
            StatisticsView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
            
            EventsView()
                .tabItem {
                    Label("Events", systemImage: "calendar")
                }
            
            InvoicesContactsView()
                .tabItem {
                    Label("Invoices", systemImage: "doc.text.fill")
                }
            
            ContactUsView()
                .tabItem {
                    Label("Contact", systemImage: "envelope.fill")
                }
        }
        .accentColor(ThemeColors.accent)
    }
}

struct StatisticsView: View {
    var body: some View {
        ZStack {
            ThemeColors.background.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(spacing: 25) {
                    StatCard(title: "Past Events", value: "12", icon: "clock.fill", color: .blue)
                    StatCard(title: "Profit/Loss", value: "$5,000", icon: "dollarsign.circle.fill", color: .green)
                    StatCard(title: "Sales", value: "$25,000", icon: "cart.fill", color: .orange)
                    StatCard(title: "Referrals", value: "8", icon: "link", color: ThemeColors.accent)
                }
                .padding()
            }
        }
        .navigationBarTitle("Statistics", displayMode: .large)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundColor(color)
                .frame(width: 70)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(ThemeColors.secondaryText)
                Text(value)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(ThemeColors.text)
            }
            Spacer()
        }
        .padding()
        .background(ThemeColors.secondaryBackground.opacity(0.8))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}

struct EventsView: View {
    var body: some View {
        ZStack {
            ThemeColors.background.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(1...5, id: \.self) { index in
                        EventCard(title: "Future Event \(index)", date: "2024-11-\(index+10)", description: "Join us for an exciting event filled with networking opportunities and insightful presentations.")
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle("Upcoming Events", displayMode: .large)
    }
}

struct EventCard: View {
    let title: String
    let date: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(ThemeColors.text)
            
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(ThemeColors.accent)
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.secondaryText)
            }
            
            Text(description)
                .font(.body)
                .foregroundColor(ThemeColors.secondaryText)
                .lineLimit(3)
            
            Button(action: {
                // Action to view event details
            }) {
                Text("Learn More")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(ThemeColors.background)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(ThemeColors.accent)
                    .cornerRadius(20)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(ThemeColors.secondaryBackground.opacity(0.8))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct EventRow: View {
    let title: String
    let date: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(ThemeColors.text)
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(ThemeColors.secondaryText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(ThemeColors.accent)
        }
        .padding()
        .background(ThemeColors.secondaryBackground.opacity(0.8))
        .cornerRadius(15)
    }
}


struct InvoicesContactsView: View {
    var body: some View {
        ZStack {
            ThemeColors.background.edgesIgnoringSafeArea(.all)
            List {
                Section(header: Text("Invoices").foregroundColor(ThemeColors.accent)) {
                    ForEach(1...3, id: \.self) { index in
                        InvoiceRow(number: index, amount: Double(index * 100))
                    }
                }
                
                Section(header: Text("Contacts").foregroundColor(ThemeColors.accent)) {
                    ForEach(1...5, id: \.self) { index in
                        ContactRow(name: "Contact \(index)", email: "contact\(index)@example.com")
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarTitle("Invoices & Contacts", displayMode: .large)
    }
}

struct InvoiceRow: View {
    let number: Int
    let amount: Double
    
    var body: some View {
        HStack {
            Text("Invoice #\(number)")
                .foregroundColor(ThemeColors.text)
            Spacer()
            Text("$\(amount, specifier: "%.2f")")
                .foregroundColor(ThemeColors.accent)
        }
    }
}

struct ContactRow: View {
    let name: String
    let email: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
                .foregroundColor(ThemeColors.text)
            Text(email)
                .font(.subheadline)
                .foregroundColor(ThemeColors.secondaryText)
        }
    }
}

struct ContactUsView: View {
    @State private var message = ""
    
    var body: some View {
        ZStack {
            ThemeColors.background.edgesIgnoringSafeArea(.all)
            VStack(spacing: 30) {
                Text("Send us a message")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(ThemeColors.text)
                
                TextEditor(text: $message)
                    .foregroundColor(ThemeColors.text)
                    .background(ThemeColors.secondaryBackground.opacity(0.8))
                    .cornerRadius(15)
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(ThemeColors.accent.opacity(0.5), lineWidth: 1)
                    )
                
                Button(action: {
                    // Send message action
                }) {
                    Text("Send")
                        .font(.headline)
                        .foregroundColor(ThemeColors.text)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(Color.blue.opacity(0.7))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
            }
            .padding(30)
        }
        .navigationBarTitle("Contact Us", displayMode: .large)
    }
}

struct StudentHomeView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Label("Feed", systemImage: "list.bullet")
                }
            
            MyPointsView()
                .tabItem {
                    Label("Points", systemImage: "star.fill")
                }
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
            
            AboutMeView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
        .accentColor(.green)
    }
}

struct FeedView: View {
    var body: some View {
        ZStack {
            ThemeColors.background.edgesIgnoringSafeArea(.all)
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(1...10, id: \.self) { index in
                        FeedCard(title: "Exciting News \(index)",
                                 description: "Get ready for an amazing update! We're introducing new features that will revolutionize your experience.",
                                 imageSystemName: "star.fill",
                                 date: "May \(index), 2024")
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle("Latest Updates", displayMode: .large)
    }
}

struct FeedCard: View {
    let title: String
    let description: String
    let imageSystemName: String
    let date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: imageSystemName)
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                    .frame(width: 40, height: 40)
                    .background(Color.green.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(ThemeColors.text)
                    Text(date)
                        .font(.caption)
                        .foregroundColor(ThemeColors.secondaryText)
                }
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(ThemeColors.secondaryText)
                .lineLimit(3)
            
            Button(action: {
                // Action to read more
            }) {
                Text("Read More")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(ThemeColors.secondaryBackground.opacity(0.8))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct MyPointsView: View {
    @State private var points = 1000
    
    var body: some View {
        ZStack {
            ThemeColors.background.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(spacing: 30) {
                    PointsCard(points: points)
                    
                    RecentActivityList()
                    
                    RedeemPointsSection()
                }
                .padding()
            }
        }
        .navigationBarTitle("My Points", displayMode: .large)
    }
}

struct PointsCard: View {
    let points: Int
    
    var body: some View {
        VStack(spacing: 20) {
            Text("\(points)")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(.green)
            
            Text("Total Points")
                .font(.title2)
                .foregroundColor(ThemeColors.text)
            
            HStack(spacing: 20) {
                PointActionButton(title: "Earn", systemImage: "plus.circle.fill")
                PointActionButton(title: "Redeem", systemImage: "gift.fill")
            }
        }
        .padding()
        .background(ThemeColors.secondaryBackground.opacity(0.8))
        .cornerRadius(25)
        .shadow(color: Color.green.opacity(0.2), radius: 15, x: 0, y: 10)
    }
}

struct PointActionButton: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        Button(action: {
            // Action for earn/redeem
        }) {
            HStack {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.headline)
            .foregroundColor(ThemeColors.background)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.green)
            .cornerRadius(15)
        }
    }
}

struct RecentActivityList: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.text)
            
            ForEach(1...5, id: \.self) { index in
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 10, height: 10)
                    Text("Completed Task \(index)")
                        .foregroundColor(ThemeColors.text)
                    Spacer()
                    Text("+\(index * 10)")
                        .foregroundColor(.green)
                        .fontWeight(.semibold)
                }
                .padding()
                .background(ThemeColors.secondaryBackground.opacity(0.5))
                .cornerRadius(10)
            }
        }
        .padding()
        .background(ThemeColors.secondaryBackground.opacity(0.8))
        .cornerRadius(20)
    }
}

struct RedeemPointsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Redeem Points")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(ThemeColors.text)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(1...5, id: \.self) { index in
                        RedeemOptionCard(title: "Reward \(index)", points: index * 100, systemImage: "gift")
                    }
                }
            }
        }
    }
}

struct RedeemOptionCard: View {
    let title: String
    let points: Int
    let systemImage: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 30))
                .foregroundColor(.green)
            Text(title)
                .font(.headline)
                .foregroundColor(ThemeColors.text)
            Text("\(points) pts")
                .font(.subheadline)
                .foregroundColor(ThemeColors.secondaryText)
        }
        .frame(width: 120, height: 120)
        .background(ThemeColors.secondaryBackground.opacity(0.8))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.green.opacity(0.5), lineWidth: 1)
        )
    }
}

struct SearchView: View {
    @State private var searchText = ""
    let categories = ["Travel", "Apparels", "Tech Pass", "Geeks", "Service", "Entertainment"]
    
    var body: some View {
        ZStack {
            ThemeColors.background.edgesIgnoringSafeArea(.all)
            VStack(spacing: 16) {
                SearchBar(text: $searchText)
                    .padding(.horizontal)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(categories.filter { searchText.isEmpty || $0.localizedCaseInsensitiveContains(searchText) }, id: \.self) { category in
                            NavigationLink(destination: CategoryDetailView(category: category)) {
                                CategoryCard(category: category)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitle("Search", displayMode: .large)
            }
        }

        struct SearchBar: View {
            @Binding var text: String

            var body: some View {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(ThemeColors.secondaryText)
                    TextField("Search", text: $text)
                        .foregroundColor(ThemeColors.text)
                }
                .padding()
                .background(ThemeColors.secondaryBackground)
                .cornerRadius(10)
            }
        }

struct CategoryCard: View {
    let category: String
    
    var body: some View {
        VStack {
            Image(systemName: "tag.fill")
                .font(.system(size: 40))
                .foregroundColor(ThemeColors.accent)
            Text(category)
                .font(.headline)
                .foregroundColor(ThemeColors.text)
        }
        .frame(height: 130)
        .frame(maxWidth: .infinity)
        .background(ThemeColors.secondaryBackground)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}
        struct CategoryDetailView: View {
            let category: String
            
            var body: some View {
                ZStack {
                    ThemeColors.background.edgesIgnoringSafeArea(.all)
                    List {
                        ForEach(1...10, id: \.self) { index in
                            Text("\(category) Item \(index)")
                                .foregroundColor(ThemeColors.text)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                .navigationBarTitle(category, displayMode: .large)
            }
        }

        struct AboutMeView: View {
            var body: some View {
                ZStack {
                    ThemeColors.background.edgesIgnoringSafeArea(.all)
                    ScrollView {
                        VStack(spacing: 20) {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .foregroundColor(.green)
                            
                            Text("John Doe")
                                .font(.title)
                                .foregroundColor(ThemeColors.text)
                            
                            InfoSection(title: "Personal Information") {
                                InfoRow(title: "Student ID", value: "12345")
                                InfoRow(title: "Major", value: "Computer Science")
                                InfoRow(title: "Year", value: "Junior")
                            }
                            
                            InfoSection(title: "Contact Information") {
                                InfoRow(title: "Email", value: "john.doe@example.com")
                                InfoRow(title: "Phone", value: "(123) 456-7890")
                            }
                        }
                        .padding()
                    }
                }
                .navigationBarTitle("About Me", displayMode: .large)
            }
        }

        struct InfoSection<Content: View>: View {
            let title: String
            let content: Content
            
            init(title: String, @ViewBuilder content: () -> Content) {
                self.title = title
                self.content = content()
            }
            
            var body: some View {
                VStack(alignment: .leading, spacing: 10) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    content
                        .padding()
                        .background(ThemeColors.secondaryBackground)
                        .cornerRadius(10)
                }
            }
        }

        struct InfoRow: View {
            let title: String
            let value: String
            
            var body: some View {
                HStack {
                    Text(title)
                        .foregroundColor(ThemeColors.secondaryText)
                    Spacer()
                    Text(value)
                        .foregroundColor(ThemeColors.text)
                }
            }
        }
