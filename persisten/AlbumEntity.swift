//
//  AlbumEntity.swift
//  Pictus
//
//  Created by Andre on 24/08/26.
//
//
internal import Foundation
internal import SwiftData

@Model
class AlbumEntity {
    var idAlbum: UUID?
    var imgAlbum: Data?
    var nameAlbum: String?
    @Relationship(inverse: \ArtEntity.albuns) var art: [ArtEntity]?
    
    init(nameAlbum: String?, imgAlbum: Data?,art: [ArtEntity]?) {
        self.idAlbum = UUID()
        self.nameAlbum = nameAlbum
        self.imgAlbum = imgAlbum
        self.art = art
    }
}
