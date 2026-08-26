//
//  AlbumHorizontalView.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 22/08/26.
//

import SwiftUI
internal import SwiftData

struct AlbumHorizontalView: View {
    @Environment(\.modelContext) private var context
    @EnvironmentObject var viewModel: EntityRelationship

    @Query(sort: [SortDescriptor(\AlbumEntity.nameAlbum)])
    private var albunsEntities: [AlbumEntity]

    var body: some View {
        Group {
            if albunsEntities.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "folder")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    Text("Nenhum álbum criado ainda")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: 10) {
                        ForEach(albunsEntities, id: \.idAlbum) { album in
                            NavigationLink {
                                AlbunsView(idAlbum: album.idAlbum)
                                    .environmentObject(viewModel)
                            } label: {
                                albumCard(album)
                                    .contextMenu{
                                        Button(role:.destructive){
                                            context.delete(album)
                                        } label: {
                                            Label("Apagar Álbum",systemImage: "trash")
                                        }
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
        }
    }

    @ViewBuilder
    private func albumCard(_ album: AlbumEntity) -> some View {
        let primeiraObraComImagem = album.art.first(where: { $0.imgArt != nil })
        let imgData = primeiraObraComImagem?.imgArt

        ZStack(alignment: .bottom) {
            if let imgData, let uiImage = UIImage(data: imgData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .frame(width: 150, height: 150)
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            }

            Text(album.nameAlbum ?? "Sem nome")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(16)
                .frame(maxWidth: 150, alignment: .leading)
                .background(
                    LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                )
        }
        .frame(width: 150, height: 150)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
