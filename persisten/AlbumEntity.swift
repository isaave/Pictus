//
//  AlbumEntity.swift
//  Pictus
//
//  Created by Andre on 24/08/26.
//
//

internal import Foundation
public import SwiftData


@Model public class AlbumEntity {
    var idAlbum: UUID
    var imgAlbum: Data?
    var nameAlbum: String?
    @Relationship(inverse: \ArtEntity.albuns) var art: [ArtEntity]?
    
    public init() {
        idAlbum = UUID()
       
    }
    
}
