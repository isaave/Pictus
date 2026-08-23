//
//  AlbumHorizontalView.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 22/08/26.
//

import SwiftUI

struct AlbumHorizontalView: View {
    @ObservedObject var Vm: CoreDataRelationshipViewModel

    var body: some View {
        Group {
            if Vm.albunsEntities.isEmpty {
                // ✅ Mensagem quando não tem álbuns
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
                        ForEach(Vm.albunsEntities, id: \.objectID) { album in
                            if let idAlbum = album.idAlbum {
                                NavigationLink {
                                    AlbunsView(idAlbum: idAlbum)
                                        .environmentObject(Vm)
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
        .onAppear { Vm.fetchAlbuns() }
    }

    @ViewBuilder
    private func albumCard(_ album: AlbumEntity) -> some View {
        ZStack(alignment: .bottomLeading) {
            if let imgData = album.imgAlbum, let uiImage = UIImage(data: imgData) {
                Image(uiImage: uiImage)
                    .resizable()
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

#Preview {
    AlbumHorizontalView(Vm: CoreDataRelationshipViewModel())
}
