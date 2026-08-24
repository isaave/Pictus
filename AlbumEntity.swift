//
//  AlbumEntity.swift
//  Pictus
//
//  Created by Andre on 24/08/26.
//

import Foundation
import SwiftData

@Model
final class AlbumEntity {
    @Attribute(.unique) var idAlbum: UUID
    var imgAlbum: Data?
    var nameAlbum: String?
    var art: [ArtEntity]

    init(
        idAlbum: UUID = UUID(),
        imgAlbum: Data? = nil,
        nameAlbum: String? = nil,
        art: [ArtEntity] = []
    ) {
        self.idAlbum = idAlbum
        self.imgAlbum = imgAlbum
        self.nameAlbum = nameAlbum
        self.art = art
    }
}
