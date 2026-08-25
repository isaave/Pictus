//
//  PictusApp.swift
//  Pictus
//
//  Created by Isabella Avelina on 14/08/26.
//

import SwiftUI
internal import SwiftData

@main
struct PictusApp: App {
    private let modelContainer: ModelContainer
    @StateObject private var viewModel: EntityRelationship
    @State private var showSplash = true
    
    init() {
        let container = try! ModelContainer(
            for: ArtEntity.self, AlbumEntity.self, ReflectionEntity.self
        )
        self.modelContainer = container
        
        _viewModel = StateObject(wrappedValue: EntityRelationship(context: container.mainContext))
    }
    
    var body: some Scene {
        WindowGroup {
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
            .modelContainer(modelContainer)
            .animation(.easeInOut(duration: 0.6), value: showSplash)
            .task {
                try? await Task.sleep(for: .seconds(2))
                withAnimation {
                    showSplash = false
                }
            }
        }
    }
}
