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
        
    func addObra(name: String, nameAutor: String?, dataCriacao: Date, context: String, img: Data, origen: String ){
        
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
               print("Erro: nome da obra está vazio")
               return
           }

        
           guard let nameAutor, !nameAutor.trimmingCharacters(in: .whitespaces).isEmpty else {
               print("Erro: nome do autor está vazio ou nil")
               return
           }

       
        //so vai chegar aqui se nn der nenhum erro
        let newObra = ObraEntity(context: manager.context)
        newObra.ctxObra = context.trimmingCharacters(in: .whitespaces).isEmpty ? nil : context
        
        
        newObra.id = UUID()
        newObra.nameObra = name
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
    }
    
    func addReflection(rfx : String){
        let newReflexao = ReflexaoEntity(context: manager.context)
       
        newReflexao.textReflx = rfx
        newReflexao.dateReflx = Date()
    }
 
    
    func addAtor(name: String){

    let newAutor = AutorEntity(context: manager.context)
    newAutor.name = name
    saveData()
    }
    
    func saveData() {
    manager.save()
    }
    
}

