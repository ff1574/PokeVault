import SwiftUI

struct SettingsView: View {
    @State private var showAbout = false
    @State private var showProfile = false
    @AppStorage("playerName") private var playerName = "Ash"
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Profile Header
                        VStack(spacing: 15) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.red, Color.orange]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .shadow(color: .red.opacity(0.4), radius: 10, x: 0, y: 5)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 45))
                                    .foregroundColor(.white)
                            }
                            
                            Text(playerName)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                            
                            Text("Pokémon Trainer")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 10)
                        
                        // Account Section
                        VStack(spacing: 12) {
                            SectionHeader(title: "Account")
                            
                            SettingsCard {
                                SettingsRow(
                                    icon: "person.circle.fill",
                                    title: "Edit Profile",
                                    iconColor: .blue,
                                    showChevron: true
                                )
                                .onTapGesture {
                                    showProfile = true
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Preferences Section
                        VStack(spacing: 12) {
                            SectionHeader(title: "Preferences")
                            
                            SettingsCard {
                                SettingsToggleRow(
                                    icon: "moon.fill",
                                    title: "Dark Mode",
                                    iconColor: .indigo,
                                    isOn: $isDarkMode
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // App Info Section
                        VStack(spacing: 12) {
                            SectionHeader(title: "About")
                            
                            SettingsCard {
                                SettingsRow(
                                    icon: "info.circle.fill",
                                    title: "About PokeVault",
                                    iconColor: .purple,
                                    showChevron: true
                                )
                                .onTapGesture {
                                    showAbout = true
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // App Version
                        Text("PokeVault v1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 10)
                            .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAbout) {
                AboutView()
            }
            .sheet(isPresented: $showProfile) {
                ProfileEditView(playerName: $playerName)
            }
        }
    }
}

// Section Header Component
struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.horizontal, 5)
    }
}

// Settings Card Container
struct SettingsCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Settings Row Component
struct SettingsRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    let showChevron: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .contentShape(Rectangle())
    }
}

// Settings Toggle Row Component
struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 30)
            
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
    }
}

// About View Sheet
struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.red.opacity(0.2), Color.orange.opacity(0.2)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.red)
                        .padding(.top, 40)
                    
                    Text("PokeVault")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                    
                    Text("Version 1.0.0")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        Text("About")
                            .font(.headline)
                        
                        Text("PokeVault is your ultimate Pokémon companion app. Browse the complete Pokédex, build powerful teams, and analyze type coverage to become the best trainer! This project was done for a college class to showcase the capabilities of Swift. ~ Franko")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// Profile Edit View Sheet
struct ProfileEditView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var playerName: String
    @State private var tempName: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Trainer Information")) {
                    HStack {
                        Text("Name")
                        TextField("Enter your name", text: $tempName)
                            .multilineTextAlignment(.trailing)
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        playerName = tempName
                        dismiss()
                    }
                    .disabled(tempName.isEmpty)
                }
            }
            .onAppear {
                tempName = playerName
            }
        }
    }
}
