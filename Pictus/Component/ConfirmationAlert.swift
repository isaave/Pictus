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
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .accessibilityFocused(
                        $isTitleFocused
                    )
                Text(message)
                    .font(.body)
                    .foregroundStyle(.secondary)
                Text(question)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .fontWeight(Font.Weight.semibold)
                    
            }

            VStack(spacing: 12) {
                Button(action: {
                    onConfirm()
                }) {
                    HStack{
                        Text(confirmTitle)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background {
                        Capsule()
                            .fill(Color(.accent))
                    }

                }
                //.buttonStyle(.borderedProminent)
                .tint(.accentColor)
                
                
                //IMport pod
                
                Button(action: {
                    onCancel()
                }) {
                    HStack{
                        Text(cancelTitle)
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background {
                        Capsule()
                            .fill(Color(.systemGray3))
                    }

                }
                //.buttonStyle(.borderedProminent)
                //.tint(Color(.systemGray3))

            }
        }
        .padding(24)
        .frame(maxWidth: 420)
        .background(.regularMaterial)
        .clipShape(
            RoundedRectangle(
                cornerRadius: 28,
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
        title: "Atenção",
        message: "Acessar o contexto desta obra sem análise prévia pode impactar sua interpretação.",
        question: "Deseja continuar?",
        confirmTitle: "Sim",
        cancelTitle: "Não",
        onConfirm: {},
        onCancel: {}
    )
}
