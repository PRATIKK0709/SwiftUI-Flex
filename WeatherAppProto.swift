import SwiftUI

@main
struct ShowcaseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Color Extension
extension Color {
    static let darkBlue = Color(#colorLiteral(red: 0.1215686277, green: 0.1294117719, blue: 0.1411764771, alpha: 1))
    static let lightBlue = Color(#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1))
    static let accent = Color(#colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372549, alpha: 1))
    static let lightText = Color.white
    static let darkText = Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
}

struct ContentView: View {
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView {
                VStack(spacing: 25) {
                    HeaderView()
                    WeatherCardView()
                    ForecastView()
                    AirQualityView()
                }
                .padding()
            }
        }
    }
}

struct BackgroundView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [.darkBlue, .lightBlue]),
                       startPoint: .topLeading,
                       endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}

struct HeaderView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("New York")
                    .font(.system(size: 32, weight: .bold))
                Text("Friday, 13 September")
                    .font(.subheadline)
            }
            Spacer()
            Image(systemName: "location.circle.fill")
                .font(.system(size: 32))
        }
        .foregroundColor(.lightText)
    }
}

struct WeatherCardView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.lightText.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.lightText.opacity(0.5), lineWidth: 1)
                )
            
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    Text("72°")
                        .font(.system(size: 64, weight: .bold))
                    Text("Feels like 75°")
                        .font(.subheadline)
                    Text("Partly Cloudy")
                        .font(.headline)
                }
                
                Spacer()
                
                Image(systemName: "cloud.sun.fill")
                    .font(.system(size: 80))
            }
            .padding()
            .foregroundColor(.lightText)
        }
        .frame(height: 180)
    }
}

struct ForecastView: View {
    let forecasts = ["Mon", "Tue", "Wed", "Thu", "Fri"]
    let temperatures = [68, 72, 75, 71, 69]
    let icons = ["sun.max.fill", "cloud.sun.fill", "sun.max.fill", "cloud.fill", "cloud.drizzle.fill"]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("5-Day Forecast")
                .font(.headline)
                .foregroundColor(.lightText)
            
            HStack {
                ForEach(0..<5) { index in
                    VStack {
                        Text(forecasts[index])
                            .font(.caption)
                        Image(systemName: icons[index])
                            .font(.system(size: 24))
                        Text("\(temperatures[index])°")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .background(Color.lightText.opacity(0.2))
        .cornerRadius(15)
        .foregroundColor(.lightText)
    }
}

struct AirQualityView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Air Quality")
                .font(.headline)
            
            HStack {
                Text("Good")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("AQI 32")
                        .font(.headline)
                    Text("PM2.5: 8 μg/m³")
                        .font(.subheadline)
                }
            }
            
            ProgressView(value: 0.32)
                .accentColor(.accent)
        }
        .padding()
        .background(Color.lightText.opacity(0.2))
        .cornerRadius(15)
        .foregroundColor(.lightText)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
