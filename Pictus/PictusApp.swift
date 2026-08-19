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
    var body: some Scene {
        WindowGroup {
            CollectionView()
                .environment(\.managedObjectContext, coreDataManager.context)
        }
    }
}
