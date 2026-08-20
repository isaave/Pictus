//
//  ReflectionCard.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 19/08/26.
//

import SwiftUI

struct ReflectionCard: View {
    
    @State private var reflection = ""
    @State private var wantsHelp: Bool = false
    
    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing: 16){
                Text("Hora de Refletir")
                    .font(.title3)
                    .fontWeight(.semibold)
                Divider()
                HStack{
                    Text("Quero Ajuda")
                        .font(.body)
                    Spacer()
                    Toggle("", isOn: $wantsHelp)
                }
                
                if wantsHelp{
                    VStack{
                        Text("1.")
                        Text("2.")
                        Text("3.")
                        HStack{
                            Spacer()
                            Image(systemName: "arrow.clockwise")
                                .font(.title2)
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
                Spacer()

                HStack {
                    Spacer()
                    Button {
                    } label: {
                        Text("Adicionar Reflexão")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                Color.gray.opacity(0.8)
                            )
                            .padding(.horizontal, 30)
                            .padding(.vertical)
                            .background {
                                RoundedRectangle(cornerRadius: 32, style: .continuous)
                                    .fill(.clear)
                                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 32, style: .continuous))
                            }
                    }
                    Spacer()
                }.padding()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.gray.opacity(0.2))
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16, style: .continuous))
        }

    }
}

#Preview {
    ReflectionCard()
}
