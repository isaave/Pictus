//
//  PictusApp.swift
//  Pictus
//
//  Created by Isabella Avelina on 14/08/26.
//

import SwiftUI

@main
struct PictusApp: App {
    let coreDataManager = CoreDataManage.instance
    @StateObject private var Vm = CoreDataRelationshipViewModel()
    
    @State private var showSplash = true

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
            .environment(\.managedObjectContext, coreDataManager.context)
            .environmentObject(Vm)
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
