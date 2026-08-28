//
//  NewArtView.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 19/08/26.
//

import SwiftUI
import PhotosUI
import UIKit
internal import SwiftData

// MARK: - NewArtView
struct NewArtView: View {
    @State private var upSheet = false
    @State private var selectedAlbums: Set<UUID> = []
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var viewModel: EntityRelationship
    @Query private var obrasEntities: [ArtEntity]
    
    var obraAtual: ArtEntity
    var albumPai: AlbumEntity?
    
    private var isEditing: Bool {
        obraAtual.modelContext != nil
    }
    
    @State private var nome: String
    @State private var nomeAutor: String
    @State private var dataCriacao: Date
    @State private var local: String
    @State private var imageData: Data?
    @State private var imagePreview: UIImage?
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isLoadingImage: Bool = false
    @State private var showImageError: Bool = false
    @State private var isFill: Bool = false
    @State private var showConfirmationAlert: Bool = false
    
    @State private var reflectionText: String = ""
    
    @State private var mostrarImagemZoom = false
    @State private var zoomScale: CGFloat = 1
    @State private var zoomOffset: CGSize = .zero
    @GestureState private var pinchMagnification: CGFloat = 1

    init(obraAtual: ArtEntity, albumPai: AlbumEntity? = nil, viewModel: EntityRelationship) {
        self.obraAtual = obraAtual
        self.albumPai = albumPai
        self.viewModel = viewModel
        
        _nome = State(initialValue: obraAtual.nameArt ?? "")
        _nomeAutor = State(initialValue: obraAtual.nameAuthor ?? "")
        _dataCriacao = State(initialValue: obraAtual.dateArt ?? Date())
        _local = State(initialValue: obraAtual.local ?? "")
        _imageData = State(initialValue: obraAtual.imgArt)
        
        if let data = obraAtual.imgArt, let uiImage = UIImage(data: data) {
            _imagePreview = State(initialValue: uiImage)
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    VStack(spacing: -450) {
                        imageSection(geometry: geometry)
                        imagePickerButton
                    }
                    .frame(height: 450)
                    .clipped()
                    
                    NewArtInfo(
                        nome: $nome,
                        nomeAutor: $nomeAutor,
                        dataCriacao: $dataCriacao,
                        local: $local
                    )
                    .padding()
                        ReflectionCard(
                        obraAtual: obraAtual,
                        viewModel: viewModel,
                        hasButton: false,
                        reflection: $reflectionText
                    )
                    .padding()
                    
                    registrarObraButton
                        .padding()
                }
                .background(Color(uiColor: .systemBackground))
                .ignoresSafeArea(edges: .top)
                .scrollDismissesKeyboard(.interactively)
                .interactiveDismissDisabled()
                
                .onAppear(perform: setupInitialData)
                .onChange(of: nome) { _, newValue in
                    isFill = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                }
                .onChange(of: selectedPhoto) { _, newValue in
                    guard let newValue else { return }
                    Task { await loadImage(from: newValue) }
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
                        } label: {
                            Image(systemName: "chevron.backward")
                                .fontWeight(.semibold)
                        }
                    }
                }
                .sheet(isPresented: $upSheet) {
                    AlbumSelector(
                        selectedAlbums: $selectedAlbums,
                        onConfirm: confirmarAlbuns
                    )
                }
                .overlay {
                    confirmationOverlay
                }
                .alert("Não foi possível carregar a imagem", isPresented: $showImageError) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Selecione outra imagem e tente novamente.")
                }
                .fullScreenCover(isPresented: $mostrarImagemZoom) {
                                   ZStack {
                                       Color.black.ignoresSafeArea()

                                       if let imagePreview {
                                           Image(uiImage: imagePreview)
                                               .resizable()
                                               .scaledToFit()
                                               .scaleEffect(zoomScale * pinchMagnification)
                                               .offset(zoomOffset)
                                               .gesture(
                                                   MagnificationGesture()
                                                       .updating($pinchMagnification) { value, state, _ in
                                                           state = value
                                                       }
                                                       .onEnded { value in
                                                           zoomScale = max(1, min(zoomScale * value, 5))
                                                       }
                                               )
                                               .simultaneousGesture(
                                                   DragGesture()
                                                       .onChanged { value in
                                                           if zoomScale > 1 { zoomOffset = value.translation }
                                                       }
                                                       .onEnded { _ in
                                                           if zoomScale <= 1 { zoomOffset = .zero }
                                                       }
                                               )
                                               .onTapGesture(count: 2) {
                                                   withAnimation(.spring()) {
                                                       if zoomScale > 1 {
                                                           zoomScale = 1
                                                           zoomOffset = .zero
                                                       } else {
                                                           zoomScale = 2.5
                                                       }
                                                   }
                                               }
                                       }

                                       VStack {
                                           HStack {
                                               Spacer()
                                               Button {
                                                   zoomScale = 1
                                                   zoomOffset = .zero
                                                   mostrarImagemZoom = false
                                               } label: {
                                                   Image(systemName: "xmark.circle.fill")
                                                       .font(.title)
                                                       .foregroundStyle(.white, .black.opacity(0.5))
                                               }
                                               .padding()
                                           }
                                           Spacer()
                                       }
                                   }
                               }
                           }
                       }
                   }
            }
