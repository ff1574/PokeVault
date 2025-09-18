import SwiftUI

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
