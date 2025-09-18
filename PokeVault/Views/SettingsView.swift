import SwiftUI

struct SettingsView: View {
    var body: some View {
        Form {
            Section(header: Text("Account").font(.headline)) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.blue)
                    Text("Profile")
                }
                HStack {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.red)
                    Text("Change Password")
                }
                HStack {
                    Image(systemName: "arrow.right.square.fill")
                        .foregroundColor(.gray)
                    Text("Log Out")
                }
            }
            
            Section(header: Text("General").font(.headline)) {
                HStack {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.purple)
                    Text("About")
                }
                HStack {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.yellow)
                    Text("Notifications")
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.gray.opacity(0.1))
    }
}
