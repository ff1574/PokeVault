import Foundation
import Combine

class TeamManager: ObservableObject {
    private let teamCapacity = 6
    @Published var team: [Pokemon] = []
    
    // MARK: - Team Management
    
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
    
    // MARK: - Team Analysis (The "Cool Feature")
    
    struct TypeAnalysis {
        let type: String
        let strength: Int
    }
    
    /// Calculates the overall strength/weakness of the current team against all 18 types.
    /// Strength is calculated by checking the sum of effective damage modifiers across all team members.
    /// A score > 0 means the team generally resists/is immune to the type.
    /// A score < 0 means the team generally takes super effective damage from the type.
    func getTeamTypeAnalysis() -> [String: TypeAnalysis] {
        if team.isEmpty {
            return [:]
        }
        
        // 1. Initialize analysis for all types
        var analysis: [String: Double] = Constants.allTypes.reduce(into: [:]) { result, type in
            result[type] = 0.0
        }
        
        // 2. Iterate through each PokÃ©mon and update the analysis
        for pokemon in team {
            let pokeTypes = pokemon.types.map { $0.type.name }
            
            // Analyze how the PokÃ©mon's type(s) defend against an *attacking type*
            for (attackingType, interactions) in Constants.pokemonTypeInteraction {
                for (defendingType, multiplier) in interactions {
                    // Check if the PokÃ©mon has the defending type
                    if pokeTypes.contains(defendingType) {
                        
                        // Apply the damage multiplier to the score.
                        // A resistance (0.5) is a positive score (good). A weakness (2.0) is a negative score (bad).
                        switch multiplier {
                        case 0.0: // Immunity
                            analysis[attackingType]? += 2.0
                        case 0.25: // Double Resistance
                            analysis[attackingType]? += 1.5
                        case 0.5: // Resistance
                            analysis[attackingType]? += 1.0
                        case 1.0: // Normal damage - neutral, do not add to score
                            break
                        case 2.0: // Weakness
                            analysis[attackingType]? -= 1.0
                        case 4.0: // Double Weakness
                            analysis[attackingType]? -= 2.0
                        default:
                            break
                        }
                    }
                }
            }
        }
        
        // 3. Convert raw score to a classified strength level (-2, -1, 0, 1, 2)
        var finalAnalysis: [String: TypeAnalysis] = [:]
        for (type, score) in analysis {
            let strength: Int
            if score >= 3 {
                strength = 2 // Highly Resists
            } else if score > 0 {
                strength = 1 // Resists
            } else if score < 0 && score > -3 {
                strength = -1 // Weakness
            } else if score <= -3 {
                strength = -2 // Highly Weak
            } else {
                strength = 0 // Neutral
            }
            finalAnalysis[type] = TypeAnalysis(type: type, strength: strength)
        }
        
        return finalAnalysis.sorted { $0.key < $1.key }.reduce(into: [:]) { $0[$1.key] = $1.value }
    }
    
    // Other cool feature: calculate the team's average base stats
    func getAverageBaseStats() -> [String: Int] {
        guard !team.isEmpty else { return [:] }
        
        var totalStats: [String: Int] = [:]
        
        // Sum up all base stats for each category
        for pokemon in team {
            for statWrapper in pokemon.stats {
                totalStats[statWrapper.stat.name, default: 0] += statWrapper.base_stat
            }
        }
        
        // Calculate the average
        let teamCount = Double(team.count)
        return totalStats.mapValues { Int(Double($0) / teamCount) }
            .sorted { $0.key < $1.key }
            .reduce(into: [:]) { $0[$1.key] = $1.value }
    }
}
