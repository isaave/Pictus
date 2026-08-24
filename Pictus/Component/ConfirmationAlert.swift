//
//  ConfirmationAlert.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 18/08/26.
//

import SwiftUI

struct ConfirmationAlert: View {
    let title: String
    let message: String
    let question: String
    let confirmTitle: String
    let cancelTitle: String

    let onConfirm: () -> Void
    let onCancel: () -> Void

    @Environment(\.accessibilityReduceMotion)
    private var reduceMotion

    @AccessibilityFocusState
    private var isTitleFocused: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.30)
                .ignoresSafeArea()
                .onTapGesture {
                    onCancel()
                }

            content
                .padding()
        }
        .transition(
            reduceMotion
                ? .opacity
                : .opacity.combined(with: .scale(scale: 0.96))
        )
        .onAppear {
            isTitleFocused = true
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .accessibilityFocused(
                        $isTitleFocused
                    )
                    .padding(.bottom, 8)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 2)
                Text(question)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .fontWeight(Font.Weight.semibold)
                    .padding(.bottom, 16)
            }

            VStack(spacing: 12) {
                Button(action: {
                    onConfirm()
                }) {
                    HStack{
                        Text(confirmTitle)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
                }
                .buttonStyle(.glassProminent)
                .tint(.accentColor)

                Button(action: {
                    onCancel()
                }) {
                    HStack{
                        Text(cancelTitle)
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 28)
                }
                .buttonStyle(.glass)
            }
            .font(.body)
        }
        .padding(24)
        .frame(maxWidth: 300)
        .background {
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .fill(.clear)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 38, style: .continuous))
        }
        .clipShape(
            RoundedRectangle(
                cornerRadius: 38,
                style: .continuous
            )
        )
        .shadow(
            color: .black.opacity(0.15),
            radius: 24,
            y: 8
        )
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
    }
}



#Preview {
    ConfirmationAlert(
        title: "Atenção!",
        message: "Acessar o contexto desta obra sem análise prévia pode impactar sua interpretação.",
        question: "Deseja prosseguir?",
        confirmTitle: "Sim",
        cancelTitle: "Não",
        onConfirm: {},
        onCancel: {}
    )
}

