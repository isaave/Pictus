//
//  ArtEntity.swift
//  Pictus
//
//  Created by Andre on 24/08/26.
//
//

public import Foundation
public import SwiftData


@Model public class ArtEntity {
    var ctxArt: String?
    var ctxReleased: Bool?
    var dateArt: Date?
    var id: UUID?
    var imgArt: Data?
    var local: String?
    var nameArt: String?
    var nameAuthor: String?
    var origin: String?
    var albuns: [AlbumEntity]?
    @Relationship(inverse: \ReflectionEntity.art) var reflections: [ReflectionEntity]?
    public init() {
        ctxReleased = false
    }
    
}
