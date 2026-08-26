//
//  AlbumHorizontalView.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 22/08/26.
//

import SwiftUI
internal import SwiftData

struct AlbumHorizontalView: View {
    @Environment(\.modelContext) private var modelContext
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
                            if let idAlbum = album.idAlbum {
                                NavigationLink {
                                    AlbunsView(idAlbum: idAlbum)
                                        .environmentObject(viewModel)
                                } label: {
                                    albumCard(album)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal, 15)
                }
            }
        }
    }

    @ViewBuilder
    private func albumCard(_ album: AlbumEntity) -> some View {
        ZStack(alignment: .center) {
            if let imgData = album.imgAlbum, let uiImage = UIImage(data: imgData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .aspectRatio(1, contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            }

            Text(album.nameAlbum ?? "Sem nome")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(colors: [.clear, .black.opacity(0.6)], startPoint: .top, endPoint: .bottom)
                )
        }
        .frame(width: 130, height: 155)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
