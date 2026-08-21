//
//  AllAlbunsView.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 21/08/26.
//

import SwiftUI

struct AllAlbunsView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var Vm: CoreDataRelationshipViewModel
    
    @State private var searchText = ""
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var filteredAlbuns: [AlbumEntity] {
        
        if searchText.isEmpty {
            return Vm.albunsEntities
        } else {
            return Vm.albunsEntities.filter {
                ($0.nameAlbum ?? "")
                    .localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        
        NavigationStack {
            
            VStack(spacing: 0) {
                
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
                            print("Adicionar álbum")
                        },
                        icon: "plus"
                    )
                    .frame(width: 48, height: 48)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                
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
                            
                            ForEach(
                                filteredAlbuns,
                                id: \.objectID
                            ) { album in
                                
                                if let idAlbum = album.idAlbum {
                                    
                                    NavigationLink {
                                        
                                        AlbunsView(
                                            idAlbum: idAlbum
                                        )
                                        .environmentObject(Vm)
                                        
                                    } label: {
                                        
                                        AlbumCover(
                                            albumName: album.nameAlbum ?? "Sem nome",
                                            coverWidth: 175,
                                            coverHeight: 210
                                        )
                                    }
                                    .buttonStyle(.plain)
                                }
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
        }
    }
}

#Preview {
    AllAlbunsView()
        .environmentObject(
            CoreDataRelationshipViewModel()
        )
}


//MEUS TESTES kkkkk nao consigo apagar mais os albuns
//#Preview {
//    
//    let vm = CoreDataRelationshipViewModel()
//    
//    vm.adicionarAlbunsTeste()
//    
//    return AllAlbunsView()
//        .environmentObject(vm)
//}
