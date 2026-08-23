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
    @Published var albunsEntities: [AlbumEntity] = []

    init() {
        fetchObras()
        fetchAlbuns()
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
    
    @discardableResult
    func addArt(obra: Obras) -> UUID {
        let newObra = ArtEntity(context: manager.context)
        let id = UUID()
        
        newObra.ctxArt = obra.context.trimmingCharacters(in: .whitespaces).isEmpty ? nil : obra.context
        newObra.id = id
        newObra.nameArt = obra.name.trimmingCharacters(in: .whitespaces).isEmpty ? "Desconhecido" : obra.name
        newObra.nameAuthor = obra.nameAutor.trimmingCharacters(in: .whitespaces).isEmpty ? nil : obra.nameAutor
        newObra.dateArt = obra.dataCriacao > Date() ? Date() : obra.dataCriacao
        newObra.imgArt = obra.img
        newObra.local = obra.local
        newObra.origin = obra.origem
        newObra.ctxReleased = false
        saveData()
        return id
    }
    
    func addEmptyArt() -> UUID {
        let emptyArt = ArtEntity(context: manager.context)
        
        let id = UUID()
        emptyArt.id = id
        emptyArt.origin = "Minhas"
        emptyArt.dateArt = Date()
        
        saveData()
        return id
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
    
    func editObra(name: String?,nameArt : String?, data: Date?, local: String?,img: Data?, uuid: UUID ) {
        let busca: NSFetchRequest<ArtEntity> = ArtEntity.fetchRequest()
        busca.predicate  = NSPredicate(format: "id == %@", uuid as CVarArg)
        busca.fetchLimit = 1
        
        if let result = try? manager.context.fetch(busca).first {
            result.nameArt = nameArt ?? result.nameArt
            result.nameAuthor = name ?? result.nameAuthor
            result.dateArt = data ?? result.dateArt
            result.local = local ?? result.local
            result.imgArt = img ?? result.imgArt
            
            saveData()
        }
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
    
    func addReflectionToID(rfx: String, obra: UUID) {
        
        let busca: NSFetchRequest<ArtEntity> = ArtEntity.fetchRequest()
        busca.predicate  = NSPredicate(format: "id == %@", obra as CVarArg)
        busca.fetchLimit = 1
        
        if let obra = try? manager.context.fetch(busca).first {
            let newReflexao = ReflectionEntity(context: manager.context)
            
            newReflexao.textReflx = rfx
            newReflexao.dateReflx = Date()
            newReflexao.art = obra
            
            saveData()
            
        }
       
    }
    
    func fetchReflexoesDaObra(obra: ArtEntity) -> [ReflectionEntity] {
        let request: NSFetchRequest<ReflectionEntity> = ReflectionEntity.fetchRequest()
                request.predicate = NSPredicate(format: "art == %@", obra)
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
    
    func addObraToAlbuns(idAlbuns: [UUID], idArt: UUID) {
        let request: NSFetchRequest<AlbumEntity> = AlbumEntity.fetchRequest()
        request.predicate = NSPredicate(format: "idAlbum IN %@", idAlbuns)

        let requestObra: NSFetchRequest<ArtEntity> = ArtEntity.fetchRequest()
        requestObra.predicate = NSPredicate(format: "id == %@", idArt as CVarArg)
        requestObra.fetchLimit = 1
        
        guard let novaObra = try? manager.context.fetch(requestObra).first else {
            print("Obra não encontrada: \(idArt)")
            return
        }
        
        do {
            let albuns = try manager.context.fetch(request)

            for album in albuns {
                album.addToArt(novaObra)
            }

            try manager.context.save()
            print("Obra adicionada a \(albuns.count) álbum(s)")
        } catch {
            print("Erro ao adicionar obra: \(error.localizedDescription)")
        }
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
    
    func fetchAlbuns() {
        let request: NSFetchRequest<AlbumEntity> = AlbumEntity.fetchRequest()
        do{
            albunsEntities = try manager.context.fetch(request)
        }catch let error {
            print("erro au subir uma nova obra\(error.localizedDescription)")
        }
    }
    
    
    
   private func saveData() {
        manager.save()
        fetchObras()
        fetchAlbuns()
    }
    
    
    
    
    //testes dados ficticios
    func adicionarAlbunsTeste() {
           let albunsTeste: [(String, String)] = [
               ("Natureza", "mountain.2.fill"),
               ("Retratos", "person.fill"),
               ("Urbano", "building.2.fill"),
               ("Viagens", "airplane.fill")
           ]

           for (nome, symbol) in albunsTeste {
               let album = AlbumEntity(context: manager.context) // ✅ context direto da ViewModel
               album.idAlbum = UUID()
               album.nameAlbum = nome

               let config = UIImage.SymbolConfiguration(pointSize: 200, weight: .regular)
               if let uiImage = UIImage(systemName: symbol, withConfiguration: config),
                  let data = uiImage.jpegData(compressionQuality: 0.8) {
                   album.imgAlbum = data
               }
               album.art = NSSet()
           }

           do {
               try manager.context.save()
               fetchAlbuns() // ✅ já está na ViewModel
               print("✅ 4 álbuns de teste criados")
           } catch {
               print("❌ Erro: \(error.localizedDescription)")
           }
        saveData()
       }
   }
