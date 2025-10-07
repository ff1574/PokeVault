import SwiftUI

struct TeamBuilderView: View {
    @Binding var selectedTab: Int 
    @EnvironmentObject var teamManager: TeamManager
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header Section
                    VStack(spacing: 10) {
                        Text("Team Builder")
                            .font(.system(size: 40, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text("\(teamManager.team.count)/6 Pokémon")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 8)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(20)
                    }
                    .padding(.top, 20)
                    
                    // Team Grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: 2), spacing: 15) {
                        ForEach(0..<6) { index in
                            if index < teamManager.team.count {
                                TeamSlotFilledView(pokemon: teamManager.team[index], index: index)
                            } else {
                                TeamSlotEmptyView(selectedTab: $selectedTab)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Team Statistics (only show if team has Pokemon)
                    if !teamManager.team.isEmpty {
                        TeamStatisticsView()
                    }
                    
                    Spacer(minLength: 30)
                }
            }
        }
    }
}

struct TeamSlotEmptyView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        Button(action: {
            selectedTab = 1  // Switch to Pokédex tab (index 1)
        }) {
            VStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 180)
                    .overlay(
                        VStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.5))
                            Text("Add Pokémon")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                            Text("Tap to browse")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.4), lineWidth: 2)
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct TeamSlotFilledView: View {
    let pokemon: Pokemon
    let index: Int
    @EnvironmentObject var teamManager: TeamManager
    @State private var showRemoveConfirmation = false
    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack(alignment: .topTrailing) {
                // Pokemon Card
                VStack(spacing: 5) {
                    // Pokemon Image - Custom Loader
                    Group {
                        if let uiImage = loadedImage {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                        } else if isLoading {
                            ProgressView()
                                .frame(height: 100)
                        } else {
                            Image(systemName: "photo.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: 100)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                    .onAppear {
                        loadImage()
                    }
                    .id(pokemon.id) // Force reload when pokemon changes
                    
                    // Pokemon Name
                    Text(pokemon.name.capitalized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // Type Icons (Updated Section)
                    HStack(spacing: 8) {
                        ForEach(pokemon.types, id: \.type.name) { typeWrapper in
                            VStack(spacing: 2) {
                                Image(typeWrapper.type.name.lowercased())
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .shadow(radius: 3)
                                
                                Text(typeWrapper.type.name.capitalized)
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding(.top, 2)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.4), lineWidth: 2)
                )
                
                // Remove Button
                Button(action: {
                    showRemoveConfirmation = true
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                        .background(Circle().fill(Color.white))
                }
                .offset(x: 8, y: -8)
            }
        }
        .alert("Remove Pokémon", isPresented: $showRemoveConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Remove", role: .destructive) {
                withAnimation {
                    teamManager.remove(pokemon: pokemon)
                }
            }
        } message: {
            Text("Remove \(pokemon.name.capitalized) from your team?")
        }
    }
    
    private func loadImage() {
        guard let urlString = pokemon.sprites.front_default,
              let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        // Check cache first
        let cache = URLCache.shared
        let request = URLRequest(url: url)
        
        if let cachedResponse = cache.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data) {
            DispatchQueue.main.async {
                self.loadedImage = image
                self.isLoading = false
            }
            return
        }
        
        // Load from network
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let image = UIImage(data: data),
                  let response = response else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            // Cache the response
            let cachedData = CachedURLResponse(response: response, data: data)
            cache.storeCachedResponse(cachedData, for: request)
            
            DispatchQueue.main.async {
                self.loadedImage = image
                self.isLoading = false
            }
        }.resume()
    }
}

struct TeamStatisticsView: View {
    @EnvironmentObject var teamManager: TeamManager
    
    var body: some View {
        VStack(spacing: 20) {
            // Type Coverage Analysis
            TypeCoverageView()
            
            // Average Stats
            AverageStatsView()
            
            // Type Distribution
            TypeDistributionView()
        }
        .padding()
    }
}

struct TypeCoverageView: View {
    @EnvironmentObject var teamManager: TeamManager
    
    var typeAnalysis: [String: TeamManager.TypeAnalysis] {
        teamManager.getTeamTypeAnalysis()
    }
    
