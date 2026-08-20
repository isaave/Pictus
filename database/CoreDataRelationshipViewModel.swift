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
  
    @Published var obrasEntities: [ArtEntity] = []

    init() {
        seedObrasIfNeeded()
        fetchObras()
    }
    
    func seedObrasIfNeeded() {
    if !hasObras() {
        let objetosIniciais = ObrasObjects().objects
        for obra in objetosIniciais {
            addArt(obra: obra)
        }
    }
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
        }catch let error {
            print("Erro ao buscar Obras: \(error.localizedDescription)")
        }
    }
    
    func addArt(obra: Obras){
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
    
    func addEmptyArt(){
        let EmptyArt = ArtEntity(context: manager.context)
        
        EmptyArt.id = UUID()
        
        saveData()
    }

    func getAllOrigin() -> [String] {
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
        let busca: NSFetchRequest<ArtEntity> = ArtEntity.fetchRequest()
        busca.predicate  = NSPredicate(format: "id == %@", uuid as CVarArg)
        busca.fetchLimit = 1
        
        if let result = try? manager.context.fetch(busca).first {
            result.ctxReleased = true
        }
        saveData()
    }
    
    func deleteArt(uuid: UUID){
        let busca: NSFetchRequest<ArtEntity> = ArtEntity.fetchRequest()
        busca.predicate  = NSPredicate(format: "id == %@", uuid as CVarArg)
        busca.fetchLimit = 1

        do {
            if let result = try? manager.context.fetch(busca).first {
                manager.context.delete(result)
                saveData()
            }
        }
    }
    
    // reflection
    //.....................................//
    
    func addReflection(rfx: String, obra: ArtEntity) {
        let newReflexao = ReflectionEntity(context: manager.context)
        
        newReflexao.textReflx = rfx
        newReflexao.dateReflx = Date()
        newReflexao.art = obra
        
        saveData()
       
    }
    
    func fetchReflexoesDaObra(obra: ArtEntity) -> [ReflectionEntity] {
        let request: NSFetchRequest<ReflectionEntity> = ReflectionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "obra == %@", obra)
        request.sortDescriptors = [NSSortDescriptor(key: "dateReflx", ascending: false)]
        
        return (try? manager.context.fetch(request)) ?? []
    }
    
    //album
    //...........................................//
 
    func addAlbuns(nome: String, obras: [ArtEntity]){
        let newAlbum = AlbumEntity(context: manager.context)
        
        newAlbum.idAlbum = UUID()
        newAlbum.nameAlbum = nome
        newAlbum.imgAlbum = obras.first?.imgArt
        
        let obrasSet = NSSet(array: obras)
            newAlbum.addToArt(obrasSet)
        
        saveData()
    }
    
    func addObrasToAlbum(nomeAlbum: String, novasObras: [ArtEntity]) {
        let request: NSFetchRequest<AlbumEntity> = AlbumEntity.fetchRequest()
        request.predicate = NSPredicate(format: "nameAlbun == %@", nomeAlbum)
        request.fetchLimit = 1

        guard let album = try? manager.context.fetch(request).first else {
            print("Álbum não encontrado: \(nomeAlbum)")
            return
        }

        for obra in novasObras {
            album.addToArt(obra)
        }

        saveData()
    }
    
    func deleteAlbun(id: UUID) {
        let request: NSFetchRequest<AlbumEntity> = AlbumEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        do{
            guard let album = try manager.context.fetch(request).first else {
                    print("Álbum não encontrado")
                    return
                }
                manager.context.delete(album)
                saveData()
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    
    
    
    func saveData() {
        manager.save()
        fetchObras()
    }
}

