//
//  ArtEntity.swift
//  Pictus
//
//  Created by Andre on 24/08/26.
//
//
internal import Foundation
internal import SwiftData

@Model
class ArtEntity {
    var id: UUID
    var ctxArt: String?
    var ctxReleased: Bool?
    var dateArt: Date?
    var imgArt: Data?
    var local: String?
    var nameArt: String?
    var nameAuthor: String?
    var origin: String?
    var albuns: [AlbumEntity]
    @Relationship(inverse: \ReflectionEntity.art)
    var reflections: [ReflectionEntity]

    init(name: String? = nil, authorName: String? = nil, date: Date? = nil, local: String? = nil, img: Data? = nil, ctxArt: String? = nil, ctxReleased: Bool? = nil, origin: String? = nil) {
        self.id = UUID()
        self.nameArt = name
        self.nameAuthor = authorName
        self.dateArt = date
        self.local = local
        self.imgArt = img
        self.ctxArt = ctxArt
        self.ctxReleased = ctxReleased
        self.origin = origin
        self.albuns = []
        self.reflections = []
    }
}
