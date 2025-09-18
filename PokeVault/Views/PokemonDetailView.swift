import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon
    
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
        ScrollView {
            VStack(spacing: 0) {
                // Top section with image and name
                VStack(spacing: 10) {
                    Text(pokemon.name.capitalized)
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                    
                    // Display type icons
                    HStack(spacing: 10) {
                        ForEach(pokemon.types, id: \.type.name) { typeWrapper in
                            Image(typeWrapper.type.name.lowercased())
                                .resizable()
                                .frame(width: 30, height: 30)
                                .shadow(radius: 5)
                        }
                    }
                    
                    AsyncImage(url: URL(string: pokemon.sprites.front_default ?? "")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200, height: 200)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 200, height: 200)
                    }
                    .shadow(radius: 10)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
                .padding(.bottom, 20)
                .background(backgroundGradient)
                .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                .edgesIgnoringSafeArea(.top)
                
                // Details section
                VStack(spacing: 20) {
                    // Abilities Card
                    VStack(alignment: .leading) {
                        Text("Abilities")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        ForEach(pokemon.abilities, id: \.ability.name) { abilityWrapper in
                            Text("- \(abilityWrapper.ability.name.capitalized)")
                                .padding(.vertical, 2)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    
                    // Base Stats Card
                    VStack(alignment: .leading) {
                        Text("Base Stats")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        ForEach(pokemon.stats, id: \.stat.name) { statWrapper in
                            HStack {
                                Text(statWrapper.stat.name.capitalized + ":")
                                Spacer()
                                Text("\(statWrapper.base_stat)")
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                }
                .padding()
                .offset(y: -30) // Overlap with the top section
            }
        }
        .background(Color.gray.opacity(0.1))
        .edgesIgnoringSafeArea(.all)
    }
}
