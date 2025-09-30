import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon
    @State private var evolutionData: EvolutionData?
    @State private var moveDetails: [MoveDetail]?
    @State private var abilityDetails: [AbilityDetail]?
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
                        // 1. EVOLUTIONS (First Section)
                        if let evolutionData = evolutionData {
                            EvolutionView(currentPokemon: pokemon, evolutionLine: evolutionData.evolutionLine)
                        } else {
                            Text("Loading Evolutions...")
                                .foregroundColor(.white)
                                .padding()
                        }
                        
                        // 2. BASE STATS (Second Section)
                        BaseStatsCardView(pokemon: pokemon)

                        // 3. MOVES (Third Section - with expandable/retractable logic)
                        MovesCardView(moveDetails: moveDetails)

                        // 4. ABILITIES (Fourth Section - with expandable/retractable logic)
                        AbilitiesCardView(abilityDetails: abilityDetails)
                        
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            pokemonService.fetchEvolutionData(for: pokemon) { fetchedData in
                self.evolutionData = fetchedData
            }
            pokemonService.fetchAllMoveDetails(for: pokemon) { details in
                self.moveDetails = details
            }
            pokemonService.fetchAllAbilityDetails(for: pokemon) { details in
                self.abilityDetails = details
            }
        }
    }
}

struct BaseStatsCardView: View {
    let pokemon: Pokemon
    
    var body: some View {
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

struct AbilitiesCardView: View {
    let abilityDetails: [AbilityDetail]?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Abilities")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Divider()
                .background(.white.opacity(0.7))
            
            if let details = abilityDetails {
                ForEach(details) { ability in
                    AbilityDetailRow(ability: ability)
                }
            } else {
                Text("Loading abilities...")
                    .foregroundColor(.white.opacity(0.8))
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
    }
}

struct AbilityDetailRow: View {
    let ability: AbilityDetail
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(ability.name.capitalized.replacingOccurrences(of: "-", with: " "))
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }) {
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .foregroundColor(.cyan)
                }
            }
            
            Text(ability.effect ?? "No description available.")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(isExpanded ? nil : 2) // Limit to 2 lines when collapsed
        }
        .padding(.vertical, 5)
    }
}

struct MovesCardView: View {
    let moveDetails: [MoveDetail]?
    @State private var isExpanded: Bool = false
    
    var movesToShow: [MoveDetail] {
        guard let details = moveDetails else { return [] }
        // Show only the first 2 moves if not expanded
        return isExpanded ? details : Array(details.prefix(2))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Moves")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Spacer()
                
                if let details = moveDetails, details.count > 2 {
                    Button(action: {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }) {
                        Text(isExpanded ? "Show Less" : "Show All (\(details.count))")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.cyan)
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .foregroundColor(.cyan)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            Divider()
                .background(.white.opacity(0.7))
            
            if moveDetails != nil {
                ForEach(movesToShow) { move in
                    MoveDetailRow(move: move)
                }
                
                if movesToShow.isEmpty {
                    Text("No moves learned.")
                        .foregroundColor(.white.opacity(0.8))
                }
            } else {
                Text("Loading moves...")
                    .foregroundColor(.white.opacity(0.8))
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
    }
}

struct MoveDetailRow: View {
    let move: MoveDetail
    
    var typeColor: Color {
        return Constants.pokemonTypeColor[move.type.name] ?? .gray
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(move.name.capitalized.replacingOccurrences(of: "-", with: " "))
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                HStack(spacing: 5) {
                    Image(move.type.name.lowercased())
                        .resizable()
                        .frame(width: 15, height: 15)
                        .shadow(radius: 1)
                    Text(move.type.name.capitalized)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(typeColor.opacity(0.8))
                        .cornerRadius(5)
                }
            }
            
            HStack(spacing: 15) {
                // Power
                DetailStatPill(label: "Power", value: move.power != nil ? String(move.power!) : "--")
                
                // Accuracy
                DetailStatPill(label: "Acc", value: move.accuracy != nil ? "\(move.accuracy!)%" : "--")
                
                // PP
                DetailStatPill(label: "PP", value: move.pp != nil ? String(move.pp!) : "--")
            }
            
            // Move Effect Description
            if move.shortEffect != "No effect description." {
                Text("Effect: \(move.shortEffect.replacingOccurrences(of: "$effect_chance%", with: ""))") // Clean up effect string
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.vertical, 5)
    }
}

struct DetailStatPill: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 4) {
            Text(label + ":")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundColor(.white)
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
