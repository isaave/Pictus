//
//  ReflectionEntity.swift
//  Pictus
//
//  Created by Andre on 24/08/26.
//

import Foundation
import SwiftData

@Model
final class ReflectionEntity {
    var dateReflx: Date?
    var textReflx: String?
    var art: ArtEntity?

    init(
        dateReflx: Date? = nil,
        textReflx: String? = nil,
        art: ArtEntity? = nil
    ) {
        self.dateReflx = dateReflx
        self.textReflx = textReflx
        self.art = art
    }
}
