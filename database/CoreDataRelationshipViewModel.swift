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


class CoreDataRelationshipViewModel: ObservableObject {
    let manager = CoreDataManage.instance
        
    func addObra(name: String?, nameAutor: String?, dataCriacao: Date?, context: String, img: Data, origen: String ){
        
        let newObra = ObraEntity(context: manager.context)
        newObra.ctxObra = context.trimmingCharacters(in: .whitespaces).isEmpty ? nil : context
        
        
        newObra.id = UUID()
        newObra.nameObra = context.trimmingCharacters(in: .whitespaces).isEmpty ? "Desconhesido" : name
        newObra.dateObra = dataCriacao
        newObra.imgObra = img
        newObra.origen = origen
        newObra.ctxLibetado = false
        
        saveData()
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

