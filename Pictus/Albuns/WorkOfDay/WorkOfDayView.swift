//
//  WorkOfDay.swift
//  Pictus
//
//  Created by Andre on 18/08/26.
//

import SwiftUI
import CoreData

struct WorkOfDay: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = CoreDataRelationshipViewModel()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ArtEntity.dateArt, ascending: false)]
    )
    var obras: FetchedResults<ArtEntity>
   
    @AppStorage("selectedIndex") private var selectedIndex: Int = 0
    
    private var obraSelecionada: ArtEntity? {
        guard !obras.isEmpty else { return nil }
        if obras.indices.contains(selectedIndex) {
            return obras[selectedIndex]
        }
        return obras.first
    }
    
    var body: some View {
        Group {
            if obras.isEmpty {
                ContentUnavailableView(
                    "Nenhuma obra encontrada",
                    systemImage: "photo.on.rectangle.angled"
                )
            } else if let obra = obraSelecionada {
                WorkOfDayContentView(obraAtual: obra, viewModel: viewModel)
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

struct WorkOfDayContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var obraAtual: ArtEntity
    @ObservedObject var viewModel: CoreDataRelationshipViewModel
    
    @AppStorage("alreadyOpenedAlert") private var alreadyOpenedAlert: Bool = false
    @State private var showAlert = false
    @State private var reflexoesSalvas: [ReflectionEntity] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Imagem
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
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(obraAtual.ctxArt ?? "Conteúdo da arte")
                            .font(.body)
                            .lineLimit(obraAtual.ctxReleased ? nil : 4)
                            .overlay(alignment: .bottom) {
                                if !obraAtual.ctxReleased {
                                    LinearGradient(
                                        colors: [
                                            .clear,
                                            colorScheme == .dark ? Color.black : Color.white
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                    .frame(height: 40)
                                    .allowsHitTesting(false)
                                }
                            }
                        
                        HStack {
                            Spacer()
                            Button {
                                if !alreadyOpenedAlert {
                                    showAlert.toggle()
                                } else {
                                    obraAtual.ctxReleased.toggle()
                                    try? viewContext.save()
                                }
                            } label: {
                                HStack(spacing: 6) {
                                    Image(systemName: obraAtual.ctxReleased ? "lock.open.fill" : "lock.fill")
                                        .contentTransition(.symbolEffect(.replace))
                                    
                                    Text(obraAtual.ctxReleased ? "Ver menos" : "Ver mais")
                                        .fontWeight(.semibold)
                                        .foregroundStyle(colorScheme == .dark ? .white : .black)
                                }
                            }
                        }
                        .padding(.top, 4)
                    }
                    
                    // Card para criar nova reflexão
                    ReflectionCard(obraAtual: obraAtual, viewModel: viewModel)
                    
                    // Lista de reflexões já registradas para esta obra
                    if !reflexoesSalvas.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Minhas Reflexões")
                                .font(.title3.bold())
                            
                            ForEach(reflexoesSalvas, id: \.self) { item in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.textReflx ?? "")
                                        .font(.body)
                                    
                                    if let data = item.dateReflx {
                                        Text(data.formatted(date: .abbreviated, time: .shortened))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.1))
                                )
                            }
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(16)
            }
        }
        .onAppear {
            carregarReflexoes()
        }
        .overlay(
            Group {
                if showAlert {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture { showAlert = false }
                        
                        ConfirmationAlert(
                            title: "Atenção!",
                            message: "Acessar o contexto desta obra sem análise prévia pode impactar sua interpretação.",
                            question: "Deseja prosseguir?",
                            confirmTitle: "Sim",
                            cancelTitle: "Não",
                            onConfirm: {
                                obraAtual.ctxReleased.toggle()
                                try? viewContext.save()
                                showAlert = false
                                alreadyOpenedAlert = true
                            },
                            onCancel: {
                                showAlert = false
                            }
                        )
                    }
                }
            }
        )
    }
    
    private func carregarReflexoes() {
        reflexoesSalvas = viewModel.fetchReflexoesDaObra(obra: obraAtual)
    }
}
