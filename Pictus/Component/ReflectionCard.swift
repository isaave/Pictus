//
//  ReflectionCard.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 19/08/26.
//

import SwiftUI

struct ReflectionCard: View {
    var obraAtual: ArtEntity
    @ObservedObject var viewModel: EntityRelationship

    var hasButton : Bool
    @State private var reflection = ""
    @State private var wantsHelp: Bool = false
    @State private var selectedIndexes: [Int] = [0, 1, 2]
    
    @AppStorage("hasDiscovered") private var hasDiscovered: Bool = false
    @AppStorage("lastRollDate") private var lastRollDate: String = ""
    @Environment(\.dismiss) private var dismiss
    let questions = QuestionsClass()
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Hora de Refletir")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Divider()
                
                HStack {
                    Text("Quero Ajuda")
                        .font(.body)
                    Spacer()
                    Toggle("", isOn: $wantsHelp)
                }
                
                if wantsHelp {
                    VStack(alignment: .leading, spacing: 8) {
                        if selectedIndexes.count >= 3 {
                            Text("1. \(questions.questions[selectedIndexes[0]])")
                            Text("2. \(questions.questions[selectedIndexes[1]])")
                            Text("3. \(questions.questions[selectedIndexes[2]])")
                        }
                        
                        HStack {
                            Spacer()
                            Button {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    sortearNovosIndices()
                                }
                            } label: {
                                Image(systemName: "arrow.clockwise")
                                    .font(.title2)
                            }
                        }
                    }
                }
                
                Divider()
                
                TextField(
                    "",
                    text: $reflection,
                    prompt: Text("Essa obra parece ser...")
                        .font(.body)
                        .foregroundStyle(.placeholder)
                        .fontWeight(.semibold)
                )
                .padding(.vertical, 8)
                
                if hasButton{
                    HStack {
                        Spacer()
                        Button {
                            let textoReflexao = reflection.trimmingCharacters(in: .whitespacesAndNewlines)
                            
                            if !textoReflexao.isEmpty {
                                viewModel.addReflection(text: textoReflexao, to: obraAtual)
                            }
                            
                            hasDiscovered = true
                            lastRollDate = Date().formatted(date: .numeric, time: .omitted)
                            dismiss()
                        } label: {
                            Text("Adicionar Reflexão")
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.white)
                                .padding(.horizontal, 30)
                                .padding(.vertical, 12)
                                .background {
                                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                                        .fill(Color.accentColor)
                                }
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.gray.opacity(0.12))
        }
        .onAppear {
            sortearNovosIndices()
        }
    }
    
    private func sortearNovosIndices() {
        guard questions.questions.count >= 3 else { return }
        let indicesAleatorios = Array(questions.questions.indices)
            .shuffled()
            .prefix(3)
        selectedIndexes = Array(indicesAleatorios)
    }
}
