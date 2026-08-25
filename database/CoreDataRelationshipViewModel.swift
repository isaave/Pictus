//
//  CoreDataRelationshipViewModel.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 17/08/26.
//


import SwiftUI
import Combine
import SwiftData
import Foundation



class CoreDataRelationshipViewModel: ObservableObject {
    //Função que verifica se há obras inseridas no banco de dados
    func hasObras(in context: ModelContext) -> Bool {
    var descriptor = FetchDescriptor<ArtEntity>()
    descriptor.fetchLimit = 1
    
    do {
        let results = try context.fetch(descriptor)
        return !results.isEmpty
    } catch {
        print("Erro ao checar existência de obras: \(error)")
        return false
    }
}
    //----------------------------------------------------------------------------------
  
    //Função de edição de obra feita
    func editObra(newAuthorName: String?,newNameArt : String?, newDate: Date?, newLocal: String?,newImg: Data?, uuid: UUID, in context: ModelContext ) {
        let filterObra = #Predicate<ArtEntity>{ obrasEntities in
            obrasEntities.id == uuid
        }
        let obra = FetchDescriptor<ArtEntity>(predicate: filterObra)
        
        do{
            let obraASerAtualizada = try context.fetch(obra)
            
            if let obra = obraASerAtualizada.first{
                
                if let newAuthorName{
                    obra.nameAuthor = newAuthorName 
                }
                
                if let newNameArt{
                    obra.nameArt = newNameArt
                }
                
                if let newDate{
                    obra.dateArt = newDate
                }
                
                if let newLocal{
                    obra.local = newLocal
                }
                
                if let newImg{
                    obra.imgArt = newImg
                }
                
            }
        }catch{
            print("Não foi possível encontrar a obra")
        }
    }
    //----------------------------------------------------------------------------------
    
    //Função de deleção de obra
    func deleteArt(uuid: UUID,in context:ModelContext){
        let obraProcuradaFilter = FetchDescriptor(predicate: #Predicate<ArtEntity>{obra in obra.id == uuid})
        
        do{
            
            let obraProcurada =  try context.fetch(obraProcuradaFilter)
            
            if let obra = obraProcurada.first{
                context.delete(obra)
            }
        }catch{
            print("Não foi possível encontrar a obra")
        }
        
    }
    //----------------------------------------------------------------------------------
    
    //Função para adicionar uma reflexão
    func addReflection(rfx: String, obra: ArtEntity, in context:ModelContext) {
        let newReflexao = ReflectionEntity()
        newReflexao.textReflx = rfx
        newReflexao.dateReflx = Date()
        newReflexao.art = obra
        context.insert(newReflexao)
    }
    //----------------------------------------------------------------------------------
    
    
    func addReflectionToID(rfx: String, idObra: UUID,in context:ModelContext) {
        
        let obraFilter = #Predicate<ArtEntity>{ obra in
            obra.id == idObra
        }
        let descriptor = FetchDescriptor(predicate: obraFilter)
        
        do{
            let resultados = try context.fetch(descriptor)
            
            if let resultados = try context.fetch(descriptor).first{
                let newReflexao = ReflectionEntity()
                newReflexao.textReflx = rfx
                newReflexao.dateReflx = Date()
                newReflexao.art = resultados
                context.insert(newReflexao)
            }
        }catch{
            print("Não foi possível encontrar a obra")
        }
    }
   
    
}
