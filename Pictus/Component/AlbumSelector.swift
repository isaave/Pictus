//
//  AlbumSelector.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 20/08/26.
//

import SwiftUI
internal import SwiftData

struct AlbumSelector: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: EntityRelationship
    
    @Binding var selectedAlbums: Set<UUID>
    
    @Query(sort: [SortDescriptor(\AlbumEntity.nameAlbum)])
    private var albunsEntities: [AlbumEntity]
    
    let onConfirm: () -> Void

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if albunsEntities.isEmpty {
                    ContentUnavailableView(
                        "Nenhum álbum ainda",
                        systemImage: "folder",
                        description: Text("Crie álbuns para poder carregar suas obras a eles")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(albunsEntities, id: \.idAlbum) { album in
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
                    Button("Cancelar") { onConfirm() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Concluído") { onConfirm() }
                }
            }
        }
    }

    @ViewBuilder
    private func albumCard(_ album: AlbumEntity) -> some View {
        let isSelected = selectedAlbums.contains(album.idAlbum)

        ZStack(alignment: .bottomLeading) {
            if let imgData = album.imgAlbum, let uiImage = UIImage(data: imgData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(1, contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: "folder")
                            .foregroundStyle(.secondary)
                    }
            }

            Text(album.nameAlbum ?? "Álbum sem nome")
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
        .onTapGesture {
            if isSelected {
                selectedAlbums.remove(album.idAlbum)
            } else {
                selectedAlbums.insert(album.idAlbum)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AlbumEntity.self, ArtEntity.self, configurations: config)
    
    return AlbumSelector(
        selectedAlbums: .constant([]),
        onConfirm: {}
    )
    .environmentObject(EntityRelationship(context: container.mainContext))
    .modelContainer(container)
}
