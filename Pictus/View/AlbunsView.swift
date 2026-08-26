//
//  AlbunsView.swift
//  Pictus
//
//  Created by Andre on 19/08/26.
//

import SwiftUI
internal import SwiftData

struct AlbunsView: View {
    
    @Environment(\.modelContext) private var context
    @EnvironmentObject var viewModel: EntityRelationship
    @Query var albunsEntities: [AlbumEntity]
    @Query var obrasEntities: [ArtEntity]
    
    @Environment(\.dismiss) private var dismiss
    
    public let idAlbum: UUID
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    @State var searchText = ""
    @State private var obraAtual: ArtEntity? = nil
    
    var albumAtual: AlbumEntity? {
        return albunsEntities.first { $0.idAlbum == idAlbum }
    }
    
    var obrasDoAlbum: [ArtEntity] {
       
        return albumAtual?.art ?? []
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
                        ForEach(filteredObras, id: \.id) { obra in
                            NavigationLink {
                                WorkOfDayContentView(obra: obra,viewModel: viewModel)
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
        // CORREÇÃO 4: Atualização de modificador depreciado
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $obraAtual) { obra in
            NewArtView(obraAtual: obra)
        }
    }
    
    private func tratarCriacaoObraManual() {
        let idArteVazia = EntityRelationship(context: context).addEmptyArt(in: context)
        
        if let albumAtual = albumAtual {
            let descriptor = FetchDescriptor<ArtEntity>(predicate: #Predicate { $0.id == idArteVazia })
            
            if let novaObra = try? context.fetch(descriptor).first {
                if albumAtual.art == nil {
                    albumAtual.art = []
                }
                albumAtual.art?.append(novaObra)
            }
        }
        
        // Abre a sheet de edição
    }
}
