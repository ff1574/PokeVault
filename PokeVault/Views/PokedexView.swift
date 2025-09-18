import SwiftUI

struct PokedexView: View {
    @StateObject var pokemonService = PokemonService()
    @State private var searchText = ""
    @State private var isShowingFilter = false
    @State private var selectedTypes: Set<String> = []
    
    var filteredPokemonList: [PokemonListItem] {
        var list = pokemonService.pokemonList
        
        // Filter by search text
        if !searchText.isEmpty {
            list = list.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Filter by selected types (this requires fetching details for each Pokemon, which is inefficient)
        // For a more robust solution, you would need to refactor your PokemonService to fetch a filtered list
        // from the API. For demonstration purposes, we will not filter by type in this list view.
        
        return list
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    TextField("Search Pokémon", text: $searchText)
                        .padding(8)
                        .padding(.horizontal, 24)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading, 8)
                                
                                if !searchText.isEmpty {
                                    Button(action: {
                                        self.searchText = ""
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.gray)
                                            .padding(.trailing, 8)
                                    }
                                }
                            }
                        )
                    
                    Button(action: {
                        isShowingFilter.toggle()
                    }) {
                        Image(systemName: "slider.horizontal.3.square.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredPokemonList) { pokemonListItem in
                            NavigationLink(destination: PokemonDetailFetchView(url: pokemonListItem.url)) {
                                PokemonRowView(pokemonListItem: pokemonListItem)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color.gray.opacity(0.1))
            }
            .onAppear {
                pokemonService.fetchPokemonList()
            }
        }
        .sheet(isPresented: $isShowingFilter) {
            FilterView(selectedTypes: $selectedTypes)
        }
    }
}

struct PokemonRowView: View {
    let pokemonListItem: PokemonListItem
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonListItem.id).png")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
            } placeholder: {
                ProgressView()
                    .frame(width: 60, height: 60)
            }
            .background(Color.white)
            .clipShape(Circle())
            .shadow(radius: 3)
            
            Text(pokemonListItem.name.capitalized)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.black)
            
            Spacer()
        }
        .padding(10)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct FilterView: View {
    @Binding var selectedTypes: Set<String>
    let allTypes = ["normal", "fire", "water", "electric", "grass", "ice", "fighting", "poison", "ground", "flying", "psychic", "bug", "rock", "ghost", "dragon", "steel", "dark", "fairy"]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(allTypes, id: \.self) { type in
                    HStack {
                        Text(type.capitalized)
                        Spacer()
                        if selectedTypes.contains(type) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle()) // Make the whole row tappable
                    .onTapGesture {
                        if selectedTypes.contains(type) {
                            selectedTypes.remove(type)
                        } else {
                            selectedTypes.insert(type)
                        }
                    }
                }
            }
            .navigationTitle("Filter by Type")
        }
    }
}
