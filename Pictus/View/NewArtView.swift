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
    
    @ObservedObject var viewModel: CoreDataRelationshipViewModel
    
    let obraID: UUID

//    let onSave: (
//        _ nomeAutor: String?,
//        _ nomeObra: String?,
//        _ data: Date?,
//        _ local: String?,
//        _ imagem: Data?,
//        _ id: UUID
//    ) -> Void
    
    @State private var showConfirmationAlert: Bool = false
    
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

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    VStack(spacing: 0) {
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
                    
                    
                    ReflectionCard()
                        .padding(.horizontal)
                        .frame(minHeight: 520)
                    
                    HStack {
                        Spacer()
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
                        Spacer()
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
//                            ConfirmationAlert(
//                                title: "Atenção!",
//                                message: "Você possui alterações que não foram salvas.",
//                                question: "Deseja salvar as alterações?",
//                                confirmTitle: "Sim",
//                                cancelTitle: "Não",
//                                onConfirm: {},
//                                onCancel: {}
//                            )
                            
//
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
                                    save()
                                    showConfirmationAlert = false
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

    
//    private func save() {
//        onSave(
//            nomeAutor,
//            nome,
//            dataCriacao,
//            local,
//            imageData,
//            obraID
//        )
//        dismiss()
//    }
    
    
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

//#Preview {
//    NewArtView(
//        obraID: UUID()
//    ) { nomeAutor, nomeObra, data, local, imagem, id in
//        print("Salvar obra:")
//        print("ID:", id)
//        print("Nome:", nomeObra ?? "")
//        print("Autor:", nomeAutor ?? "")
//        print("Data:", data as Any)
//        print("Local:", local ?? "")
//        print("Imagem:", imagem != nil)
//    }
//}

#Preview {
    NewArtView(
        viewModel: CoreDataRelationshipViewModel(),
        obraID: UUID()
    )
}
