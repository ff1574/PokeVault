import SwiftUI

struct PokedexView: View {
    @StateObject var pokemonService = PokemonService()
    @State private var searchText = ""
    @State private var isShowingFilter = false
    @State private var selectedTypes: Set<String> = []
    
    var filteredPokemonList: [Pokemon] {
        var list = pokemonService.detailedPokemonList
        
        // Filter by search text
        if !searchText.isEmpty {
            list = list.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Filter by selected types
        if !selectedTypes.isEmpty {
            list = list.filter { pokemon in
                let pokemonTypes = pokemon.types.map { $0.type.name }
                // Check if any of the pokemon's types are in the selected types set
                return !selectedTypes.isDisjoint(with: pokemonTypes)
            }
        }
        
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
                            }
                        )
                    
                    Button(action: {
                        isShowingFilter.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .padding(.leading, 8)
                    .sheet(isPresented: $isShowingFilter) {
                        FilterView(selectedTypes: $selectedTypes)
                    }
                }
                .padding()
                
                if pokemonService.isLoading {
                    ProgressView("Loading Pokémon...")
                        .padding()
                } else if filteredPokemonList.isEmpty && !searchText.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                } else if filteredPokemonList.isEmpty && selectedTypes.isEmpty {
                    Text("No Pokémon found.")
                } else {
                    List(filteredPokemonList) { pokemon in
                        NavigationLink(destination: PokemonDetailView(pokemon: pokemon)) {
                            PokemonCardView(pokemon: pokemon)
                        }
                        .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                }
            }
            .onAppear {
                if pokemonService.detailedPokemonList.isEmpty {
                    pokemonService.fetchPokemonList()
                }
            }
        }
    }
}

struct PokemonCardView: View {
    let pokemon: Pokemon
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: pokemon.sprites.front_default ?? "")) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                } else {
                    ProgressView()
                        .frame(width: 80, height: 80)
                }
            }
            
            VStack(alignment: .leading, spacing: 5) {
                // ID
                Text(String(format: "#%03d", pokemon.id))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Name
                Text(pokemon.name.capitalized)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                // Type Icons
                HStack(spacing: 5) {
                    ForEach(pokemon.types, id: \.type.name) { typeWrapper in
                        Image(typeWrapper.type.name.lowercased())
                            .resizable()
                            .frame(width: 25, height: 25)
                            .shadow(radius: 2)
                    }
                }
            }
            
            Spacer()
        }
        .padding(10)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct FilterView: View {
    @Binding var selectedTypes: Set<String>
    @Environment(\.dismiss) var dismiss
    let allTypes = Constants.allTypes;
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(allTypes, id: \.self) { type in
                    HStack(spacing: 15) {
                        Image(type)
                            .resizable()
                            .frame(width: 30, height: 30)
                            .shadow(radius: 2)
                        Text(type.capitalized)
                        Spacer()
                        if selectedTypes.contains(type) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle())
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
