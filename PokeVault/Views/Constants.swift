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
