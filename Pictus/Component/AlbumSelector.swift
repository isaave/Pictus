//
//  AlbumSelector.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 20/08/26.
//
import SwiftUI
struct AlbumSelector: View {
    @ObservedObject var Vm: CoreDataRelationshipViewModel
    @Binding var selectedAlbums: Set<UUID>

    let onConfirm: () -> Void

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            Group {
                      if Vm.albunsEntities.isEmpty {
                          ContentUnavailableView(
                              "Nenhum álbum ainda",
                              systemImage: "folder",
                              description: Text("Crie albuns para poder caregar suas obras a eles")
                          )
                      } else {
                          ScrollView {
                              LazyVGrid(columns: columns, spacing: 12) {
                                  ForEach(Vm.albunsEntities, id: \.idAlbum) { album in
                                      albumCard(album)
                                  }
                              }
                              .padding(.horizontal)
                          }
                      }
                  }
                  .navigationTitle("Selecione os álbuns da obra")
                  .navigationBarTitleDisplayMode(.inline)
                  .toolbar {
                      ToolbarItem(placement: .cancellationAction) {
                          Button(role: .close) { onConfirm() }
                      }
                      ToolbarItem(placement: .confirmationAction) {
                          Button(role: .confirm) { onConfirm() }
                              .disabled(selectedAlbums.isEmpty)
                      }
                  }
                  .onAppear { Vm.fetchAlbuns() }
              }
          }

    @ViewBuilder
    private func albumCard(_ album: AlbumEntity) -> some View {
        let isSelected = selectedAlbums.contains(album.idAlbum ?? UUID())

        ZStack(alignment: .center) {
            if let imgData = album.imgAlbum, let uiImage = UIImage(data: imgData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(1, contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
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

            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.white, .blue)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(6)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(.blue, lineWidth: isSelected ? 3 : 0)
        )
        .onLongPressGesture(minimumDuration: 0.5) {
            if let id = album.idAlbum {
                if selectedAlbums.contains(id) {
                    selectedAlbums.remove(id)
                } else {
                    selectedAlbums.insert(id)
                }
            }
        }
        .onTapGesture {
            if !selectedAlbums.isEmpty, let id = album.idAlbum {
                if selectedAlbums.contains(id) {
                    selectedAlbums.remove(id)
                } else {
                    selectedAlbums.insert(id)
                }
            }
        }
    }
}

#Preview {
    AlbumSelector(
        Vm: CoreDataRelationshipViewModel(),
        selectedAlbums: .constant([]),
        onConfirm: {}
    )
}
