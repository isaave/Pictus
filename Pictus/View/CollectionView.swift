//
//  CollectionView.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 17/08/26.
//

import SwiftUI

enum SegmentedClasses: String, CaseIterable {
    case all = "Todos"
    case discoveries = "Descobertas"
    case personal = "Minhas"
}

struct MockObra {
    let name: String
    let author: String
    let date: String
    let category: SegmentedClasses
}

struct MockAlbum {
    let name: String
    let category: SegmentedClasses
}

struct CollectionView: View {
    @StateObject var viewModel: CoreDataRelationshipViewModel = CoreDataRelationshipViewModel()
    @State private var selectedMode: SegmentedClasses = .all
    @State private var searchText = ""

    @AppStorage("selectedIndex") private var selectedIndex: Int = 0
    @AppStorage("lastRollDate") private var lastRollDate: String = ""


    let albums = [
        MockAlbum(name: "Grafite", category: .discoveries),
        MockAlbum(name: "Realismo", category: .discoveries),
        MockAlbum(name: "Pintura", category: .discoveries),
        MockAlbum(name: "Barroco", category: .discoveries),
        MockAlbum(name: "Retrato", category: .discoveries),
        MockAlbum(name: "Meu Álbum", category: .personal)
    ]


    let obras = [
        MockObra(
            name: "Stańczyk",
            author: "Jan Matejko",
            date: "1862",
            category: .discoveries
        ),
        MockObra(
            name: "A Criação de Adão",
            author: "Michelangelo",
            date: "1511",
            category: .discoveries
        ),
        MockObra(
            name: "Fiel até a morte",
            author: "Edward Poynter",
            date: "1865",
            category: .discoveries
        ),
        MockObra(
            name: "O céu de Ataíde",
            author: "Mestre Ataíde",
            date: "1812",
            category: .discoveries
        ),
        MockObra(
            name: "Minha obra",
            author: "Minha coleção",
            date: "2026",
            category: .personal
        )
    ]

    let obrasColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    // MARK: - Obras filtradas

    var filteredObras: [MockObra] {
        var result: [MockObra]

        switch selectedMode {
        case .all:
            result = obras

        case .discoveries:
            result = obras.filter {
                $0.category == .discoveries
            }

        case .personal:
            result = obras.filter {
                $0.category == .personal
            }
        }

        // Busca por nome ou autor
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.author.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    // MARK: - Álbuns filtrados

    var filteredAlbums: [MockAlbum] {
        var result: [MockAlbum]

        switch selectedMode {
        case .all:
            result = albums

        case .discoveries:
            result = albums.filter {
                $0.category == .discoveries
            }

        case .personal:
            result = albums.filter {
                $0.category == .personal
            }
        }

        // Busca por nome
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {

                    // MARK: Título

                    HStack {
                        Text("Coleções")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)

                        Spacer()

                        BtnDescobertas()
                            .frame(width: 48, height: 48)
                    }
                    .padding(.horizontal)
                    .padding(.top, -40)


                    ArtSegmentedControl(
                        selection: $selectedMode
                    )
                    .padding(.horizontal)
           
                    NavigationLink(
                        destination: AlbunsView(searchText: "")
                    ) {
                        HStack {
                            Text("Álbuns")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.primary)

                            Spacer()
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                    }
                    .buttonStyle(.plain)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {

                            ForEach(
                                filteredAlbums,
                                id: \.name
                            ) { album in

                                AlbumCover(
                                    albumName: album.name,
                                    coverWidth: 130,
                                    coverHeight: 155
                                )
                            }
                        }
                        .padding(.horizontal, 14)
                    }
                    .padding(.top, -15)


                    Spacer()

                    HStack {
                        Text("Obras")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)

                        Spacer()

                        BtnAdd(
                            ButtonAction: {
                                print("Add")
                            },
                            icon: "plus"
                        )
                        .frame(width: 40, height: 40)
                    }
                    .padding(.horizontal)
                    .padding(.top, 30)

    
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
                        .padding(.vertical, 50)
                        .padding(.horizontal)
                    } else {

                        LazyVGrid(
                            columns: obrasColumns,
                            spacing: 12
                        ) {
                            ForEach(
                                filteredObras,
                                id: \.name
                            ) { obra in

                                ArtPreview(
                                    artName: obra.name,
                                    authorName: obra.author,
                                    dateArt: obra.date
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .searchable(
                text: $searchText,
                prompt: "Buscar obras e álbuns"
            )
            .onAppear {
                viewModel.seedObrasIfNeeded()
                verificarESortearObraDoDia()
            }
        }
    }


    private func verificarESortearObraDoDia() {
        guard !obras.isEmpty else {
            return
        }

        let hojeString = Date().formatted(
            date: .numeric,
            time: .omitted
        )

        if lastRollDate != hojeString ||
            !obras.indices.contains(selectedIndex) {

            executarSorteio()
            lastRollDate = hojeString
        }
    }

    private func sortearNovaObraManual() {
        guard !obras.isEmpty else {
            return
        }

        executarSorteio()

        lastRollDate = Date().formatted(
            date: .numeric,
            time: .omitted
        )
    }

    private func executarSorteio() {
        if obras.count > 1 {

            var novoIndice = selectedIndex

            while novoIndice == selectedIndex {
                novoIndice = Int.random(
                    in: 0..<obras.count
                )
            }

            selectedIndex = novoIndice

        } else {
            selectedIndex = 0
        }
    }
}


#Preview {
    CollectionView()
}

