//
//  NewArtInfo.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 20/08/26.
//

import SwiftUI

struct NewArtInfo: View {
    @State private var nome = ""
    @State private var nomeAutor = ""
    @State private var dataCriacao = Date()
    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing: 10){
                
                Text("Sobre a Obra")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.vertical, 4)
                
                Divider()
                
                HStack{
                    Text("Data")
                        .font(.body)
                    Spacer()
                    DatePickerComp()
                }
                
                Divider()
                
                HStack{
                    Text("Nome da Obra")
                    TextField("Insira o nome da obra", text: $nome)
                        .font(.body)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.vertical, 6)
                
                Divider()
                
                HStack{
                    Text("Autor")
                        .font(.body)
                    TextField("Isira o nome do autor", text:$nomeAutor)
                        .font(.body)
                        .disableAutocorrection(true)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.vertical, 6)
                
//                Divider()
//                
//                HStack{
//                    Text("Nome da Obra")
//                        .font(.body)
//                    Spacer()
//                    TextField("Insira o nome da obra", text: $nome)
//                        .font(.body)
//                        .disableAutocorrection(true)
//                        .disabled(true)
//                }
//                Divider()
//                HStack{
//                    Text("Autor")
//                        .font(.body)
//                    Text("ola")
////                    Spacer()
////                    TextField("Insira o nome do autor", text: $nomeAutor)
//                }
            }
            .padding()
        }
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.gray.opacity(0.2))
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16, style: .continuous))
        }

    }
}

#Preview {
    NewArtInfo()
}
