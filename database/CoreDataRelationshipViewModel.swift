//
//  CoreDataRelationshipViewModel.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 17/08/26.
//


import SwiftUI
import Combine
import CoreData
import SwiftData
import Foundation

class CoreDataRelationshipViewModel: ObservableObject {
    let manager = CoreDataManage.instance
        
    
    // func obras abaixo
    func addObra(obra: Obras){
        
        let newObra = ObraEntity(context: manager.context)
        newObra.ctxObra = obra.context.trimmingCharacters(in: .whitespaces).isEmpty ? nil : obra.context
        
        
        newObra.id = UUID()
        newObra.nameObra = obra.name.trimmingCharacters(in: .whitespaces).isEmpty ? "Desconhesido" : obra.name
        newObra.dateObra = obra.dataCriacao > Date() ? Date() : obra.dataCriacao
        newObra.imgObra = obra.img
        newObra.origen = obra.origem
        newObra.ctxLibetado = false
        
        saveData()
        }
    func getTodasOrigen(){
    
    }
    
    
    func editDescription(uuid: UUID){
        let busca: NSFetchRequest<ObraEntity> = ObraEntity.fetchRequest()
        busca.predicate  = NSPredicate(format: "id == %@",uuid as CVarArg)
        busca.fetchLimit = 1
        
        if let result = try? manager.context.fetch(busca).first {
            result.ctxLibetado = true
        }
        saveData()
    }
    
    //.....................................//
    
    func addReflection(rfx : String){
        let newReflexao = ReflexaoEntity(context: manager.context)
       
        newReflexao.textReflx = rfx
        newReflexao.dateReflx = Date()
        saveData()
    }
 
    func addAlbuns(){
        
    }
    func saveData() {
    manager.save()
    }
    
}

