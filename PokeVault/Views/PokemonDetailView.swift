import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon
    @State private var evolutionData: EvolutionData?
    @StateObject private var pokemonService = PokemonService()
    
    var backgroundGradient: LinearGradient {
        let colors = pokemon.types.map { typeWrapper in
            return Constants.pokemonTypeColor[typeWrapper.type.name] ?? .gray
        }
        
        if colors.count == 2 {
            return LinearGradient(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            return LinearGradient(gradient: Gradient(colors: [colors.first ?? .gray, colors.first?.opacity(0.8) ?? .gray]), startPoint: .top, endPoint: .bottom)
        }
    }
    
    var body: some View {
        ZStack {
            backgroundGradient
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 0) {
                    // Top section with image and name
                    ZStack(alignment: .bottom) {
                        Color.clear
                            .frame(height: 250)
                        
                        AsyncImage(url: URL(string: pokemon.sprites.front_default ?? "")) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 200, height: 200)
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                                    .offset(y: 40)
                            } else if phase.error != nil {
                                Image(systemName: "xmark.circle")
                                    .font(.largeTitle)
                                    .foregroundColor(.red)
                            } else {
                                ProgressView()
                            }
                        }
                    }
                    
                    VStack(spacing: 10) {
                        Text(pokemon.name.capitalized)
                            .font(.system(size: 38, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                            .padding(.top, 40)
                        
                        HStack(spacing: 10) {
                            ForEach(pokemon.types, id: \.type.name) { typeWrapper in
                                VStack {
                                    Image(typeWrapper.type.name.lowercased())
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .shadow(radius: 5)
                                    Text(typeWrapper.type.name.capitalized)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    .padding()
                    
                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Moves")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Divider()
                                .background(.white.opacity(0.7))
                            
                            ForEach(pokemon.abilities, id: \.ability.name) { abilityWrapper in
                                Text(abilityWrapper.ability.name.capitalized)
                                    .font(.body)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Base Stats")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Divider()
                                .background(.white.opacity(0.7))
                            
                            ForEach(pokemon.stats, id: \.stat.name) { statWrapper in
                                StatBarView(stat: statWrapper)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        if let evolutionData = evolutionData {
                            EvolutionView(currentPokemon: pokemon, evolutionLine: evolutionData.evolutionLine)
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            pokemonService.fetchEvolutionData(for: pokemon) { fetchedData in
                self.evolutionData = fetchedData
            }
        }
    }
}

struct StatBarView: View {
    let stat: StatWrapper
    let maxStatValue = 255.0
    
    var statColor: Color {
        switch stat.stat.name {
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
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(stat.stat.name.capitalized.replacingOccurrences(of: "-", with: " "))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("\(stat.base_stat)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.gray.opacity(0.6))
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 5)
                        .fill(statColor)
                        .frame(width: min(CGFloat(stat.base_stat) / CGFloat(maxStatValue) * geometry.size.width, geometry.size.width), height: 10)
                        .animation(.easeOut, value: stat.base_stat)
                }
            }
            .frame(height: 10)
        }
    }
}

struct EvolutionView: View {
    let currentPokemon: Pokemon
    let evolutionLine: [NamedAPIResource]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Evolutions")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Divider()
                .background(.white.opacity(0.7))
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(evolutionLine, id: \.name) { pokemon in
                        NavigationLink(destination: PokemonDetailFetchView(url: pokemon.url)) {
                            EvolutionStep(name: pokemon.name, imageURL: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.id ?? "").png", isCurrent: pokemon.name == currentPokemon.name)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color.black.opacity(0.4))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.3), lineWidth: 2)
        )
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct EvolutionStep: View {
    let name: String
    let imageURL: String
    let isCurrent: Bool
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: imageURL)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: isCurrent ? 80 : 60, height: isCurrent ? 80 : 60)
                        .padding(.top, isCurrent ? 0 : 20)
                } else {
                    ProgressView()
                        .frame(width: 60, height: 60)
                }
            }
            Text(name.capitalized)
                .font(.caption)
                .foregroundColor(.white)
                .fontWeight(isCurrent ? .bold : .regular)
        }
    }
}

struct PokemonDetailFetchView: View {
    let url: String
    @State private var pokemon: Pokemon?
    @State private var isLoading = true
    @StateObject private var pokemonService = PokemonService()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading...")
            } else if let pokemon = pokemon {
                PokemonDetailView(pokemon: pokemon)
            } else {
                Text("Failed to load Pokemon data.")
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.backward.circle.fill")
                        .foregroundColor(.white)
                        .font(.title)
                }
            }
        }
        .onAppear {
            pokemonService.fetchPokemonDetails(from: url) { fetchedPokemon in
                self.pokemon = fetchedPokemon
                self.isLoading = false
            }
        }
    }
}
