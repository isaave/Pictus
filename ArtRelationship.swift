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
    
}
