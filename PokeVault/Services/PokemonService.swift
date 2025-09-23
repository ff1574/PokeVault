import Foundation
import Combine

@MainActor
class PokemonService: ObservableObject {
    
    @Published var pokemonList: [PokemonListItem] = []
    @Published var detailedPokemonList: [Pokemon] = []
    @Published var isLoading = false
    
    func fetchPokemonList() {
        isLoading = true
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data else {
                DispatchQueue.main.async { self?.isLoading = false }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(PokemonListResponse.self, from: data)
                self.pokemonList = decodedResponse.results
                
                self.fetchDetailedPokemonList()
                
            } catch {
                print("Decoding list failed: \(error)")
                DispatchQueue.main.async { self.isLoading = false }
            }
        }.resume()
    }
    
    func fetchDetailedPokemonList() {
        let dispatchGroup = DispatchGroup()
        var tempPokemonList: [Pokemon] = []
        
        for item in pokemonList {
            dispatchGroup.enter()
            fetchPokemonDetails(from: item.url) { pokemon in
                if let pokemon = pokemon {
                    tempPokemonList.append(pokemon)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            self.detailedPokemonList = tempPokemonList.sorted(by: { $0.id < $1.id })
            self.isLoading = false
        }
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
                    DispatchQueue.main.async {
                        completion(decodedPokemon)
                    }
                } catch {
                    print("Decoding details failed: \(error)")
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }.resume()
    }
    
    func fetchEvolutionData(for pokemon: Pokemon, completion: @escaping (EvolutionData?) -> Void) {
        guard let speciesURL = URL(string: pokemon.species.url) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: speciesURL) { data, response, error in
            guard let data = data,
                  let species = try? JSONDecoder().decode(PokemonSpecies.self, from: data),
                  let evolutionURL = URL(string: species.evolution_chain.url) else {
                completion(nil)
                return
            }

            URLSession.shared.dataTask(with: evolutionURL) { data, response, error in
                guard let data = data,
                      let evolutionChain = try? JSONDecoder().decode(EvolutionChain.self, from: data) else {
                    completion(nil)
                    return
                }

                var evolutionLine: [NamedAPIResource] = []
                var currentNode = evolutionChain.chain
                
                func parseEvolutions(node: EvolutionNode) {
                    if let pokemonId = node.species.url.split(separator: "/").last, !pokemonId.isEmpty {
                        let correctedURL = "https://pokeapi.co/api/v2/pokemon/\(pokemonId)/"
                        let correctedResource = NamedAPIResource(name: node.species.name, url: correctedURL)
                        evolutionLine.append(correctedResource)
                    }
                    
                    for nextNode in node.evolves_to {
                        parseEvolutions(node: nextNode)
                    }
                }
                
                parseEvolutions(node: currentNode)

                let evolution = EvolutionData(evolutionLine: evolutionLine)
                
                DispatchQueue.main.async {
                    completion(evolution)
                }
            }.resume()
        }.resume()
    }
}
