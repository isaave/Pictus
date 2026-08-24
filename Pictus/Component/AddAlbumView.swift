//
//  AddAlbumView.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 22/08/26.
//

import SwiftUI
import CoreData

struct AddAlbumView: View {
    @EnvironmentObject var Vm: CoreDataRelationshipViewModel
    @Environment(\.dismiss) var dismiss

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ArtEntity.dateArt, ascending: false)]
    ) private var obrasEntities: FetchedResults<ArtEntity>

    @State private var nomeAlbum: String = ""
    @State private var obrasSelecionadas: [ArtEntity] = []

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            Group {
                if obrasEntities.isEmpty {
                    ContentUnavailableView(
                        "Nenhuma obra encontrada",
                        systemImage: "paintbrush",
                        description: Text("Crie uma obra antes de montar um álbum.")
                    )
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            Text("Escolha o nome do álbum abaixo")
                                .font(Font.body.bold())
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                            
                            TextField("EX: renascentista", text: $nomeAlbum)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal)

                            HStack {
                                Text("Selecione as obras")
                                    .font(.system(size: 18, weight: .bold))
                                Spacer()
                            }
                            .padding(.horizontal)

                            LazyVGrid(columns: columns, spacing: 12) {
                                ForEach(obrasEntities, id: \.objectID) { obra in
                                    obraSelectionCard(obra)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Novo Álbum")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        Vm.addAlbuns(nome: nomeAlbum, obras: obrasSelecionadas)
                        dismiss()
                    }
                    .disabled(nomeAlbum.isEmpty || obrasSelecionadas.isEmpty)
                }
            }
        }
    }

    @ViewBuilder
    private func obraSelectionCard(_ obra: ArtEntity) -> some View {
        let isSelected = obrasSelecionadas.contains(where: { $0.objectID == obra.objectID })

        ZStack(alignment: .bottomLeading) {
            if let imgData = obra.imgArt, let uiImage = UIImage(data: imgData) {
                Image(uiImage: uiImage)
                    .resizable()
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

            Text(obra.nameArt ?? "Sem título")
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
                obrasSelecionadas.removeAll { $0.objectID == obra.objectID }
            } else {
                obrasSelecionadas.append(obra)
            }
        }
    }
}

#Preview("Com obras disponíveis") {
    let vm = CoreDataRelationshipViewModel()
    vm.seedObrasIfNeeded()
    return NavigationStack {
        AddAlbumView()
            .environmentObject(vm)
    }
}

#Preview("Sem obras") {
    let vm = CoreDataRelationshipViewModel()
    return NavigationStack {
        AddAlbumView()
            .environmentObject(vm)
    }
}
