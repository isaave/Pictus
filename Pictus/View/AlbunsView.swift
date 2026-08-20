import SwiftUI

struct AlbunsView: View {
    @Environment(\.dismiss) private var dismiss
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State var searchText = ""
    let names = ["Grafite", "Realismo", "Pintura", "Barroco", "Retrato", "Pré-Historia", "Fauvismo"]
    
    var filteredNames: [String] {
        if searchText.isEmpty {
            return names
        } else {
            return names.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Conteúdo com Scroll
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredNames, id: \.self) { album in
                            AlbumCover(albumName: album, coverWidth: 175, coverHeight: 210)
                        }
                    }
                    .padding(.top, 16)
                }
                .searchable(text: $searchText, prompt: "Buscar álbuns")
            }
          
        }
        .navigationTitle("Albuns")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button{
                }label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

#Preview {
    AlbunsView()
}
