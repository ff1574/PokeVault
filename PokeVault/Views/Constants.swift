import SwiftUI

struct Constants {
    static let pokemonTypeColor: [String: Color] = [
        "normal": Color(hex: "A8A77A"),
        "fire": Color(hex: "EE8130"),
        "water": Color(hex: "6390F0"),
        "electric": Color(hex: "F7D02C"),
        "grass": Color(hex: "7AC74C"),
        "ice": Color(hex: "96D9D6"),
        "fighting": Color(hex: "C22E28"),
        "poison": Color(hex: "A33EA1"),
        "ground": Color(hex: "E2BF65"),
        "flying": Color(hex: "A98FF3"),
        "psychic": Color(hex: "F95587"),
        "bug": Color(hex: "A6B91A"),
        "rock": Color(hex: "B6A136"),
        "ghost": Color(hex: "735797"),
        "dragon": Color(hex: "6F35FC"),
        "steel": Color(hex: "B7B7CE"),
        "dark": Color(hex: "705746"),
        "fairy": Color(hex: "DDA0DD")
    ]
    
    static let allTypes = [
        "normal", "fire", "water", "electric", "grass", "ice",
        "fighting", "poison", "ground", "flying", "psychic", "bug",
        "rock", "ghost", "dragon", "dark", "steel", "fairy"
    ]

    static let pokemonTypeInteraction: [String: [String: Double]] = [
        "normal": ["rock": 0.5, "ghost": 0.0, "steel": 0.5],
        "fire": ["fire": 0.5, "water": 0.5, "grass": 2.0, "ice": 2.0, "bug": 2.0, "rock": 0.5, "dragon": 0.5, "steel": 2.0],
        "water": ["fire": 2.0, "water": 0.5, "grass": 0.5, "ground": 2.0, "rock": 2.0, "dragon": 0.5],
        "electric": ["water": 2.0, "electric": 0.5, "grass": 0.5, "ground": 0.0, "flying": 2.0, "dragon": 0.5],
        "grass": ["fire": 0.5, "water": 2.0, "grass": 0.5, "poison": 0.5, "ground": 2.0, "flying": 0.5, "bug": 0.5, "rock": 2.0, "dragon": 0.5, "steel": 0.5],
        "ice": ["fire": 0.5, "water": 0.5, "grass": 2.0, "ice": 0.5, "ground": 2.0, "flying": 2.0, "dragon": 2.0, "steel": 0.5],
        "fighting": ["normal": 2.0, "ice": 2.0, "poison": 0.5, "flying": 0.5, "psychic": 0.5, "bug": 0.5, "rock": 2.0, "ghost": 0.0, "dark": 2.0, "steel": 2.0, "fairy": 0.5],
        "poison": ["grass": 2.0, "poison": 0.5, "ground": 0.5, "rock": 0.5, "ghost": 0.5, "steel": 0.0, "fairy": 2.0],
        "ground": ["fire": 2.0, "electric": 2.0, "grass": 0.5, "poison": 2.0, "flying": 0.0, "bug": 0.5, "rock": 2.0, "steel": 2.0],
        "flying": ["electric": 0.5, "grass": 2.0, "fighting": 2.0, "bug": 2.0, "rock": 0.5, "steel": 0.5],
        "psychic": ["fighting": 2.0, "poison": 2.0, "psychic": 0.5, "dark": 0.0, "steel": 0.5],
        "bug": ["fire": 0.5, "grass": 2.0, "fighting": 0.5, "poison": 0.5, "flying": 0.5, "psychic": 2.0, "ghost": 0.5, "dark": 2.0, "steel": 0.5, "fairy": 0.5],
        "rock": ["fire": 2.0, "ice": 2.0, "fighting": 0.5, "ground": 0.5, "flying": 2.0, "bug": 2.0, "steel": 0.5],
        "ghost": ["normal": 0.0, "psychic": 2.0, "ghost": 2.0, "dark": 0.5],
        "dragon": ["dragon": 2.0, "steel": 0.5, "fairy": 0.0],
        "dark": ["fighting": 0.5, "psychic": 2.0, "ghost": 2.0, "dark": 0.5, "fairy": 0.5],
        "steel": ["fire": 0.5, "water": 0.5, "electric": 0.5, "ice": 2.0, "rock": 2.0, "steel": 0.5, "fairy": 2.0],
        "fairy": ["fire": 0.5, "fighting": 2.0, "poison": 0.5, "dragon": 2.0, "dark": 2.0, "steel": 0.5]
    ]

}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
