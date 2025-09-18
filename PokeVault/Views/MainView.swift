import SwiftUI

struct MainView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.red.opacity(0.8), Color.white.opacity(0.8)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image("pokeball")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .shadow(radius: 10)
                
                Text("PokeVault")
                    .font(.system(size: 40, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                Text("Your personal Pokémon companion.")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
    }
}
