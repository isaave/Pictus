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
        
    func addObra(name: String, nameAutor: String?, autor: AutorEntity?, dataCriacao: Date, descricao: String, img: Data, origen: String ){
        let newObra = ObraEntity(context: manager.context)
        
  
        
        newObra.id = UUID()
        newObra.nameObra = name
        newObra.autor = autor
        newObra.dateObra = dataCriacao
        newObra.ctxObra = descricao
        newObra.imgObra = img
        newObra.origen = origen
        newObra.ctxLibetado = false
        
        saveData()
        }
    
    
    
    func editDescription(uuid: UUID){
    
     
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
