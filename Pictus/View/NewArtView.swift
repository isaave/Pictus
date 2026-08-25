//
//  NewArtView.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 19/08/26.
//

import SwiftUI
import PhotosUI
import UIKit

struct NewArtView: View {
    @State private var upSheet = false
    @State private var selectedAlbums: Set<UUID> = []
    @Environment(\.dismiss) private var dismiss
    
    var art = ArtRelationship()
    @Query obrasEntities = [ArtEntity]
    
    let obraID: UUID
    
    private var obraAtual: ArtEntity? {
        obrasEntities.first(where: { $0.id == obraID })
    }
    
    @State private var nome = ""
    @State private var nomeAutor = ""
    @State private var dataCriacao = Date()
    @State private var local = ""

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var imagePreview: UIImage?

    @State private var isLoadingImage: Bool = false
    @State private var showImageError: Bool = false
    @State private var isFill: Bool = false
    
    @State private var showConfirmationAlert: Bool = false

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    VStack(spacing: -100) {
                        ZStack(alignment: .bottomLeading) {
                            if let imagePreview {
                                Image(uiImage: imagePreview)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: geometry.size.width)
                                    .frame(height: 400)
                                    .clipped()
                            } else {
                                ZStack {
                                    PhotosPicker(
                                        selection: $selectedPhoto,
                                        matching: .images
                                    ) {
                                        Group {
                                            Image(systemName: "photo")
                                        }
                                        .font(.title3)
                                        .foregroundStyle(.gray)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                                        .background(
                                            .black.opacity(0.3)
                                        )
                                    }
                                    .accessibilityLabel(
                                        imageData == nil
                                        ? "Selecionar imagem"
                                        : "Alterar imagem"
                                    )
                                }
                            }
                            
                            imagePickerButton
                        }
                        .frame(height: 400)
                    }
                    
                    NewArtInfo(
                        nome: $nome,
                        nomeAutor: $nomeAutor,
                        dataCriacao: $dataCriacao,
                        local: $local
                    )
                    
                    .padding()
                    
                    
                    if let obraAtual {
                        ReflectionCard(
                            obraAtual: obraAtual,
                            viewModel: viewModel,
                            hasButton: false
                        )
                        
                        .padding(.horizontal)
                    }
                    
                    HStack (alignment:.center){
                        Button {
                            save()
                        } label: {
                            Text("Registrar Obra")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(canSave ? Color.white : Color.gray.opacity(0.8))
                                .padding(.horizontal, 30)
                                .padding(.vertical)
                                .background {
                                    RoundedRectangle(
                                        cornerRadius: 32,
                                        style: .continuous
                                    )
                                    .fill(canSave ? Color.accentColor : .clear)
                                    .glassEffect(
                                        .regular.interactive(),
                                        in: .rect(
                                            cornerRadius: 32,
                                            style: .continuous
                                        )
                                    )
                                    .opacity(isFill ? 1.0 : 0.6)
                                }
                        }
                        .disabled(!canSave || !isFill)
                    }.padding()
                    
                }
                .background(Color(uiColor: .systemBackground))
                .ignoresSafeArea(edges: .top)
                .scrollDismissesKeyboard(.interactively)
                .onAppear {
                    isFill = !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }
                .onChange(of: nome) { oldValue, newValue in
                    isFill = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }
                .interactiveDismissDisabled()
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            upSheet.toggle()
                        } label: {
                            Image(systemName: "folder.fill.badge.plus")
                                .fontWeight(.semibold)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showConfirmationAlert = true
                        } label: {
                            Image(systemName: "chevron.backward")
                                .fontWeight(.semibold)
                        }
                        .sheet(isPresented: $upSheet) {
                            AlbumSelector(
                                Vm: viewModel, selectedAlbums: $selectedAlbums, onConfirm: {
                                    upSheet = false
                                }
                                
                                )
                        }
                    }
                    
                }
                .onChange(of: selectedPhoto) { newPhoto in
                    guard let newPhoto else { return }
                    
                    Task {
                        await loadImage(from: newPhoto)
                    }
                }
                .alert(
                    "Não foi possível carregar a imagem",
                    isPresented: $showImageError
                ) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Selecione outra imagem e tente novamente.")
                }
            }
            .overlay(
                Group {
                    if showConfirmationAlert {
                        ZStack {
                            Color.black.opacity(0.4)
                                .ignoresSafeArea()
                                .onTapGesture { showConfirmationAlert = false }

                            ConfirmationAlert(
                                title: "Atenção!",
                                message: "Você possui alterações que não foram salvas.",
                                question: "Deseja salvar as alterações?",
                                confirmTitle: "Salvar",
                                cancelTitle: "Descartar",
                                onConfirm: {
                                    if canSaveBack {
                                        save()
                                        showConfirmationAlert = false
                                    }
                                },
                                onCancel: {
                                    discart()
                                    showConfirmationAlert = false
                                }
                            )
                        }
                    }
                }
            )
        }
    }
}

private extension NewArtView {

    var imagePickerButton: some View {
        VStack {
            HStack {
                Spacer()
                PhotosPicker(
                    selection: $selectedPhoto,
                    matching: .images
                ) {
                    Group {
                        Image(systemName: "photo")
                            .foregroundColor(.clear)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 250)
                }
            }

            Spacer()
        }
        .padding(.top, 105)
        .padding(.horizontal, 16)
    }
}

private extension NewArtView {

    var canSave: Bool {
        imageData != nil && !isLoadingImage && isFill
    }
    
    var canSaveBack: Bool {
        imageData != nil && !isLoadingImage
    }

    private func save() {
        viewModel.editObra(
            name: nomeAutor,
            nameArt: nome,
            data: dataCriacao,
            local: local,
            img: imageData,
            uuid: obraID
        )

        dismiss()
    }
    
    private func discart() {
        viewModel.deleteArt(
            uuid: obraID
        )
        dismiss()
    }
    
    @MainActor
    func loadImage(from item: PhotosPickerItem) async {

        isLoadingImage = true

        defer {
            isLoadingImage = false
        }

        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data)
            else {
                showImageError = true
                return
            }

            imageData = data
            imagePreview = uiImage

        } catch {
            imageData = nil
            imagePreview = nil
            showImageError = true
        }
    }
}

#Preview {
    NewArtView(
        viewModel: CoreDataRelationshipViewModel(),
        obraID: UUID()
    )
}
