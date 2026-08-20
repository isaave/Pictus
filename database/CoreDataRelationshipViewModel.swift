//
//  CoreDataRelationshipViewModel.swift
//  Pictus
//

import SwiftUI
import Combine
import CoreData
import Foundation

class CoreDataRelationshipViewModel: ObservableObject {
    let manager = CoreDataManage.instance
    
    @Published var obrasEntities: [ArtEntity] = []

    init() {
        // Removido o seedObrasIfNeeded() automático
        fetchObras()
    }
    
    private func hasObras() -> Bool {
        let request: NSFetchRequest<ArtEntity> = ArtEntity.fetchRequest()
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
        let request: NSFetchRequest<ArtEntity> = ArtEntity.fetchRequest()
        do {
            obrasEntities = try manager.context.fetch(request)
        } catch let error {
            print("Erro ao buscar Obras: \(error.localizedDescription)")
        }
    }
    
    func addArt(obra: Obras) {
        let newObra = ArtEntity(context: manager.context)
        
        newObra.ctxArt = obra.context.trimmingCharacters(in: .whitespaces).isEmpty ? nil : obra.context
        newObra.id = UUID()
        newObra.nameArt = obra.name.trimmingCharacters(in: .whitespaces).isEmpty ? "Desconhecido" : obra.name
        newObra.dateArt = obra.dataCriacao > Date() ? Date() : obra.dataCriacao
        newObra.imgArt = obra.img
        newObra.local = obra.local
        newObra.origin = obra.origem
        newObra.ctxReleased = false
        
        saveData()
    }

    func addReflection(rfx: String, obra: ArtEntity) {
        let newReflexao = ReflectionEntity(context: manager.context)
        newReflexao.textReflx = rfx
        newReflexao.dateReflx = Date()
        newReflexao.art = obra
        saveData()
    }

    func fetchReflexoesDaObra(obra: ArtEntity) -> [ReflectionEntity] {
        let request: NSFetchRequest<ReflectionEntity> = ReflectionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "art == %@", obra)
        request.sortDescriptors = [NSSortDescriptor(key: "dateReflx", ascending: false)]
        return (try? manager.context.fetch(request)) ?? []
    }

    func saveData() {
        manager.save()
        fetchObras()
    }
}
