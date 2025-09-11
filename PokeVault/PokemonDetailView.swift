import SwiftUI

struct PokemonDetailView: View {
    let pokemon: Pokemon
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Display the image
                if let imageUrl = pokemon.sprites.front_default, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 150)
                            .background(Color.gray.opacity(0.1))
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                            .frame(width: 150, height: 150)
                    }
                }
                
                // Display the name and other info
                Text(pokemon.name.capitalized)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Abilities:")
                        .font(.headline)
                    ForEach(pokemon.abilities, id: \.ability.name) { abilityWrapper in
                        Text("- \(abilityWrapper.ability.name.capitalized)")
                    }
                    
                    Text("Base Stats:")
                        .font(.headline)
                    ForEach(pokemon.stats, id: \.stat.name) { statWrapper in
                        Text("- \(statWrapper.stat.name.capitalized): \(statWrapper.base_stat)")
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
            .padding()
            .navigationTitle(pokemon.name.capitalized)
        }
    }
}
