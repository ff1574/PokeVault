import SwiftUI

struct ContentView: View {
    @StateObject var pokemonService = PokemonService()

    var body: some View {
        NavigationStack {
            List(pokemonService.pokemonList) { pokemonListItem in
                NavigationLink(destination: PokemonDetailFetchView(url: pokemonListItem.url)) {
                    HStack {
                        AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonListItem.id).png")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                        } placeholder: {
                            ProgressView()
                                .frame(width: 50, height: 50)
                        }
                        
                        Text(pokemonListItem.name.capitalized)
                            .font(.headline)
                            .padding(.leading, 10)
                    }
                }
            }
            .navigationTitle("Pokedex")
            .onAppear {
                pokemonService.fetchPokemonList()
            }
        }
    }
}

// A new view that fetches and displays the detailed Pokemon data.
struct PokemonDetailFetchView: View {
    let url: String
    @State private var pokemon: Pokemon?
    @State private var isLoading = true
    @StateObject private var pokemonService = PokemonService()

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
        .onAppear {
            pokemonService.fetchPokemonDetails(from: url) { fetchedPokemon in
                self.pokemon = fetchedPokemon
                self.isLoading = false
            }
        }
    }
}
