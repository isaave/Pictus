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
                // Barra Superior Personalizada (Alinhada como na sua imagem)
                HStack {
                    // Botão de Voltar personalizado
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 48, height: 48)
                            .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 55, style: .continuous))
                    }
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    // Título Centralizado
                    Text("Álbuns")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    // Botão de Adicionar (BtnAdd)
                    BtnAdd(ButtonAction: {
                        print("Add clicado")
                    }, icon: "plus")
                    .frame(width: 48, height: 48)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                
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
            .navigationBarHidden(true) // Oculta a barra nativa para usar apenas a nossa personalizada
        }
    }
}

#Preview {
    AlbunsView()
}
