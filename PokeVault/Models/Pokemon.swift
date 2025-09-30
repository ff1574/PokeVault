import Foundation

struct Pokemon: Codable, Identifiable {
    let id: Int
    let name: String
    let sprites: Sprites
    let abilities: [AbilityWrapper]
    let moves: [MoveWrapper]
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

struct MoveWrapper: Codable {
    let move: NamedAPIResource
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
    
    var id: String? {
        return url.split(separator: "/").last?.description
    }
}

struct PokemonListResponse: Codable {
    let results: [PokemonListItem]
}

struct MoveDetail: Codable, Identifiable {
    let name: String
    let pp: Int?
    let accuracy: Int?
    let power: Int?
    let type: NamedAPIResource
    let effect_entries: [EffectEntry]
    
    var shortEffect: String {
        return effect_entries.first { $0.language.name == "en" }?.short_effect ?? "No effect description."
    }
    
    var id: String {
        return name
    }
}

struct AbilityDetail: Codable, Identifiable {
    let name: String
    let effect_entries: [EffectEntry]
    
    var effect: String? {
        return effect_entries.first { $0.language.name == "en" }?.effect
    }
    
    var id: String {
        return name
    }
}

struct EffectEntry: Codable {
    let effect: String?
    let short_effect: String?
    let language: NamedAPIResource
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
