//
//  WordOfDayView.swift
//  Pictus
//
//  Created by Andre on 18/08/26.
//

import SwiftUI

struct WorkOfDay: View {
    @StateObject var viewModel: CoreDataRelationshipViewModel = CoreDataRelationshipViewModel()
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ObraEntity.dateObra, ascending: false)]
    )
    var obras: FetchedResults<ObraEntity>
   
    @State private var mostrarToast = false
    
    var body: some View {
        @AppStorage("selectedIndex")  var selectedIndex: Int = 0
        let obraAtual = obras[selectedIndex]
        
        ScrollView{
            Image(uiImage: UIImage(data: obraAtual.imgObra ?? Data()) ?? UIImage(systemName: "photo")!)
                .resizable()
                .scaledToFit()
                .overlay(alignment:.bottomLeading){
                    VStack(alignment: .leading){
                        Text(obraAtual.nameObra ?? "Desconhecido")
                            .font(.title.bold())
                        Text("Autor - Lugar - Ano")
                            .font(.body)
                            .foregroundStyle(.white)
                    }
                    .padding(16)
                }
            
            VStack(alignment:.leading){
                Text("Sobre a obra")
                    .font(.title2.bold())
                Text("Descrição da obra")
                    .font(.default)
                VStack(alignment:.leading){
                    Text("Hora de Refletir")
                        .font(.title3.bold())
                    Divider()
                    Text("Quero Ajuda")
                    
                }
                .padding(16)
            }
            .padding(16)
            
        }
        
        .navigationTitle("Obra do dia")
        .toolbar{
            ToolbarItem(placement:.topBarTrailing){
                BtnAdd(ButtonAction: {
                    print("Add")
                },icon: "ellipsis")
            }
        }
        .ignoresSafeArea(edges:.top)
        
    }
    
   
}




#Preview {
    WorkOfDay(viewModel: CoreDataRelationshipViewModel())
}
