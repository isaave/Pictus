//
//  CollectionView.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 17/08/26.
//

import SwiftUI
import CoreData

enum SegmentedClasses: String, CaseIterable {
    case all = "Todos"
    case discoveries = "Descobertas"
    case personal = "Minhas"
}

struct CollectionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var viewModel: CoreDataRelationshipViewModel
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ArtEntity.dateArt, ascending: false)]
    )
    private var obrasEntities: FetchedResults<ArtEntity>
    
    @State private var selectedMode: SegmentedClasses = .all
    @State private var searchText = ""
    @AppStorage("selectedIndex") private var selectedIndex: Int = 0
    @AppStorage("hasDiscovered") private var hasDiscovered: Bool = false
    @AppStorage("lastRollDate") private var lastRollDate: String = ""
    @AppStorage("idObraDoDia") private var idObraDoDia: String = ""
    @State private var mostrarToast = false
    @State private var toastMessage = "Você já abriu esta obra hoje, espere até amanhã!"
    @State private var irParaObraDoDia = false

    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var mostrarOnboarding: Bool = false
    
    @State private var idNovaArteParaEditar: UUID? = nil
    
    // Controla se exibe a LoadingView como tela cheia
    @State private var isDiscovering: Bool = false
    
    let obrasColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]


    var filteredObras: [ArtEntity] {
        var result = obrasEntities.filter { obra in
            let temNome = (obra.nameArt != nil && !obra.nameArt!.isEmpty)
            let temImagem = obra.imgArt != nil
            return temNome || temImagem
        }

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
                let autor = obra.nameAuthor ?? ""
                let local = obra.local ?? ""
                return nome.localizedCaseInsensitiveContains(searchText) ||
                       autor.localizedCaseInsensitiveContains(searchText) ||
                       local.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }


    var body: some View {
        NavigationStack {
            // Se estiver descobrindo, exibe a LoadingView como uma View de tela inteira
            if isDiscovering {
                LoadingView()
            } else {
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
                                .disabled(isDiscovering)
                            }
                            .padding(.horizontal)

                            // Segmented Control
                            ArtSegmentedControl(selection: $selectedMode)
                                .padding(.horizontal)

                            // Álbuns
                            NavigationLink(destination: AllAlbunsView().environmentObject(viewModel)) {
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

                            AlbumHorizontalView(Vm: viewModel)

                            // Obras
                            HStack {
                                Text("Obras")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primary)
                                Spacer()
                                
                                BtnAdd(
                                    ButtonAction: {
                                        tratarCriacaoObraManual()
                                    },
                                    icon: "plus"
                                )
                                .frame(width: 40, height: 40)
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)

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
                     
                    // Toast Feedback
                    if mostrarToast {
                        Text(toastMessage)
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
                .searchable(text: $searchText, prompt: "Buscar obras e álbuns")
                .navigationDestination(for: NSManagedObjectID.self) { objectID in
                    if let obraClicada = viewContext.object(with: objectID) as? ArtEntity {
                        WorkOfDayContentView(obraAtual: obraClicada, viewModel: viewModel)
                    }
                }
                .navigationDestination(for: UUID.self) { idAlbum in
                    AlbunsView(idAlbum: idAlbum)
                        .environmentObject(viewModel)
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
                .onAppear {
                    verificarESortearObraDoDia()
                }
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
                            .font(.system(size: 17))
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
                            .font(.system(size: 17))
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
    
    // MARK: - Métodos Auxiliares

    private func tratarCliqueDescoberta() {
        guard !isDiscovering else { return }
         
        let catalogo = ObrasObjects().objects
        
        // Normaliza os nomes já cadastrados no banco (ignorando acentos, maiúsculas e espaços)
        let nomesJaCadastrados = Set(obrasEntities.compactMap { obraEntity in
            obraEntity.nameArt?
                .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        })
        
        // Filtra o catálogo comparando com os nomes rigorosamente normalizados
        let catalogoDisponivel = catalogo.filter { obraCatalogo in
            let nomeNormalizado = obraCatalogo.name
                .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return !nomesJaCadastrados.contains(nomeNormalizado)
        }

        // Validação de limite caso todas as obras tenham sido descobertas
        if catalogoDisponivel.isEmpty {
            toastMessage = "Você já descobriu todas as obras disponíveis!"
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                mostrarToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    mostrarToast = false
                }
            }
            return
        }

        let hojeString = Date().formatted(date: .numeric, time: .omitted)

        if lastRollDate == hojeString && hasDiscovered {
            toastMessage = "Você já abriu esta obra hoje, espere até amanhã!"
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                mostrarToast = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    mostrarToast = false
                }
            }
        } else {
            // Exibe a LoadingView como tela cheia
            withAnimation {
                isDiscovering = true
            }
             
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let obraSorteada = catalogoDisponivel.randomElement() {
                    let idObraSorteada = viewModel.addArt(obra: obraSorteada)
                    idObraDoDia = idObraSorteada.uuidString
                }
                lastRollDate = hojeString
                hasDiscovered = true
                 
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation {
                        isDiscovering = false
                    }
                    irParaObraDoDia = true
                }
            }
        }
    }
     
    private func tratarCriacaoObraManual() {
        let idArteVazia = viewModel.addEmptyArt()
        idNovaArteParaEditar = idArteVazia
         
        let hojeString = Date().formatted(date: .numeric, time: .omitted)
        lastRollDate = hojeString
        hasDiscovered = true
    }

    private func verificarESortearObraDoDia() {
        guard !obrasEntities.isEmpty else { return }
        let hojeString = Date().formatted(date: .numeric, time: .omitted)

        if lastRollDate != hojeString {
            hasDiscovered = false
        }

        if lastRollDate != hojeString || !obrasEntities.indices.contains(selectedIndex) {
            executarSorteio()
        }
    }

    private func sortearNovaObraManual() {
        guard !obrasEntities.isEmpty else { return }
        executarSorteio()
        lastRollDate = Date().formatted(date: .numeric, time: .omitted)
    }

    private func executarSorteio() {
        let obrasCount = obrasEntities.count
        if obrasCount > 1 {
            var novoIndice = selectedIndex
            while novoIndice == selectedIndex {
                novoIndice = Int.random(in: 0..<obrasCount)
            }
            selectedIndex = novoIndice
        } else {
            selectedIndex = 0
        }
    }
}

#Preview {
    CollectionView()
        .environmentObject(CoreDataRelationshipViewModel())
}
