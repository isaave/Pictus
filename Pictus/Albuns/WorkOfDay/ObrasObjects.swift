//
//  ObrasObjects.swift
//  Pictus
//
//  Created by Andre on 18/08/26.
//

import UIKit

struct ObrasObjects{
    var alreadyRoller = false
    
    let objects: [Obras] = [
        Obras(
            name: "Stánczyk",
            nameAutor: "Jan Matejko",
            dataCriacao: Calendar.current.date(from: DateComponents(year: 1862, month: 10, day: 10)) ?? Date(),
            img:  UIImage(named:"ArtCover")?.jpegData(compressionQuality: 0.1) ?? Data(),
            origem: "Descobertas",
            local: "Polônia",
            
        ),
        Obras(
            name: "andre",
            nameAutor: "oio",
            dataCriacao: Calendar.current.date(from: DateComponents(year: 1862, month: 10, day: 10)) ?? Date(),
            img:  UIImage(named:"ArtCover")?.jpegData(compressionQuality: 0.1) ?? Data(),
            origem: "bla",
            local: "sla"
        ),
        Obras(
            name: "junior",
            nameAutor: "oio",
            dataCriacao: Calendar.current.date(from: DateComponents(year: 1862, month: 10, day: 10)) ?? Date(),
            img:  UIImage(named:"ArtCover")?.jpegData(compressionQuality: 0.1) ?? Data(),
            origem: "bla",
            local: "sla"
        ),
        Obras(
            name: "carlos",
            nameAutor: "oio",
            dataCriacao: Calendar.current.date(from: DateComponents(year: 1862, month: 10, day: 10)) ?? Date(),
            img:  UIImage(named:"ArtCover")?.jpegData(compressionQuality: 0.1) ?? Data(),
            origem: "bla",
            local: "sla"
        )
    ]
    
    func rollArt() -> Int{
        return Int.random(in: 0..<objects.count)
    }
}
