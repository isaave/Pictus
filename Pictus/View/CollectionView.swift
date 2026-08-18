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

struct CollectionView: View {

    @State private var selectedMode: SegmentedClasses = .all

    // TODO: Substituir por dados reais (Core Data) quando os álbuns estiverem conectados.
    let albumNames = ["Grafite", "Realismo", "Pintura", "Barroco", "Retrato"]

    var body: some View {
        NavigationStack {
            VStack {

                HStack {
                    Text("Senhas")
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
                    HStack(spacing: -15) {
                        ForEach(albumNames, id: \.self) { name in
                            AlbumCover(albumName: name,coverWidth: 175,coverHeight: 210)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
        }
    }
}

#Preview {
    CollectionView()
}
