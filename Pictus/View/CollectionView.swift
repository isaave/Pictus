//
//  CollectionView.swift
//  Pictus
//

import SwiftUI
import CoreData

// MARK: - Modelos de Apoio e Filtro

enum SegmentedClasses: String, CaseIterable {
    case all = "Todos"
    case discoveries = "Descobertas"
    case personal = "Minhas"
}

struct MockAlbum {
    let name: String
    let category: SegmentedClasses
}

// MARK: - View Principal

struct CollectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var viewModel: CoreDataRelationshipViewModel = CoreDataRelationshipViewModel()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ArtEntity.dateArt, ascending: false)]
    )
    private var obrasEntities: FetchedResults<ArtEntity>
    
    @State private var selectedMode: SegmentedClasses = .all
    @State private var searchText = ""
    
    @AppStorage("idObraDoDia") private var idObraDoDia: String = ""
    @AppStorage("hasDiscovered") private var hasDiscovered: Bool = false
    @AppStorage("lastRollDate") private var lastRollDate: String = ""
    @AppStorage("obrasSorteadasHistorico") private var obrasSorteadasHistorico: String = ""
    
    // MARK: - Controle de Onboarding e Carregamento
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var mostrarOnboarding: Bool = false
    @State private var isLoading: Bool = false
    @State private var mostrarToast: Bool = false
    @State private var irParaObraDoDia: Bool = false
    @State private var idNovaArteParaEditar: UUID? = nil
    
    let catalog = ObrasObjects().objects
    
    let albums = [
        MockAlbum(name: "Grafite", category: .discoveries),
        MockAlbum(name: "Realismo", category: .discoveries),
        MockAlbum(name: "Pintura", category: .discoveries),
        MockAlbum(name: "Barroco", category: .discoveries),
        MockAlbum(name: "Retrato", category: .discoveries),
        MockAlbum(name: "Meu Álbum", category: .personal)
    ]
    
    let obrasColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // MARK: - Filtros de Busca
    
    var filteredObras: [ArtEntity] {
        var result = Array(obrasEntities)
        
        switch selectedMode {
        case .all:
            break
        case .discoveries:
            result = result.filter { $0.origin == "Descobertas" }
        case .personal:
            result = result.filter { $0.origin == "Minhas" }
        }
        
        if !searchText.isEmpty {
            result = result.filter { obra in
                let nome = obra.nameArt ?? ""
                let local = obra.local ?? ""
                let autor = obra.nameAuthor ?? ""
                return nome.localizedCaseInsensitiveContains(searchText) ||
                       local.localizedCaseInsensitiveContains(searchText) ||
                       autor.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    var filteredAlbums: [MockAlbum] {
        var result = albums
        
        switch selectedMode {
        case .all:
            break
        case .discoveries:
            result = albums.filter { $0.category == .discoveries }
        case .personal:
            result = albums.filter { $0.category == .personal }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    // MARK: - Interface Visual
    
    var body: some View {
        Group {
            // Troca direta de tela: exibe a LoadingView enquanto carrega
            if isLoading {
                LoadingView()
                    .transition(.opacity)
            } else {
                NavigationStack {
                    ZStack(alignment: .bottom) {
                        ScrollView {
                            VStack(spacing: 20) {
                                
                                // Header Principal
                                HStack {
                                    Text("Coleções")
                                        .font(.largeTitle)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                    
                                    BtnDescobertas {
                                        tratarCliqueDescoberta()
                                    }
                                    .frame(width: 48, height: 48)
                                }
                                .padding(.horizontal)
                                
                                // Control de Categorias
                                ArtSegmentedControl(selection: $selectedMode)
                                    .padding(.horizontal)
                                
                                // Seção Álbuns
                                NavigationLink(destination: AlbunsView(searchText: "")) {
                                    HStack {
                                        Text("Álbuns")
                                            .font(.system(size: 28, weight: .bold))
                                            .foregroundColor(.primary)
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                                .buttonStyle(.plain)
                                
                                ScrollView(Axis.Set.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(filteredAlbums, id: \.name) { album in
                                            AlbumCover(
                                                albumName: album.name,
                                                coverWidth: 130,
                                                coverHeight: 155
                                            )
                                        }
                                    }
                                    .padding(.horizontal, 15)
                                }
                                
                                // Seção Obras + Botão de Adicionar
                                HStack {
                                    Text("Obras")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.primary)
                                        .padding(.horizontal, 2)
                                    
                                    Spacer()
                                    
                                    BtnAdd(
                                        ButtonAction: {
                                            tratarCriacaoObraManual()
                                        },
                                        icon: "plus"
                                    )
                                    .frame(width: 40, height: 40)
                                    .padding(.horizontal, 9)
                                }
                                .padding(.top, 10)
                                .padding(.horizontal)
                                
                                // Lista de Obras em Grade
                                if filteredObras.isEmpty {
                                    VStack(spacing: 10) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 40))
                                            .foregroundStyle(.secondary)
                                        
                                        Text("Nenhuma obra encontrada")
                                            .font(.headline)
                                        
                                        Text(
                                            selectedMode == .personal
                                            ? "Você ainda não possui obras na sua coleção."
                                            : "Não encontramos obras para esse filtro."
                                        )
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 40)
                                    .padding(.horizontal)
                                } else {
                                    LazyVGrid(columns: obrasColumns, spacing: 12) {
                                        ForEach(filteredObras, id: \.objectID) { obra in
                                            NavigationLink(value: obra.objectID) {
                                                ArtPreview(
                                                    artName: obra.nameArt ?? "Sem Título",
                                                    authorName: obra.nameAuthor ?? obra.local ?? "Desconhecido",
                                                    dateArt: obra.dateArt?.formatted(date: .numeric, time: .omitted) ?? "",
                                                    imgData: obra.imgArt
                                                )
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.bottom, 30)
                        }
                        
                        // Mensagem Flutuante de Bloqueio
                        if mostrarToast {
                            Text("Você já abriu ou adicionou uma obra hoje, espere até amanhã!")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 18)
                                .background(
                                    Capsule()
                                        .fill(Color.black.opacity(0.85))
                                )
                                .padding(.bottom, 25)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .navigationDestination(for: NSManagedObjectID.self) { objectID in
                        if let obraClicada = viewContext.object(with: objectID) as? ArtEntity {
                            WorkOfDayContentView(obraAtual: obraClicada, viewModel: viewModel)
                        }
                    }
                    .navigationDestination(isPresented: $irParaObraDoDia) {
                        WorkOfDay()
                    }
                    .sheet(isPresented: Binding(
                        get: { idNovaArteParaEditar != nil },
                        set: { seAberto in
                            if !seAberto { idNovaArteParaEditar = nil }
                        }
                    )) {
                        if let uuid = idNovaArteParaEditar {
                            NewArtView(viewModel: viewModel, obraID: uuid)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Buscar obras e álbuns")
            }
        }
        .onAppear {
            if !hasSeenOnboarding {
                mostrarOnboarding = true
            }
        }
        .sheet(isPresented: $mostrarOnboarding) {
            onboardingView
        }
    }
        
    // MARK: - View de Onboarding
    
    private var onboardingView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Spacer()
                Image("Icone")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 124, height: 124)
                    .cornerRadius(22)
                    .shadow(color: .black.opacity(0.10), radius: 15, x: 5, y: 10)
                Spacer()
            }
            .padding(.top, 55)
            .padding(.bottom, 24)
            
            VStack(alignment: .leading, spacing: 14) {
                Text("Conheça o")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(Color("AccentColor"))
                
                Text("Pictus")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 54)
            .padding(.bottom, 32)
            
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .top, spacing: 1) {
                    Image(systemName: "lightbulb.max.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.accentColor)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Reflita sobre arte")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        Text("Forme sua própria interpretação sobre as obras diárias e seus próprios registros.")
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 30)
                }
                
                HStack(alignment: .top, spacing: 1) {
                    Image(systemName: "photo.badge.magnifyingglass")
                        .font(.system(size: 24))
                        .foregroundColor(.accentColor)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Descubra todos os dias")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        Text("Receba uma nova obra diariamente e conheça diferentes formas de enxergar a arte.")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 30)
                }
                
                HStack(alignment: .top, spacing: 1) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.accentColor)
                        .frame(width: 32)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Encontre arte ao seu redor")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.primary)
                        Text("Fotografe aquilo que você considera arte e reflita sobre isso.")
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 30)
                }
            }
            .padding(.horizontal, 52)
            
            Spacer()
            
            Button {
                hasSeenOnboarding = true
                mostrarOnboarding = false
            } label: {
                Text("Continuar")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.accentColor)
                    .clipShape(.rect(cornerRadius: 55, style: .continuous))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }

    // MARK: - Regras de Negócio
    
    private func tratarCliqueDescoberta() {
        let hojeString = Date().formatted(date: .numeric, time: .omitted)
        
        if lastRollDate == hojeString && hasDiscovered {
            exibirToast()
        } else {
            withAnimation(.easeInOut(duration: 0.25)) {
                isLoading = true
            }
            
            Task {
                if lastRollDate != hojeString {
                    await sortearESalvarObraNoCoreDataAsync()
                    lastRollDate = hojeString
                }
                
                try? await Task.sleep(nanoseconds: 500_000_000)
                
                withAnimation(.easeInOut(duration: 0.25)) {
                    isLoading = false
                    irParaObraDoDia = true
                }
            }
        }
    }
    
    @MainActor
    private func sortearESalvarObraNoCoreDataAsync() async {
        let historico = obrasSorteadasHistorico
            .components(separatedBy: ",")
            .filter { !$0.isEmpty }
        
        var naoVistas = catalog.filter { !historico.contains($0.name) }
        
        if naoVistas.isEmpty {
            obrasSorteadasHistorico = ""
            naoVistas = catalog
        }
        
        guard var obraSorteada = naoVistas.randomElement() else { return }
        obraSorteada.origem = "Descobertas"
        
        viewModel.addArt(obra: obraSorteada)
        
        if let obraCriada = viewModel.obrasEntities.first(where: { $0.nameArt == obraSorteada.name }) {
            idObraDoDia = obraCriada.id?.uuidString ?? ""
        }
        
        var novoHistorico = historico
        novoHistorico.append(obraSorteada.name)
        obrasSorteadasHistorico = novoHistorico.joined(separator: ",")
        
        hasDiscovered = true
    }
    
    private func tratarCriacaoObraManual() {
        let idArteVazia = viewModel.addEmptyArt()
        idNovaArteParaEditar = idArteVazia
        
        let hojeString = Date().formatted(date: .numeric, time: .omitted)
        lastRollDate = hojeString
        hasDiscovered = true
    }
    
    private func exibirToast() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            mostrarToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                mostrarToast = false
            }
        }
    }
}

#Preview {
    CollectionView()
}
