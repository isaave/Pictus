//
//  ArtRelationship.swift
//  Pictus
//
//  Created by Andre on 25/08/26.
//

internal import Foundation
import Combine
import SwiftData

@MainActor
final class EntityRelationship : ObservableObject{

    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
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
//
//  ArtViewModel.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 25/08/26.
//



final class ArtViewModel: ObservableObject {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    // Obras
    func addArtwork(name: String, author: String, date: Date,
                    imageData: Data?, location: String?,
                    origin: String, contextText: String?) {
        let entity = ArtEntity()
        entity.id = UUID()
        entity.nameArt = name
        entity.nameAuthor = author
        entity.dateArt = date
        entity.imgArt = imageData
        entity.local = location
        entity.origin = origin
        entity.ctxArt = contextText
        entity.ctxReleased = false
        context.insert(entity)
    }
    
    func deleteArtwork(_ art: ArtEntity) {
        context.delete(art)
    }
    
    func updateArtwork(_ art: ArtEntity, name: String?, artName: String?,
                       date: Date?, location: String?, imageData: Data?) {
        art.nameAuthor = name ?? art.nameAuthor
        art.nameArt = artName ?? art.nameArt
        art.dateArt = date ?? art.dateArt
        art.local = location ?? art.local
        art.imgArt = imageData ?? art.imgArt
    }
    
    // Reflexões
    func addReflection(text: String, to artwork: ArtEntity) {
        let reflection = ReflectionEntity()
        reflection.textReflx = text
        reflection.dateReflx = Date()
        reflection.art = artwork
        context.insert(reflection)
    }
    
    // Álbuns
    func createAlbum(name: String, artworks: [ArtEntity]) {
        let album = AlbumEntity()
        album.idAlbum = UUID()
        album.nameAlbum = name
        album.imgAlbum = artworks.first?.imgArt
        context.insert(album)
        for artwork in artworks {
            album.art?.append(artwork)
        }
    }
    
    func deleteAlbum(_ album: AlbumEntity) {
        context.delete(album)
    }
}
