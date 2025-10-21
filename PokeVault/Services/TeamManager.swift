import Foundation
import Combine
import Supabase

class TeamManager: ObservableObject {
    private let teamCapacity = 6
    @Published var team: [Pokemon] = []
    
    // Supabase client
    private let client = SupabaseClient(
        supabaseURL: URL(string: "https://fstnwnhanwnvqgrxtrsc.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzdG53bmhhbndudnFncnh0cnNjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA1ODAwMjksImV4cCI6MjA3NjE1NjAyOX0.gfRXTrtELLUopcRLF6TkCpHY-pDpTXWkzv-Du0FgI9E"
    )
    
    // Published shared teams list
    @Published var sharedTeams: [SharedTeam] = []
    
    var isTeamFull: Bool {
        team.count >= teamCapacity
    }
    
    func add(pokemon: Pokemon) -> Bool {
        if team.contains(where: { $0.id == pokemon.id }) {
            return false // Already in team
        }
        if team.count < teamCapacity {
            team.append(pokemon)
            return true
        }
        return false // Team is full
    }
    
    func remove(pokemon: Pokemon) {
        team.removeAll { $0.id == pokemon.id }
    }
    
    func clearTeam() {
        team.removeAll()
    }
    
    struct SharedTeam: Identifiable, Codable {
        let id: UUID
        let team_name: String
        let trainer_name: String
        let pokemon_ids: [Int]
        let created_at: Date
        
        var idString: String {
            id.uuidString
        }
    }
    
    func uploadSharedTeam(teamName: String, trainerName: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard !teamName.isEmpty, !trainerName.isEmpty else {
            completion(.failure(NSError(domain: "Invalid input", code: 0, userInfo: [NSLocalizedDescriptionKey: "Team name and trainer name cannot be empty"])))
            return
        }
        
        guard !team.isEmpty else {
            completion(.failure(NSError(domain: "Empty team", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot upload an empty team"])))
            return
        }
        
        let pokedexIDs = team.map { $0.id }
        
        // Use an Encodable struct which is necessary for Supabase
        struct TeamUpload: Encodable {
            let team_name: String
            let trainer_name: String
            let pokemon_ids: [Int]
        }
        
        let newTeam = TeamUpload(
            team_name: teamName,
            trainer_name: trainerName,
            pokemon_ids: pokedexIDs
        )
        
        Task {
            do {
                try await client
                    .from("shared_teams")
                    .insert(newTeam)
                    .execute()
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    
    func fetchSharedTeams(completion: ((Result<Void, Error>) -> Void)? = nil) {
        Task {
            do {
                let response: [SharedTeam] = try await client
                    .from("shared_teams")
                    .select()
                    .order("created_at", ascending: false)
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    self.sharedTeams = response
                    completion?(.success(()))
                }
            } catch {
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
        }
    }
    
    func loadSharedTeam(sharedTeam: SharedTeam, allPokemon: [Pokemon], pokemonService: PokemonService, completion: @escaping () -> Void) {
        // First, get Pokemon that are already loaded
        var loadedPokemon = allPokemon.filter { sharedTeam.pokemon_ids.contains($0.id) }
        let loadedIds = Set(loadedPokemon.map { $0.id })
        
        // Find Pokemon IDs that need to be fetched
        let missingIds = sharedTeam.pokemon_ids.filter { !loadedIds.contains($0) }
        
        // If all Pokemon are already loaded, set team immediately
        guard !missingIds.isEmpty else {
            DispatchQueue.main.async {
                self.team = Array(loadedPokemon.prefix(self.teamCapacity))
                completion()
            }
            return
        }
        
        // Fetch missing Pokemon
        let dispatchGroup = DispatchGroup()
        var fetchedPokemon: [Pokemon] = []
        
        for pokemonId in missingIds {
            dispatchGroup.enter()
            let urlString = "https://pokeapi.co/api/v2/pokemon/\(pokemonId)/"
            
            pokemonService.fetchPokemonDetails(from: urlString) { pokemon in
                if let pokemon = pokemon {
                    fetchedPokemon.append(pokemon)
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            // Combine loaded and fetched Pokemon
            let allTeamPokemon = loadedPokemon + fetchedPokemon
            
            // Sort by the order in the shared team's pokemon_ids array
            let orderedPokemon = sharedTeam.pokemon_ids.compactMap { id in
                allTeamPokemon.first(where: { $0.id == id })
            }
            
            self.team = Array(orderedPokemon.prefix(self.teamCapacity))
            completion()
        }
    }
    
    struct TypeAnalysis {
        let type: String
        let strength: Int
    }
    
    func getTeamTypeAnalysis() -> [String: TypeAnalysis] {
        if team.isEmpty {
            return [:]
        }
        
        var analysis: [String: Double] = Constants.allTypes.reduce(into: [:]) { result, type in
            result[type] = 0.0
        }
        
        for pokemon in team {
            let pokeTypes = pokemon.types.map { $0.type.name }
            
            for (attackingType, interactions) in Constants.pokemonTypeInteraction {
                for (defendingType, multiplier) in interactions {
                    if pokeTypes.contains(defendingType) {
                        switch multiplier {
                        case 0.0:
                            analysis[attackingType]? += 2.0
                        case 0.25:
                            analysis[attackingType]? += 1.5
                        case 0.5:
                            analysis[attackingType]? += 1.0
                        case 1.0:
                            break
                        case 2.0:
                            analysis[attackingType]? -= 1.0
                        case 4.0:
                            analysis[attackingType]? -= 2.0
                        default:
                            break
                        }
                    }
                }
            }
        }
        
        var finalAnalysis: [String: TypeAnalysis] = [:]
        for (type, score) in analysis {
            let strength: Int
            if score >= 3 {
                strength = 2
            } else if score > 0 {
                strength = 1
            } else if score < 0 && score > -3 {
                strength = -1
            } else if score <= -3 {
                strength = -2
            } else {
                strength = 0
            }
            finalAnalysis[type] = TypeAnalysis(type: type, strength: strength)
        }
        
        return finalAnalysis.sorted { $0.key < $1.key }.reduce(into: [:]) { $0[$1.key] = $1.value }
    }
    
    func getAverageBaseStats() -> [String: Int] {
        guard !team.isEmpty else { return [:] }
        
        var totalStats: [String: Int] = [:]
        
        for pokemon in team {
            for statWrapper in pokemon.stats {
                totalStats[statWrapper.stat.name, default: 0] += statWrapper.base_stat
            }
        }
        
        let teamCount = Double(team.count)
        return totalStats.mapValues { Int(Double($0) / teamCount) }
            .sorted { $0.key < $1.key }
            .reduce(into: [:]) { $0[$1.key] = $1.value }
    }
}
