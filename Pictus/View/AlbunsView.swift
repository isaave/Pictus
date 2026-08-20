//
//  AlbunsView.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 17/08/26.
//

import SwiftUI

struct AlbunsView: View {
    @Environment(\.dismiss) private var dismiss
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    @State var searchText = ""
    
    // Recebe a lista de álbuns vinda da tela anterior
    let albuns: [MockAlbum]
    
    var filteredAlbuns: [MockAlbum] {
        if searchText.isEmpty {
            return albuns
        } else {
            return albuns.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Barra Superior Personalizada
                HStack {
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
                    
                    Text("Álbuns")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
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
                        ForEach(filteredAlbuns, id: \.name) { album in
                            AlbumCover(albumName: album.name, coverWidth: 175, coverHeight: 210)
                        }
                    }
                    .padding(.top, 16)
                }
                .searchable(text: $searchText, prompt: "Buscar álbuns")
            }
            .navigationBarHidden(true)
        }
    }
}

#Preview {
    AlbunsView(albuns: [
        MockAlbum(name: "Grafite", category: .discoveries),
        MockAlbum(name: "Realismo", category: .discoveries),
        MockAlbum(name: "Pintura", category: .discoveries),
        MockAlbum(name: "Barroco", category: .discoveries),
        MockAlbum(name: "Retrato", category: .discoveries),
        MockAlbum(name: "Pré-Historia", category: .discoveries),
        MockAlbum(name: "Fauvismo", category: .discoveries)
    ])
}
