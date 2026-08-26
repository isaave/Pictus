//
//  AllAlbunsView.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 21/08/26.
//

import SwiftUI
internal import SwiftData

struct AllAlbunsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var searchText = ""
    @State private var mostrarAddAlbum = false

    @Query var albunsEntities: [AlbumEntity]

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var filteredAlbuns: [AlbumEntity] {
        if searchText.isEmpty {
            return albunsEntities
        } else {
            return albunsEntities.filter {
                ($0.nameAlbum ?? "")
                    .localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
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
                        mostrarAddAlbum = true
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
                        ForEach(filteredAlbuns, id: \.idAlbum) { album in
                            
                                NavigationLink {
                                    AlbunsView(idAlbum: album.idAlbum)
                                } label: {
                                    AlbumCover(albumName: album.nameAlbum ?? "Nome",coverData: album.imgAlbum, coverWidth: 150, coverHeight: 200,)
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
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .searchable(
                text: $searchText,
                prompt: "Buscar álbuns"
            )
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $mostrarAddAlbum) {
            AddAlbumView()
        }
    }
}

