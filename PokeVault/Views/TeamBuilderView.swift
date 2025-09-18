import SwiftUI

struct TeamBuilderView: View {
    var body: some View {
        VStack {
            Text("Build Your Team")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .padding(.top, 20)
            
            Text("Add up to 6 Pokémon to your roster.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 40)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 3), spacing: 20) {
                ForEach(0..<6) { _ in
                    TeamSlotView()
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct TeamSlotView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(Color.white)
            .frame(height: 100)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            .overlay(
                Image(systemName: "plus.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.gray.opacity(0.4))
            )
    }
}
