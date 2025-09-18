import Foundation

// The initial list response only has name and URL.
// We'll create a new model for the detailed data.
struct Pokemon: Codable, Identifiable {
    let id: Int
    let name: String
    let sprites: Sprites
    let abilities: [AbilityWrapper]
    let stats: [StatWrapper]
    let types: [TypeWrapper]
    
    // The PokeAPI provides the ID in the URL, but the detailed endpoint
    // provides an 'id' directly. For the list view, we will still need to
    // extract it from the URL. Let's make a new struct for the list item.
}

struct PokemonListItem: Codable, Identifiable {
    let name: String
    let url: String
    
    var id: String {
        return url.split(separator: "/").last?.description ?? UUID().uuidString
    }
}

// Structs for the detailed data
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

// This struct is for the initial list response
struct PokemonListResponse: Codable {
    let results: [PokemonListItem]
}