    var strongAgainst: [String] {
        typeAnalysis.filter { $0.value.strength > 0 }.map { $0.key }.sorted()
    }
    
    var weakAgainst: [String] {
        typeAnalysis.filter { $0.value.strength < 0 }.map { $0.key }.sorted()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Type Coverage")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Divider()
                .background(Color.white.opacity(0.5))
            
            // Resistances
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "shield.fill")
                        .foregroundColor(.green)
                    Text("Strong Defense Against")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                if strongAgainst.isEmpty {
                    Text("No significant resistances")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .italic()
                } else {
                    FlowLayout(spacing: 8) {
                        ForEach(strongAgainst, id: \.self) { type in
                            TypeBadge(type: type, strength: typeAnalysis[type]?.strength ?? 0)
                        }
                    }
                }
            }
            
            Divider()
                .background(Color.white.opacity(0.3))
            
            // Weaknesses
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text("Vulnerable To")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                if weakAgainst.isEmpty {
                    Text("No significant weaknesses")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .italic()
                } else {
                    FlowLayout(spacing: 8) {
                        ForEach(weakAgainst, id: \.self) { type in
                            TypeBadge(type: type, strength: typeAnalysis[type]?.strength ?? 0)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
    }
}

struct TypeBadge: View {
    let type: String
    let strength: Int
    
    var backgroundColor: Color {
        if strength >= 2 {
            return Color.green.opacity(0.8)
        } else if strength == 1 {
            return Color.green.opacity(0.6)
        } else if strength == -1 {
            return Color.red.opacity(0.6)
        } else {
            return Color.red.opacity(0.8)
        }
    }
    
    var icon: String {
        if strength > 0 {
            return strength >= 2 ? "shield.fill" : "shield.lefthalf.filled"
        } else {
            return strength <= -2 ? "exclamationmark.2" : "exclamationmark"
        }
    }
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon)
                .font(.caption2)
            Text(type.capitalized)
                .font(.caption)
                .fontWeight(.semibold)
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

struct AverageStatsView: View {
    @EnvironmentObject var teamManager: TeamManager
    
    var averageStats: [String: Int] {
        teamManager.getAverageBaseStats()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Average Team Stats")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Divider()
                .background(Color.white.opacity(0.5))
            
            if averageStats.isEmpty {
                Text("No stats to display")
                    .foregroundColor(.white.opacity(0.7))
            } else {
                VStack(spacing: 12) {
                    ForEach(averageStats.sorted(by: { $0.key < $1.key }), id: \.key) { stat, value in
                        AverageStatRow(statName: stat, value: value)
                    }
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
    }
}

struct AverageStatRow: View {
    let statName: String
    let value: Int
    let maxStatValue = 150.0
    
    var statColor: Color {
        switch statName {
        case "hp": return .red
        case "attack": return .orange
        case "defense": return .yellow
        case "special-attack": return .blue
        case "special-defense": return .green
        case "speed": return .cyan
        default: return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(statName.capitalized.replacingOccurrences(of: "-", with: " "))
                    .font(.subheadline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(value)")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.white)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(statColor)
                        .frame(width: min(CGFloat(value) / CGFloat(maxStatValue) * geometry.size.width, geometry.size.width), height: 8)
                        .animation(.easeOut, value: value)
                }
            }
            .frame(height: 8)
        }
    }
}

struct TypeDistributionView: View {
    @EnvironmentObject var teamManager: TeamManager
    
    var typeCount: [String: Int] {
        var count: [String: Int] = [:]
        for pokemon in teamManager.team {
            for type in pokemon.types {
                count[type.type.name, default: 0] += 1
            }
        }
        return count
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Type Distribution")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Divider()
                .background(Color.white.opacity(0.5))
            
            FlowLayout(spacing: 10) {
                ForEach(typeCount.sorted(by: { $0.key < $1.key }), id: \.key) { type, count in
                    HStack(spacing: 5) {
                        Text(type.capitalized)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("×\(count)")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.white.opacity(0.3))
                            .cornerRadius(8)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Constants.pokemonTypeColor[type] ?? .gray)
                    .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
    }
}

// FlowLayout for wrapping items
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var frames: [CGRect] = []
        var size: CGSize = .zero
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                frames.append(CGRect(origin: CGPoint(x: currentX, y: currentY), size: size))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}
