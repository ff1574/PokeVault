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
    @StateObject private var teamManager = TeamManager()
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Screen
            MainView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Main", systemImage: "house.fill")
                }
                .tag(0)

            // Pokedex Screen
            PokedexView()
                .tabItem {
                    Label("Pokedex", systemImage: "list.bullet.circle.fill")
                }
                .tag(1)

            // Team Builder Screen
            TeamBuilderView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Team", systemImage: "person.3.fill")
                }
                .tag(2)

            // Settings Screen
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(3)
        }
        .environmentObject(teamManager)
    }
}
