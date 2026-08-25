//
//  ArtRelationship.swift
//  Pictus
//
//  Created by Andre on 25/08/26.
//

import SwiftData
import Foundation

class ArtRelationship{

    
    
    //Função de adicionar uma arte vazia que será inserida posteriormente pelo usuário
    func addEmptyArt(in context:ModelContext) -> UUID {
        let id = UUID()
        let emptyArt = ArtEntity()
        emptyArt.id = id
        emptyArt.origin = "Minhas"
        emptyArt.dateArt = Date()
        context.insert(emptyArt)
        return id
    }
    //----------------------------------------------------------------------------------
    
    func addArt(obra: Obras){
        let obra = ArtEntity()
        obra.id = UUID()
        obra.nameAuthor = obra.nameAuthor
        obra.nameArt = obra.nameArt
        obra.dateArt = obra.dateArt
        obra.imgArt = obra.imgArt
    }
    
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
}
