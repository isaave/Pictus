//
//  PictusApp.swift
//  Pictus
//
//  Created by Isabella Avelina on 14/08/26.
//

import SwiftUI
import SwiftData

@main
struct PictusApp: App {
    var body: some Scene {
        WindowGroup {
            PictusRootView()
        }
        .modelContainer(for: [
            ArtEntity.self,
            AlbumEntity.self,
            ReflectionEntity.self
        ])
    }
}

private struct PictusRootView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = SwiftDataRelationshipViewModel()
    @State private var showSplash = true

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreen()
                    .transition(.opacity)
                    .zIndex(1)
            } else {
                CollectionView()
                    .transition(.opacity)
            }
        }
        .environmentObject(viewModel)
        .animation(.easeInOut(duration: 0.6), value: showSplash)
        .onAppear {
            viewModel.configure(modelContext: modelContext)
        }
        .task {
            try? await Task.sleep(for: .seconds(2))

            withAnimation {
                showSplash = false
            }
        }
    }
}
