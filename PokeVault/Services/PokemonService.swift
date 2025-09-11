import Foundation
import Combine

@MainActor // Mark the entire class as running on the main actor
class PokemonService: ObservableObject {
    
    @Published var pokemonList: [PokemonListItem] = []
    
    func fetchPokemonList() {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(PokemonListResponse.self, from: data)
                    // Since the class is @MainActor, this assignment will automatically
                    // happen on the main thread.
                    self.pokemonList = decodedResponse.results
                } catch {
                    print("Decoding list failed: \(error)")
                }
            }
        }.resume()
    }
    
    func fetchPokemonDetails(from urlString: String, completion: @escaping (Pokemon?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedPokemon = try JSONDecoder().decode(Pokemon.self, from: data)
                    // The completion handler is called on the main thread
                    // because the service is marked as @MainActor.
                    completion(decodedPokemon)
                } catch {
                    print("Decoding details failed: \(error)")
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }.resume()
    }
}
