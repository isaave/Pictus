//
//  AllAlbunsView.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 21/08/26.
//

import SwiftUI

struct AllAlbunsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var Vm: SwiftDataRelationshipViewModel
    
    @State private var searchText = ""
    @State private var mostrarAddAlbum = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var filteredAlbuns: [AlbumEntity] {
        let albuns = Vm.albunsEntities
        if searchText.isEmpty {
            return albuns
        } else {
            return albuns.filter {
                ($0.nameAlbum ?? "")
                    .localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // Barra Superior
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 48, height: 48)
                        .glassEffect(
                            .regular.interactive(),
                            in: .rect(
                                cornerRadius: 55,
                                style: .continuous
                            )
                        )
                }
                .shadow(
                    color: .black.opacity(0.08),
                    radius: 10,
                    x: 0,
                    y: 5
                )
                .buttonStyle(.plain)
                
                Spacer()
                
                Text("Álbuns")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                BtnAdd(
                    ButtonAction: {
                        mostrarAddAlbum = true
                    },
                    icon: "plus"
                )
                .frame(width: 48, height: 48)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // Conteúdo
            ScrollView {
                if filteredAlbuns.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "rectangle.stack")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        
                        Text("Nenhum álbum encontrado")
                            .font(.headline)
                        
                        Text("Você ainda não possui álbuns.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                    
                } else {
                    LazyVGrid(
                        columns: columns,
                        spacing: 16
                    ) {
                        ForEach(filteredAlbuns) { album in
                            NavigationLink {
                                AlbunsView(idAlbum: album.idAlbum)
                                    .environmentObject(Vm)
                            } label: {
                                let obrasDoAlbum = album.art
                                let primeiraImagemValida = obrasDoAlbum.compactMap { $0.imgArt }.first
                                
                                AlbumCover(
                                    albumName: album.nameAlbum ?? "Sem nome",
                                    coverData: primeiraImagemValida,
                                    coverWidth: 175,
                                    coverHeight: 210
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .searchable(
                text: $searchText,
                prompt: "Buscar álbuns"
            )
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $mostrarAddAlbum) {
            AddAlbumView()
                .environmentObject(Vm)
        }
    }
}

#Preview {
    AllAlbunsView()
        .environmentObject(
            SwiftDataRelationshipViewModel()
        )
}
