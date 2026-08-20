//
//  EyeViewModel.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 19/08/26.
//

import SwiftUI
import Combine

class EyeViewModel: ObservableObject {
    @Published var pupilOffset: CGSize = .zero

    private let whiteSize: CGFloat = 230
    private let pupilSize: CGFloat = 150
    private var timer: AnyCancellable?

    // Limite máximo que a pupila pode se mover sem sair do branco
    private var maxOffset: CGFloat {
        (whiteSize - pupilSize) / 2
    }

    func startMovement() {
        movePupil()

        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.movePupil()
            }
    }

    func stopMovement() {
        timer?.cancel()
        timer = nil
    }

    private func movePupil() {
        withAnimation(.easeInOut(duration: 0.8)) {
            pupilOffset = CGSize(
                width: CGFloat.random(in: -maxOffset...maxOffset),
                height: CGFloat.random(in: -maxOffset...maxOffset)
            )
        }
    }
}
