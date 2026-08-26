//
//  CollectionView.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 17/08/26.
//

import SwiftUI
internal import SwiftData

enum SegmentedClasses: String, CaseIterable {
    case all = "Todos"
    case discoveries = "Descobertas"
    case personal = "Minhas"
}

struct CollectionView: View {
    @Environment(\.modelContext) private var context
    @State var object = ObrasObjects()
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
    @State private var isDiscovering: Bool = false
    @State private var abrirNovaObra : ArtEntity?
    @Query var obrasEntities: [ArtEntity]
    @EnvironmentObject var viewModel: EntityRelationship
    
    let obrasColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var obraDoDia: ArtEntity? {
        guard let uuid = UUID(uuidString: idObraDoDia) else { return nil }
        return obrasEntities.first(where: { $0.id == uuid })
    }

    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private var jaDescobriuHoje: Bool {
        !lastRollDate.isEmpty && lastRollDate == todayString
    }

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
            if isDiscovering {
                LoadingView()
            } else {
                ZStack(alignment: .bottom) {
                    ScrollView {
                        VStack(spacing: 20) {
                            HStack {
                                Text("Coleções")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Spacer()

                                BtnDescobertas {
                                    verificarDiaDescoberta()
                                }
                                .frame(width: 48, height: 48)
                                .disabled(isDiscovering)
                            }
                            .padding(.horizontal)

                            ArtSegmentedControl(selection: $selectedMode)
                                .padding(.horizontal)

                            NavigationLink(destination: AllAlbunsView()) {
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

                            AlbumHorizontalView(viewModel: _viewModel)

                            HStack {
                                Text("Obras")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primary)
                                Spacer()

                                BtnAdd(
                                    ButtonAction: {
                                        abrirNovaObra = ArtEntity()
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
                                    ForEach(filteredObras, id: \.id) { obra in
                                        NavigationLink(destination: WorkOfDayContentView(obra: obra, viewModel: viewModel)) {
                                            if obra.origin == "Minhas" {
                                                ArtPreview(
                                                    artName: obra.nameArt ?? "Sem Título",
                                                    authorName: obra.nameAuthor ?? obra.local ?? "Desconhecido",
                                                    dateArt: obra.dateArt?.formatted(date: .numeric, time: .omitted) ?? "",
                                                    imgData: obra.imgArt
                                                )
                                                .contextMenu {
                                                    Button {
                                                        abrirNovaObra = obra
                                                    } label: {
                                                        Label("Editar Obra", systemImage: "pencil")
                                                    }
                                                    Button(role: .destructive) {
                                                        context.delete(obra)
                                                    } label: {
                                                        Label("Apagar Obra", systemImage: "trash")
                                                    }
                                                }
                                            } else {
                                                ArtPreview(
                                                    artName: obra.nameArt ?? "Sem Título",
                                                    authorName: obra.nameAuthor ?? obra.local ?? "Desconhecido",
                                                    dateArt: obra.dateArt?.formatted(date: .numeric, time: .omitted) ?? "",
                                                    imgData: obra.imgArt
                                                )
                                            }
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
                .navigationDestination(for: UUID.self) { idAlbum in
                    AlbunsView(idAlbum: idAlbum)
                }
                .navigationDestination(isPresented: $irParaObraDoDia) {
                    WorkOfDay()
                }
                .sheet(item: $abrirNovaObra) { obra in
                    NewArtView(obraAtual: obra)
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

    
    @discardableResult
    func verificarDiaDescoberta() -> Bool {
        if jaDescobriuHoje {
            exibirToast("Você já descobriu uma obra hoje, volte amanhã!")
            return false
        }
        
        guard let novaObra = object.rollObra() else {
            exibirToast("Você já descobriu todas as obras disponíveis!")
            return false
        }
        
        context.insert(novaObra)
        idObraDoDia = novaObra.id.uuidString
        lastRollDate = todayString 
        irParaObraDoDia = true
        
        return true
    }

    private func exibirToast(_ mensagem: String) {
        toastMessage = mensagem
        mostrarToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            mostrarToast = false
        }
    }
}
