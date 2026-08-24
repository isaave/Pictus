//
//  WorkOfDay.swift
//  Pictus
//
//  Created by Andre on 18/08/26.
//

import SwiftUI
import SwiftData

struct WorkOfDay: View {
    @EnvironmentObject var viewModel: SwiftDataRelationshipViewModel
    
    @Query(sort: \ArtEntity.dateArt, order: .reverse)
    var obras: [ArtEntity]
    
    @AppStorage("idObraDoDia") private var idObraDoDia: String = ""
    
    private var obraSelecionada: ArtEntity? {
        if let uuid = UUID(uuidString: idObraDoDia),
           let obraDoDia = obras.first(where: { $0.id == uuid }) {
            return obraDoDia
        }
        return obras.first(where: { $0.origin == "Descobertas" }) ?? obras.first
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
                Button{
                    print("Add")
                }label: {
                    Image(systemName: "ellipsis")
                }
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}
struct WorkOfDayContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.modelContext) private var modelContext
    
    var obraAtual: ArtEntity
    @ObservedObject var viewModel: SwiftDataRelationshipViewModel
    
    @AppStorage("alreadyOpenedAlert") private var alreadyOpenedAlert: Bool = false
    @State private var showAlert = false
    @State private var reflexoesSalvas: [ReflectionEntity] = []
   
    var body: some View {
        
        let autor = obraAtual.nameAuthor ?? "Desconhecido"
        let local = obraAtual.local ?? ""
        let ano = obraAtual.dateArt?.formatted(.dateTime.year()) ?? ""
        
        
        ScrollView {
            VStack(spacing: 16) {
                Image(uiImage: UIImage(data: obraAtual.imgArt ?? Data()) ?? UIImage(systemName: "photo")!)
                    .resizable()
                    .scaledToFit()
                    .overlay {
                        LinearGradient(
                            colors: [
                                .clear,
                                .black.opacity(0.7)
                            ],
                            startPoint: .center,
                            endPoint: .bottom
                        )
                        .allowsHitTesting(false)
                    }
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading) {
                            Text(obraAtual.nameArt ?? "Desconhecido")
                                .foregroundStyle(.white)
                                .font(.title.bold())
                            Text("\(autor) - \(local) - \(ano)")
                                .font(.body)
                                .foregroundStyle(.white)
                        }
                        .padding(16)
                    }
                
                
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    
                    if obraAtual.origin == "Descobertas"{
                        Group{
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
                            }
                            
                        }
                        
                        HStack {
                            Spacer()
                            Button {
                                if !alreadyOpenedAlert {
                                    showAlert.toggle()
                                } else {
                                    obraAtual.ctxReleased.toggle()
                                    try? modelContext.save()
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
                    }
                    
                    ReflectionCard(obraAtual: obraAtual, viewModel: viewModel,hasButton: true)
                    
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
            .navigationTitle("\(obraAtual.nameArt ?? "Desconhecido")")
            
            .ignoresSafeArea(edges:.top)
            .scrollDismissesKeyboard(.interactively)
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
                                    try? modelContext.save()
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
