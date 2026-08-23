//
//  AlbunsView.swift
//  Pictus
//
//  Created by Andre on 19/08/26.
//
//======================================================================
//
//  ATENÇÃO!!
//
//  Alterei essa tela para mostrar as obras de um album.
//  Ou seja, ela recebe um idAlbum e mostra todas as Obras desse album.
//  Para mostrar todos os albuns, criei a AllAlbunsView.
//
//  Mod Pedro Henrique Hossaka Teruel 21/08/26

import SwiftUI

struct AlbunsView: View {

    
    @EnvironmentObject var Vm: CoreDataRelationshipViewModel
    @Environment(\.dismiss) private var dismiss
    
    let idAlbum: UUID
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State var searchText = ""
    
    var filteredObras: [ArtEntity] {

        if searchText.isEmpty {
            return obrasDoAlbum
        } else {
            return obrasDoAlbum.filter {
                ($0.nameArt ?? "")
                    .localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var albumAtual: AlbumEntity? {
        Vm.albunsEntities.first {
            $0.idAlbum == idAlbum
        }
    }
    
    var obrasDoAlbum: [ArtEntity] {
        albumAtual?.art?.allObjects as? [ArtEntity] ?? []
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Barra Superior Personalizada (Alinhada como na sua imagem)
                HStack {
                    // Botão de Voltar personalizado
                    // view builder e importar como var
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
                    Text(albumAtual?.nameAlbum ?? "Álbum")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
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
                        ForEach(filteredObras, id: \.objectID) { obra in

                            Text(obra.nameArt ?? "Sem nome")
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
    AlbunsView(idAlbum: UUID())
        .environmentObject(CoreDataRelationshipViewModel())
}
