//
//  CollectionView.swift
//  Pictus
//

import SwiftUI
import CoreData

enum SegmentedClasses: String, CaseIterable {
    case all = "Todos"
    case discoveries = "Descobertas"
    case personal = "Minhas"
}

struct MockAlbum {
    let name: String
    let category: SegmentedClasses
}

struct CollectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var viewModel: CoreDataRelationshipViewModel = CoreDataRelationshipViewModel()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ArtEntity.dateArt, ascending: false)]
    )
    private var obrasEntities: FetchedResults<ArtEntity>
    
    @State private var selectedMode: SegmentedClasses = .all
    @State private var searchText = ""
    
    @AppStorage("selectedIndex") private var selectedIndex: Int = 0
    @AppStorage("hasDiscovered") private var hasDiscovered: Bool = false
    @AppStorage("lastRollDate") private var lastRollDate: String = ""
    
    @State private var mostrarToast = false
    @State private var irParaObraDoDia = false
    
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
                return nome.localizedCaseInsensitiveContains(searchText) ||
                       local.localizedCaseInsensitiveContains(searchText)
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
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Header
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
                        .padding(.top, -10)
                        
                        ArtSegmentedControl(selection: $selectedMode)
                            .padding(.horizontal)
                        
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
                        
                        ScrollView(.horizontal, showsIndicators: false) {
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
                        
                        HStack {
                            Text("Obras")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 2)
                            
                            Spacer()
                            
                            // Botão de adicionar nova obra
                            BtnAdd(
                                ButtonAction: {
                                    let idArteVazia = viewModel.addEmptyArt()
                                    idNovaArteParaEditar = idArteVazia
                                },
                                icon: "plus"
                            )
                            .frame(width: 40, height: 40)
                            .padding(.horizontal, 9)
                        }
                        .padding(.top, 10)
                        .padding(.horizontal)
                        
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
                                    NavigationLink(value: obra) {
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
                
                if mostrarToast {
                    Text("Você já abriu esta obra hoje, espere até amanhã!")
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
            .navigationDestination(for: ArtEntity.self) { obraClicada in
                WorkOfDayContentView(obraAtual: obraClicada, viewModel: viewModel)
            }
            .navigationDestination(isPresented: $irParaObraDoDia) {
                WorkOfDay()
            }
            .sheet(item: Binding(
                get: { idNovaArteParaEditar.map { IdentifiableUUID(id: $0) } },
                set: { idNovaArteParaEditar = $0?.id }
            )) { item in
                NewArtView(viewModel: viewModel, obraID: item.id)
            }
        }
        .searchable(text: $searchText, prompt: "Buscar obras e álbuns")
        .ignoresSafeArea()
    }
        
    private func tratarCliqueDescoberta() {
        let hojeString = Date().formatted(date: .numeric, time: .omitted)
        
        if lastRollDate == hojeString && hasDiscovered {
            exibirToast()
        } else {
            if lastRollDate != hojeString {
                sortearESalvarObraNoCoreData()
                lastRollDate = hojeString
            }
            irParaObraDoDia = true
        }
    }
    
    private func sortearESalvarObraNoCoreData() {
        guard !catalog.isEmpty else { return }
        
        let sorteado = Int.random(in: 0..<catalog.count)
        let obraObjeto = catalog[sorteado]
        
        viewModel.addArt(obra: obraObjeto)
        
        if !obrasEntities.isEmpty {
            selectedIndex = 0
        }
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

// Wrapper para tornar o UUID compatível com .sheet(item:)
struct IdentifiableUUID: Identifiable {
    let id: UUID
}

#Preview {
    CollectionView()
}