// MARK: - View Builders e UI Auxiliar
private extension NewArtView {
    
    @ViewBuilder
    func imageSection(geometry: GeometryProxy) -> some View {
        ZStack(alignment: .bottomLeading) {
            if let imagePreview {
                Image(uiImage: imagePreview)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: geometry.size.width)
                    .frame(height: 400)
                    .clipped()
                    .overlay(alignment: .bottomTrailing) {
                                            Button {
                                                mostrarImagemZoom = true
                                            } label: {
                                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundStyle(.white)
                                            }
                                            .padding(16)
                                        }
            } else {
                ZStack {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        Image(systemName: "photo")
                            .font(.title3)
                            .foregroundStyle(.gray)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.black.opacity(0.3))
                    }
                    .accessibilityLabel(imageData == nil ? "Selecionar imagem" : "Alterar imagem")
                }
            }
        }
    }
    
    var registrarObraButton: some View {
        HStack(alignment: .center) {
            Button(action: save) {
                Text(isEditing ? "Confirmar Edição" : "Registrar Obra")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(canSave ? Color.white : Color.gray.opacity(0.8))
                    .padding(.horizontal, 30)
                    .padding(.vertical)
                    .background {
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .fill(canSave ? Color.accentColor : .clear)
                            .glassEffect(
                                .regular.interactive(),
                                in: .rect(cornerRadius: 32, style: .continuous)
                            )
                            .opacity(isFill ? 1.0 : 0.6)
                    }
            }
            .disabled(!canSave || !isFill)
        }
    }
    
    @ViewBuilder
    var confirmationOverlay: some View {
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
    
    var imagePickerButton: some View {
        VStack {
            HStack {
                Spacer()
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    Image(systemName: "photo")
                        .foregroundColor(.clear)
                        .frame(maxWidth: .infinity, maxHeight: 250)
                }
            }
            Spacer()
        }
        .padding(.top, 105)
        .padding(.horizontal, 16)
    }
}

// MARK: - Funções Lógicas
private extension NewArtView {
    var canSave: Bool { imageData != nil && !isLoadingImage && isFill }
    var canSaveBack: Bool { imageData != nil && !isLoadingImage }
    
    func setupInitialData() {
        if !isEditing {
            obraAtual.nameArt = nome
            obraAtual.nameAuthor = nomeAutor
            obraAtual.imgArt = imageData
            obraAtual.local = local
            obraAtual.dateArt = dataCriacao
        }
        isFill = !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func save() {
        obraAtual.nameArt = nome
        obraAtual.nameAuthor = nomeAutor
        obraAtual.dateArt = dataCriacao
        obraAtual.local = local
        obraAtual.imgArt = imageData
        obraAtual.origin = "Minhas"
        
        if let albumPai = albumPai {
            if !albumPai.art.contains(where: { $0.id == obraAtual.id }) {
                albumPai.art.append(obraAtual)
            }
        }
        
        if !isEditing {
            context.insert(obraAtual)
        }
        
        // 3. Usa o texto preenchido na view principal (Binding passado do ReflectionCard)
        let textoFinalReflexao = reflectionText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !textoFinalReflexao.isEmpty {
            viewModel.addReflection(text: textoFinalReflexao, to: obraAtual)
        }
        
        try? context.save()
        
        dismiss()
    }
    
    func discart() {
        if !isEditing {
            context.delete(obraAtual)
        }
        dismiss()
    }
    
    func confirmarAlbuns() {
        let descriptor = FetchDescriptor<AlbumEntity>()
        if let todosAlbuns = try? context.fetch(descriptor) {
            let albunsSelecionados = todosAlbuns.filter { album in
                return selectedAlbums.contains(album.idAlbum)
            }
            
            for album in albunsSelecionados {
                if !(album.art.contains(where: { $0.id == obraAtual.id })) {
                    album.art.append(obraAtual)
                }
            }
            try? context.save()
        }
        upSheet = false
    }
    
    @MainActor
    func loadImage(from item: PhotosPickerItem) async {
        isLoadingImage = true
        defer { isLoadingImage = false }
        
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let uiImage = UIImage(data: data) else {
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


