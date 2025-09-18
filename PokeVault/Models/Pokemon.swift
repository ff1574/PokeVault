import Foundation

struct Pokemon: Codable, Identifiable {
    let id: Int
    let name: String
    let sprites: Sprites
    let abilities: [AbilityWrapper]
    let stats: [StatWrapper]
    let types: [TypeWrapper]
    let species: NamedAPIResource
}

struct PokemonListItem: Codable, Identifiable {
    let name: String
    let url: String
    
    var id: String {
        return url.split(separator: "/").last?.description ?? UUID().uuidString
    }
}

struct Sprites: Codable {
    let front_default: String?
}

struct AbilityWrapper: Codable {
    let ability: NamedAPIResource
}

struct StatWrapper: Codable {
    let stat: NamedAPIResource
    let base_stat: Int
}

struct TypeWrapper: Codable {
    let type: NamedAPIResource
}

struct NamedAPIResource: Codable {
    let name: String
    let url: String
}

struct PokemonListResponse: Codable {
    let results: [PokemonListItem]
}

struct PokemonSpecies: Codable {
    let evolution_chain: APIResource
}

struct APIResource: Codable {
    let url: String
}

struct EvolutionChain: Codable {
    let chain: EvolutionNode
}

struct EvolutionNode: Codable {
    let species: NamedAPIResource
    let evolves_to: [EvolutionNode]
}

struct EvolutionData {
    let evolutionLine: [NamedAPIResource]
}
