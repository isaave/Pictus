import SwiftUI

struct AlbunsView: View {
    @Environment(\.dismiss) private var dismiss
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State var searchText = ""
        let names = ["Grafite", "Realismo", "Pintura", "Barroco", "Retrato", "Pré-Historia","Fauvismo"]
    var filteredNames: [String] {
        if searchText.isEmpty {
            return names
        } else {
            return names.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        
            ScrollView {
                LazyVGrid(columns: columns) {                    ForEach(filteredNames, id: \.self) { album in
                        AlbumCover(albumName: album)
                    }
                }
            }
            .navigationTitle("Álbuns")
            .searchable(text: $searchText, prompt: "Buscar álbuns")
            .toolbar{
                ToolbarItem(placement:.topBarTrailing){
                    BtnAdd(ButtonAction: {
                        print("Add")
                    })
                }
            }
    }
}

#Preview {
    AlbunsView()
}
