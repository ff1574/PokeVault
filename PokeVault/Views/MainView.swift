import SwiftUI

struct MainView: View {
    @EnvironmentObject var teamManager: TeamManager
    @StateObject private var pokemonService = PokemonService()
    @State private var randomPokemon: Pokemon?
    @Binding var selectedTab: Int  // Add binding for tab navigation
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Animated Gradient Background
                AnimatedGradientBackground()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Hero Section
                        VStack(spacing: 12) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .shadow(color: .red.opacity(0.5), radius: 20, x: 0, y: 0)
                                .padding(.top, 40)
                            
                            Text("PokeVault")
                                .font(.system(size: 50, weight: .black, design: .rounded))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Text("Your Ultimate Pokémon Companion")
                                .font(.title3)
                                .foregroundColor(.white.opacity(0.9))
                                .fontWeight(.medium)
                        }
                        .padding(.bottom, 20)
                        
                        // Quick Stats Cards (only 2 cards now)
                        HStack(spacing: 15) {
                            QuickStatCard(
                                icon: "list.bullet.circle.fill",
                                title: "Pokédex",
                                value: "151",
                                gradient: [Color.blue, Color.cyan],
                                iconColor: .white
                            )
                            
                            QuickStatCard(
                                icon: "person.3.fill",
                                title: "Your Team",
                                value: "\(teamManager.team.count)",
                                gradient: [Color.purple, Color.pink],
                                iconColor: .white
                            )
                        }
                        .padding(.horizontal)
                        
                        // Featured Pokemon Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Pokémon of the Day")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            if let pokemon = randomPokemon {
                                NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                                    FeaturedPokemonCard(pokemon: pokemon)
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                ProgressView()
                                    .frame(height: 200)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        
                        // Quick Actions (only 2 now)
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Quick Actions")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            VStack(spacing: 12) {
                                Button(action: {
                                    selectedTab = 1  // Navigate to Pokédex tab
                                }) {
                                    QuickActionButton(
                                        icon: "magnifyingglass.circle.fill",
                                        title: "Explore Pokédex",
                                        subtitle: "Browse all 151 Pokémon",
                                        gradient: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    selectedTab = 2  // Navigate to Team Builder tab
                                }) {
                                    QuickActionButton(
                                        icon: "plus.circle.fill",
                                        title: "Build Your Team",
                                        subtitle: "Create the perfect team",
                                        gradient: [Color.green.opacity(0.8), Color.teal.opacity(0.8)]
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 30)
                    }
                }
            }
            .onAppear {
                if pokemonService.detailedPokemonList.isEmpty {
                    pokemonService.fetchPokemonList()
                }
                loadRandomPokemon()
            }
        }
    }
    
    private func loadRandomPokemon() {
        // Wait a bit for pokemon list to load if needed
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if !pokemonService.detailedPokemonList.isEmpty {
                randomPokemon = pokemonService.detailedPokemonList.randomElement()
            }
        }
    }
}

// Animated Gradient Background
struct AnimatedGradientBackground: View {
    @State private var animateGradient = false
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.9, green: 0.2, blue: 0.2),
                Color(red: 1.0, green: 0.4, blue: 0.4),
                Color(red: 0.9, green: 0.5, blue: 0.8)
            ]),
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// Quick Stat Card Component
struct QuickStatCard: View {
    let icon: String
    let title: String
    let value: String
    let gradient: [Color]
    let iconColor: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 35))
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .foregroundColor(.white)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                gradient: Gradient(colors: gradient),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: gradient[0].opacity(0.4), radius: 10, x: 0, y: 5)
    }
}

// Featured Pokemon Card - FIXED VERSION
struct FeaturedPokemonCard: View {
    let pokemon: Pokemon
    @State private var loadedImage: UIImage?
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(pokemon.name.capitalized)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 8) {
                        ForEach(pokemon.types, id: \.type.name) { typeWrapper in
                            HStack(spacing: 4) {
                                Image(typeWrapper.type.name.lowercased())
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text(typeWrapper.type.name.capitalized)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Constants.pokemonTypeColor[typeWrapper.type.name] ?? .gray)
                            .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
                
                // Fixed image loading with proper state management
                Group {
                    if let image = loadedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                    } else if isLoading {
                        ProgressView()
                            .frame(width: 120, height: 120)
                    } else {
                        Image(systemName: "photo.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 120, height: 120)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }
            .padding()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Constants.pokemonTypeColor[pokemon.types.first?.type.name ?? "normal"] ?? .gray,
                    (Constants.pokemonTypeColor[pokemon.types.first?.type.name ?? "normal"] ?? .gray).opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
        .onAppear {
            loadImage()
        }
        .onChange(of: pokemon.id) { _ in
            // Reset state when pokemon changes
            loadedImage = nil
            isLoading = true
            loadImage()
        }
        .id(pokemon.id)  // Force view refresh when pokemon changes
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

// Quick Action Button
struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.white)
                .frame(width: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.7))
                .font(.title3)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: gradient),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(15)
        .shadow(color: gradient[0].opacity(0.3), radius: 8, x: 0, y: 4)
    }
}
