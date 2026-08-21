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
    @Published var albunsEntities: [AlbumEntity] = []

    init() {
        // Removido o seedObrasIfNeeded() automático
        fetchObras()
        fetchAlbuns()  
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

        saveData()
    }
    
    func addObraToAlbuns(idAlbuns: [UUID], novaObra: ArtEntity) {
        let request: NSFetchRequest<AlbumEntity> = AlbumEntity.fetchRequest()
        request.predicate = NSPredicate(format: "idAlbum IN %@", idAlbuns)

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
    
    
    
    func saveData() {
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
}
