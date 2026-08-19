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
  
    @Published var obrasEntities: [ObraEntity] = []

    init() {
        seedObrasIfNeeded()
        fetchObras()
    }
    
    private func seedObrasIfNeeded() {
        if !hasObras() {
            let objetosIniciais = ObrasObjects().objects
            for obra in objetosIniciais {
                addObra(obra: obra)
            }
        }
    }
    
    private func hasObras() -> Bool {
        let request: NSFetchRequest<ObraEntity> = ObraEntity.fetchRequest()
        request.fetchLimit = 1
        
        do {
            let count = try manager.context.count(for: request)
            return count > 0
        } catch {
            print("Erro ao checar existência de obras: \(error)")
            return false
        }
    }
    
    func fetchObras() {
        let request: NSFetchRequest<ObraEntity> = ObraEntity.fetchRequest()
        do {
            obrasEntities = try manager.context.fetch(request)
        } catch {
            print("Erro ao buscar Obras: \(error)")
        }
    }
    
    func saveData() {
        manager.save()
    }
    
    func addObra(obra: Obras){
        let newObra = ObraEntity(context: manager.context)
       // newObra.ctxObra = obra.context
        newObra.id = UUID()
        newObra.nameObra = obra.name.trimmingCharacters(in: .whitespaces).isEmpty ? "Desconhesido" : obra.name
        newObra.dateObra = obra.dataCriacao > Date() ? Date() : obra.dataCriacao
        newObra.imgObra = obra.img
        newObra.local = obra.local
        newObra.origen = obra.origem
        newObra.ctxLibetado = false
        saveData()

        fetchObras()
    }

    func getTodasOrigen() -> [String] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "ObraEntity")
        request.propertiesToFetch = ["origen"]
        request.resultType = .dictionaryResultType

        do {
            let todasAsObras = try manager.context.fetch(request) as? [[String: Any]] ?? []
            let listaDeOrigens = todasAsObras.compactMap { $0["origen"] as? String }
            return listaDeOrigens
        } catch let error {
            print("Failed to fetch origins: \(error)")
            return []
        }
    }
    
    func editDescription(uuid: UUID){
        let busca: NSFetchRequest<ObraEntity> = ObraEntity.fetchRequest()
        busca.predicate  = NSPredicate(format: "id == %@", uuid as CVarArg)
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
}

