//
//  CoreDataManage.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 17/08/26.
//

import SwiftData

struct SwiftDataManage {
    static let modelTypes: [any PersistentModel.Type] = [
        ArtEntity.self,
        AlbumEntity.self,
        ReflectionEntity.self
    ]
}
