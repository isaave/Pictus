////
////  ReflectionTimeCard.swift
////  Pictus
////
////  Created by Pedro Henrique Hossaka Teruel on 18/08/26.
////
//
//import SwiftUI
//
//struct ReflectionTimeCard: View {
//    var body: some View {
//        VStack(alignment: .leading, spacing: 12) {
//            VStack(alignment: .leading) {
//                Text("Hora de refletir")
//                    .font(.headline)
//                    .fontWeight(.semibold)
//                    .padding(.bottom, 8)
//                Text("Quero Ajuda")
//                    .font(.subheadline)
//                    .foregroundStyle(.secondary)
//                    .padding(.bottom, 2)
//            }
//
//            VStack(spacing: 12) {
//                Button(action: {
//                    
//                }) {
//                    HStack{
//                        Text("Ola")
//                            .font(.headline)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 28)
//                }
//                .buttonStyle(.glassProminent)
//                .tint(.accentColor)
//
//                Button(action: {
//                }) {
//                    HStack{
//                        Text("Ola")
//                            .font(.headline)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 28)
//                }
//                .buttonStyle(.glass)
//            }
//            .font(.body)
//        }
//        .padding(24)
//        .frame(maxWidth: 300)
//        .background {
//            RoundedRectangle(cornerRadius: 38, style: .continuous)
//                .fill(.clear)
//                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 38, style: .continuous))
//        }
//        .clipShape(
//            RoundedRectangle(
//                cornerRadius: 38,
//                style: .continuous
//            )
//        )
//        .shadow(
//            color: .black.opacity(0.15),
//            radius: 24,
//            y: 8
//        )
//        .accessibilityElement(children: .contain)
//        .accessibilityAddTraits(.isModal)
//    }
//}
//
//
//#Preview {
//    ReflectionTimeCard()
//}
