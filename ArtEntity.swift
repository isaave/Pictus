//
//  ArtEntity.swift
//  Pictus
//
//  Created by Andre on 24/08/26.
//

import Foundation
import SwiftData

@Model
final class ArtEntity {
    var ctxArt: String?
    var ctxReleased: Bool
    var dateArt: Date?
    @Attribute(.unique) var id: UUID
    var imgArt: Data?
    var local: String?
    var nameArt: String?
    var nameAuthor: String?
    var origin: String?
    @Relationship(inverse: \AlbumEntity.art) var albuns: [AlbumEntity]
    @Relationship(deleteRule: .cascade, inverse: \ReflectionEntity.art) var reflections: [ReflectionEntity]

    init(
        ctxArt: String? = nil,
        ctxReleased: Bool = false,
        dateArt: Date? = nil,
        id: UUID = UUID(),
        imgArt: Data? = nil,
        local: String? = nil,
        nameArt: String? = nil,
        nameAuthor: String? = nil,
        origin: String? = nil,
        albuns: [AlbumEntity] = [],
        reflections: [ReflectionEntity] = []
    ) {
        self.ctxArt = ctxArt
        self.ctxReleased = ctxReleased
        self.dateArt = dateArt
        self.id = id
        self.imgArt = imgArt
        self.local = local
        self.nameArt = nameArt
        self.nameAuthor = nameAuthor
        self.origin = origin
        self.albuns = albuns
        self.reflections = reflections
    }
}
