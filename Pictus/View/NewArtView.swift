import SwiftUI
import PhotosUI
import UIKit

struct NewArtView: View {

    @Environment(\.dismiss) private var dismiss
    
    let onSave: (Obras) -> Void
    
    @State private var nome = ""
    @State private var nomeAutor = ""
    @State private var dataCriacao = Date()
    @State private var contexto = ""
    @State private var local = ""
    @State private var origem = ""

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var imagePreview: UIImage?

    @State private var isLoadingImage = false
    @State private var showImageError = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ZStack(alignment: .bottomLeading) {
                        if let imagePreview {
                            Image(uiImage: imagePreview)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 470)
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
                
                NewArtInfo()
                    .padding()
                
                
                ReflectionCard()
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .frame(minHeight: 520)
            }
            .background(Color(uiColor: .systemBackground))
            .ignoresSafeArea(edges: .top)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "folder.fill.badge.plus")
                            .fontWeight(.semibold)
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
        imageData != nil && !isLoadingImage
    }

    func save() {
        guard let imageData else {
            return
        }

        let novaObra = Obras(
            name: nome,
            nameAutor: nomeAutor,
            dataCriacao: dataCriacao,
            img: imageData,
            origem: origem,
            local: local,
            context: contexto
        )

        onSave(novaObra)
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
    NewArtView { obra in
        print("Obra pronta para salvar:", obra)
    }
}
