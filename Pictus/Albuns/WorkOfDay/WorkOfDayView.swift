//
//  WordOfDayView.swift
//  Pictus
//
//  Created by Andre on 18/08/26.
//

//
//  WordOfDayView.swift
//  Pictus
//

import SwiftUI

struct WorkOfDay: View {
    @StateObject var viewModel: CoreDataRelationshipViewModel = CoreDataRelationshipViewModel()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ArtEntity.dateArt, ascending: false)]
    )
    var obras: FetchedResults<ArtEntity>
   
    @AppStorage("selectedIndex") private var selectedIndex: Int = 0
    @AppStorage("hasDiscovered") private var hasDiscovered: Bool = false
    
    @State private var mostrarToast = false
    @State private var toggleAtivo = false
    
    var body: some View {
        Group {
           
            if obras.isEmpty {
                ContentUnavailableView(
                    "Nenhuma obra encontrada",
                    systemImage: "photo.on.rectangle.angled"
                )
            } else if obras.indices.contains(selectedIndex) {
                let obraAtual = obras[selectedIndex]
                
                ScrollView {
                    Image(uiImage: UIImage(data: obraAtual.imgArt ?? Data()) ?? UIImage(systemName: "photo")!)
                        .resizable()
                        .scaledToFit()
                        .overlay(alignment: .bottomLeading) {
                            VStack(alignment: .leading) {
                                Text(obraAtual.nameArt ?? "Desconhecido")
                                    .font(.title.bold())
                                Text("Autor - Lugar - Ano")
                                    .font(.body)
                                    .foregroundStyle(.white)
                            }
                            .padding(16)
                        }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Sobre a obra")
                            .font(.title2.bold())
                        
                        Text(obraAtual.ctxArt ?? "Conteúdo da arte")
                            .font(.body)
                            .overlay(
                                Rectangle()
                                
                                    .frame(maxWidth: .infinity,maxHeight: 50)
                                    .blur(radius: 10,)
                                
                            )
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Hora de Refletir")
                                .font(.title3.bold())
                            
                            Text("Pensou em algo novo?")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Divider()
                            
                            Toggle("Quero Ajuda", isOn: $toggleAtivo)
                                .tint(.accentColor)
                        }
                        .padding(16)
                    }
                    .padding(16)
                    
                    Button {
                        hasDiscovered.toggle()
                    } label: {
                        Text("Adicionar Reflexão")
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.bottom, 20)
                }
            } else {
                ProgressView("Carregando obra...")
            }
        }
        .navigationTitle("Obra do dia")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                BtnAdd(ButtonAction: {
                    print("Add")
                }, icon: "ellipsis")
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}

#Preview {
    NavigationStack {
        WorkOfDay(viewModel: CoreDataRelationshipViewModel())
    }
}
