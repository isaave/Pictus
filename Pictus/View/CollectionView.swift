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

    @State private var selectedMode: SegmentedClasses = .all
    @State private var searchText = ""

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
                            print("Add obra")
                        })
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
        }
    }
}

#Preview {
    CollectionView()
}
