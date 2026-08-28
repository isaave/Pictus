//
//  ArtSelector.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 26/08/26.
//

import SwiftUI
internal import SwiftData

struct ArtSelector: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let album: AlbumEntity?
    
    @State private var selectedArtIDs: Set<UUID> = []
    
    @Query(sort: [SortDescriptor(\ArtEntity.nameArt)])
    private var todasAsObras: [ArtEntity]
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            Group {
                if todasAsObras.isEmpty {
                    ContentUnavailableView(
                        "Nenhuma obra disponível",
                        systemImage: "photo.on.rectangle.angled",
                        description: Text("Cadastre obras no app para poder vinculá-las a este álbum.")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(todasAsObras, id: \.id) { obra in
                                artCard(obra)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                    }
                }
            }
            .navigationTitle("Adicionar Obras")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Concluído") {
                        adicionarObrasAoAlbum()
                        dismiss()
                    }
                }
            }
            .onAppear {
                carregarObrasDoAlbum()
            }
        }
    }
    
    @ViewBuilder
    private func artCard(_ obra: ArtEntity) -> some View {
        let isSelected = selectedArtIDs.contains(obra.id)
        
        ZStack(alignment: .bottomLeading) {
            if let imgData = obra.imgArt, let uiImage = UIImage(data: imgData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 250)
                    .aspectRatio(1, contentMode: .fill)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.15))
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                    }
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(obra.nameArt ?? "Sem Título")
                    .font(.caption)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Text(obra.nameAuthor ?? obra.local ?? "Desconhecido")
                    .font(.caption2)
                    .opacity(0.8)
                    .lineLimit(1)
            }
            .foregroundStyle(.white)
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
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
                .strokeBorder(isSelected ? Color.blue : Color.clear, lineWidth: 3)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if isSelected {
                selectedArtIDs.remove(obra.id)
            } else {
                selectedArtIDs.insert(obra.id)
            }
        }
    }
    
    // MARK: - Funções Locais de Persistência
    
    private func carregarObrasDoAlbum() {
        if let obrasJaNoAlbum = album?.art {
            selectedArtIDs = Set(obrasJaNoAlbum.map { $0.id })
        }
    }
    
    private func adicionarObrasAoAlbum() {
        guard let album = album else { return }
        
        let obrasSelecionadas = todasAsObras.filter { selectedArtIDs.contains($0.id) }
        
        // Adiciona as selecionadas sem duplicar referências existentes
        for obra in obrasSelecionadas where !album.art.contains(where: { $0.id == obra.id }) {
            album.art.append(obra)
        }
        
        try? modelContext.save()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: AlbumEntity.self, ArtEntity.self, configurations: config)
    let context = container.mainContext
    
    let albumExemplo = AlbumEntity(nameAlbum: "Modernismo", imgAlbum: nil)
    context.insert(albumExemplo)
    
    let obraExemplo = ArtEntity()
    obraExemplo.id = UUID()
    obraExemplo.nameArt = "Abaporu"
    obraExemplo.nameAuthor = "Tarsila do Amaral"
    context.insert(obraExemplo)
    
    try? context.save()
    
    return ArtSelector(album: albumExemplo)
        .modelContainer(container)
}
