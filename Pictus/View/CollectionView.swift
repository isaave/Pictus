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
}

struct CollectionView: View {
    @StateObject var viewModel: CoreDataRelationshipViewModel = CoreDataRelationshipViewModel()
    @State private var selectedMode: SegmentedClasses = .all
    @State private var searchText = ""
    
    @AppStorage("selectedIndex") private var selectedIndex: Int = 0
    @AppStorage("lastRollDate") private var lastRollDate: String = ""

    let albumNames = ["Grafite", "Realismo", "Pintura", "Barroco", "Retrato"]

    let obras = [
        MockObra(name: "Stańczyk", author: "Jan Matejko", date: "1862"),
        MockObra(name: "A Criação de Adão", author: "Michelangelo", date: "1511"),
        MockObra(name: "Fiel até a morte", author: "Edward Poynter", date: "1865"),
        MockObra(name: "O céu de Ataíde", author: "Mestre Ataíde", date: "1812")
    ]

    let obrasColumns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {

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

                    ArtSegmentedControl(
                        selection: $selectedMode
                    )
                    .padding(.horizontal)

                    switch selectedMode {
                    case .all:
                        HStack {
                            Text("Exibindo: Todos")
                        }
                    case .discoveries:
                        HStack {
                            Text("Exibindo: Descobertas")
                        }
                    case .personal:
                        HStack {
                            Text("Exibindo Minhas")
                        }
                    }

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
                            ForEach(albumNames, id: \.self) { name in
                                AlbumCover(albumName: name, coverWidth: 130, coverHeight: 155)
                            }
                        }
                        .padding(.horizontal, 15)
                    }
                    .padding(.top, -15)
                    Spacer()
                    HStack {
                        Text("Obras")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.primary)
                        Spacer()
                        BtnAdd(ButtonAction: {
                            print("Add")
                        },icon: "plus")
                        .frame(width: 40, height: 40)
                    }
                    .padding(.horizontal)
                    .padding(.top, 30)

                    LazyVGrid(columns: obrasColumns, spacing: 12) {
                        ForEach(obras, id: \.name) { obra in
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
            .searchable(text: $searchText, prompt: "Buscar obras e álbuns")
            .onAppear {
                viewModel.seedObrasIfNeeded()
                verificarESortearObraDoDia()
            }
        }
        
    }
    private func verificarESortearObraDoDia() {
        guard !obras.isEmpty else { return }
        let hojeString = Date().formatted(date: .numeric, time: .omitted)
        if lastRollDate != hojeString || !obras.indices.contains(selectedIndex) {
            executarSorteio()
            lastRollDate = hojeString
        }
    }
    private func sortearNovaObraManual() {
        guard !obras.isEmpty else { return }
        executarSorteio()
        lastRollDate = Date().formatted(date: .numeric, time: .omitted)
    }
    
    private func executarSorteio() {
        if obras.count > 1 {
            var novoIndice = selectedIndex
            while novoIndice == selectedIndex {
                novoIndice = Int.random(in: 0..<obras.count)
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
