//
//  AlbunsView.swift
//  Pictus
//
//  Created by Andre on 19/08/26.
//

import SwiftUI
import CoreData

struct AlbunsView: View {
    @EnvironmentObject var Vm: CoreDataRelationshipViewModel
    @Environment(\.dismiss) private var dismiss
    
    let idAlbum: UUID
    
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State var searchText = ""
    @State private var idNovaArteParaEditar: UUID? = nil
    
    var albumAtual: AlbumEntity? {
        let albuns = Vm.albunsEntities.compactMap { $0 as? AlbumEntity }
        return albuns.first { $0.idAlbum == idAlbum }
    }
    
    var obrasDoAlbum: [ArtEntity] {
        albumAtual?.art?.allObjects as? [ArtEntity] ?? []
    }
    
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
    
    var body: some View {
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
                
                Text(albumAtual?.nameAlbum ?? "Álbum")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                BtnAdd(ButtonAction: {
                    tratarCriacaoObraManual()
                }, icon: "plus")
                .frame(width: 48, height: 48)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            
            // Conteúdo com Scroll
            ScrollView {
                if filteredObras.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("Nenhuma obra neste álbum")
                            .font(.headline)
                        Text("Adicione obras a este álbum para visualizá-las aqui.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 60)
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredObras, id: \.objectID) { obra in
                            NavigationLink {
                                WorkOfDayContentView(obraAtual: obra, viewModel: Vm)
                            } label: {
                                ArtPreview(
                                    artName: obra.nameArt ?? "Sem Título",
                                    authorName: obra.nameAuthor ?? obra.local ?? "Desconhecido",
                                    dateArt: obra.dateArt?.formatted(date: .numeric, time: .omitted) ?? "",
                                    imgData: obra.imgArt
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
            }
            .searchable(text: $searchText, prompt: "Buscar obras no álbum")
        }
        .navigationBarHidden(true)
        .sheet(isPresented: Binding(
            get: { idNovaArteParaEditar != nil },
            set: { seAberto in
                if !seAberto { idNovaArteParaEditar = nil }
            }
        )) {
            if let uuid = idNovaArteParaEditar {
                NewArtView(viewModel: Vm, obraID: uuid)
            }
        }
    }
    
    private func tratarCriacaoObraManual() {
        let idArteVazia = Vm.addEmptyArt()
        
        if let albumId = albumAtual?.idAlbum {
            Vm.addObraToAlbuns(idAlbuns: [albumId], idArt: idArteVazia)
        }
        
        idNovaArteParaEditar = idArteVazia
    }
}

#Preview {
    AlbunsView(idAlbum: UUID())
        .environmentObject(CoreDataRelationshipViewModel())
}
