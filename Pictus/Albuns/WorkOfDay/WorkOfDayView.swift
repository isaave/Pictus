//
//  WorkOfDay.swift
//  Pictus
//
//  Created by Andre on 18/08/26.
//  Refactored for SwiftData on 25/08/26.
//

import SwiftUI
internal import SwiftData

struct WorkOfDay: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: EntityRelationship
    @Query(sort: \ArtEntity.dateArt, order: .reverse)
    var obras: [ArtEntity]
    
    @AppStorage("idObraDoDia") private var idObraDoDia: String = ""
    @AppStorage("lastRollDate") private var lastRollDate : Date = Date()
    private var obraSelecionada: ArtEntity? {
        if let uuid = UUID(uuidString: idObraDoDia),
           let obraDoDia = obras.first(where: { $0.id == uuid }) {
            return obraDoDia
        }
        return obras.first(where: { $0.origin == "Descobertas" }) ?? obras.first
    }
    
    @Query(sort:\AlbumEntity.idAlbum,order: .reverse)
    var albums: [AlbumEntity]
    
 
    var body: some View {
        Group {
            if obras.isEmpty {
                SwiftUI.ContentUnavailableView(
                    "Nenhuma obra encontrada",
                    systemImage: "photo.on.rectangle.angled"
                )
            } else if let obra = obraSelecionada {
                WorkOfDayContentView(obra: obra, viewModel: viewModel)
            } else {
                ProgressView("Carregando obra...")
            }
        }
        .navigationTitle("Obra do dia")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    print("Add")
                } label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

struct WorkOfDayContentView: View {
    @State private var upSheet = false
        @State private var selectedAlbums: Set<UUID> = []
        
        @Environment(\.colorScheme) var colorScheme
        @Environment(\.modelContext) private var modelContext
        
        var obraAtual: ArtEntity
        @ObservedObject var viewModel: EntityRelationship
        
        @State private var alreadyOpenedAlert: Bool = false
        @State private var showAlert = false
        
        @Query private var reflexoesSalvas: [ReflectionEntity]
    
    @State private var mostrarImagemZoom = false
    @State private var zoomScale: CGFloat = 1
    @State private var zoomOffset: CGSize = .zero
    @GestureState private var pinchMagnification: CGFloat = 1
    
    init(obra: ArtEntity, viewModel: EntityRelationship) {
        self.obraAtual = obra
        self._viewModel = ObservedObject(wrappedValue: viewModel)
        
        let obraID = obra.id
        _reflexoesSalvas = Query(
            filter: #Predicate<ReflectionEntity> { reflexao in
                reflexao.art?.id == obraID
            },
            sort: [SortDescriptor<ReflectionEntity>(\.dateReflx, order: .reverse)]
        )
    }
    
    private var isContextReleased: Bool {
        obraAtual.ctxReleased ?? false
    }
    
    private var uiImageAtual: UIImage {
        UIImage(data: obraAtual.imgArt ?? Data()) ?? UIImage(systemName: "photo")!
    }
   
    var body: some View {
        let autor = obraAtual.nameAuthor ?? "Desconhecido"
        let local = obraAtual.local ?? ""
        let ano = obraAtual.dateArt?.formatted(.dateTime.year()) ?? ""
         
        ScrollView {
            VStack(spacing: 16) {
                Image(uiImage: uiImageAtual)
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        LinearGradient(
                            colors: [
                                .clear,
                                .black.opacity(0.7)
                            ],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .allowsHitTesting(false)
                    }
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading) {
                            Text(obraAtual.nameArt ?? "Desconhecido")
                                .foregroundStyle(.white)
                                .font(.title.bold())
                            Text("\(autor) - \(local) - \(ano)")
                                .font(.body)
                                .foregroundStyle(.white)
                        }
                        .padding(16)
                    }
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
                 
                VStack(alignment: .leading, spacing: 16) {
                    if obraAtual.origin == "Descobertas" {
                        Group {
                            Text("Sobre a obra")
                                .font(.title2.bold())
                           
                            VStack(alignment: .leading, spacing: 8) {
                                Text(obraAtual.ctxArt ?? "Conteúdo da arte")
                                    .font(.body)
                                    .lineLimit(isContextReleased ? nil : 4)
                                    .overlay(alignment: .bottom) {
                                        if !isContextReleased {
                                            LinearGradient(
                                                colors: [
                                                    .clear,
                                                    colorScheme == .dark ? Color.black : Color.white
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                            .frame(height: 40)
                                            .allowsHitTesting(false)
                                        }
                                    }
                            }
                        }
                        
                        HStack {
                            Spacer()
                            Button {
                                if !alreadyOpenedAlert {
                                    showAlert.toggle()
                                } else {
                                    alternarLiberacaoContexto()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: isContextReleased ? "lock.open.fill" : "lock.fill")
                                        .contentTransition(.symbolEffect(.replace))
                                   
                                    Text(isContextReleased ? "Ver menos" : "Ver mais")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                     
                    ReflectionCard(obraAtual: obraAtual, viewModel: viewModel, hasButton: true)
                     
                    if !reflexoesSalvas.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Minhas Reflexões")
                                .font(.title3.bold())
                           
                            ForEach(reflexoesSalvas, id: \.self) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.textReflx ?? "")
                                        .font(.body)
                                   
                                    if let data = item.dateReflx {
                                        Text(data.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.1))
                                )
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(16)
            }
            .navigationTitle("\(obraAtual.nameArt ?? "Desconhecido")")
            .ignoresSafeArea(edges: .top)
            .scrollDismissesKeyboard(.interactively)
            .overlay(alignment: .center){
                Group {
                    if showAlert {
                        ZStack {
                            Color.black.opacity(0.4)
                                .ignoresSafeArea()
                                .onTapGesture { showAlert = false }
                           
                            ConfirmationAlert(
                                title: "Atenção!",
                                message: "Acessar o contexto desta obra sem análise prévia pode impactar sua interpretação.",
                                question: "Deseja prosseguir?",
                                confirmTitle: "Sim",
                                cancelTitle: "Não",
                                onConfirm: {
                                    alternarLiberacaoContexto()
                                    showAlert = false
                                    alreadyOpenedAlert = true
                                },
                                onCancel: {
                                    showAlert = false
                                }
                            )
                        }
                    }
                }
            }
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
                        .sheet(isPresented: $upSheet) {
                            AlbumSelector(
                                selectedAlbums: $selectedAlbums,
                                onConfirm: {
                                    let descriptor = FetchDescriptor<AlbumEntity>()
                                    if let todosAlbuns = try? modelContext.fetch(descriptor) {
                                        
                                        let albunsSelecionados = todosAlbuns.filter { album in
                                            return selectedAlbums.contains(album.idAlbum)
                                        }
                                        
                                        for album in albunsSelecionados {
                                            
                                            if !album.art.contains(where: { $0.id == obraAtual.id }) {
                                                album.art.append(obraAtual)
                                            }
                                        }
                                        
                                        try? modelContext.save()
                                    }
                                    upSheet = false
                                }
                            )
                        }
                    }
                }
                .fullScreenCover(isPresented: $mostrarImagemZoom) {
                    ZStack {
                        Color.black.ignoresSafeArea()

                        Image(uiImage: uiImageAtual)
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
     
    private func alternarLiberacaoContexto() {
        obraAtual.ctxReleased = !isContextReleased
    }
}
