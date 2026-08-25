//
//  ReflectionEntity.swift
//  Pictus
//
//  Created by Andre on 24/08/26.
//
//

public import Foundation
public import SwiftData


@Model public class ReflectionEntity {
    var dateReflx: Date?
    var textReflx: String?
    var art: ArtEntity?
    public init() {

    }
    
}
