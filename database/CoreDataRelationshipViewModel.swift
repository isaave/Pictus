//
//  CoreDataRelationshipViewModel.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 17/08/26.
//


import SwiftUI
import Combine
import CoreData


class CoreDataRelationshipViewModel: ObservableObject {
    let manager = CoreDataManage.instance
    
    public var  autor: [AutorEntity] = []
    
    
    
    func addator(name: String) {
        let newAutor = AutorEntity(context: manager.context)
        newAutor.name = name
        saveData()
    }
    
    func saveData() {
    manager.save()
    }
    
}
