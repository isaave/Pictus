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

    var body: some View {
        VStack {
            ArtSegmentedControl(
                selection: $selectedMode
            )
            .padding(.horizontal)
            
            switch selectedMode {
            case .all:
                HStack{
                    Text("Exibindo: Todos")
                }
            case .discoveries:
                HStack{
                    Text("Exibindo: Descobertas")
                }
            case .personal:
                HStack{
                    Text("Exibindo Minhas")
                }
            }
        }
    }
}

#Preview {
    CollectionView()
}
