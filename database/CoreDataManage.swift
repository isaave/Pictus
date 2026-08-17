//
//  CoreDataManage.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 17/08/26.
//

import SwiftUI
import Combine
import CoreData

class CoreDataManage {
    
    static let instance = CoreDataManage()
    
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init() {
        container = NSPersistentContainer(name: "DatabaseModel")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        context = container.viewContext
    }
    
    func save() {
        do {
            try context.save()
            print("save core data")
        } catch let error{
            print("error saving core data: \(error.localizedDescription)")
        }
    }
}
