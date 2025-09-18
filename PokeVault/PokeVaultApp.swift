import SwiftUI

@main
struct PokeVaultApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            // Main Screen
            MainView()
                .tabItem {
                    Label("Main", systemImage: "house.fill")
                }

            // Pokedex Screen
            PokedexView()
                .tabItem {
                    Label("Pokedex", systemImage: "list.bullet.circle.fill")
                }

            // Team Builder Screen
            TeamBuilderView()
                .tabItem {
                    Label("Team", systemImage: "person.3.fill")
                }

            // Settings Screen
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}
