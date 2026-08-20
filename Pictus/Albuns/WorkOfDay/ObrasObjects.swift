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
            context: "Ambientada na Polônia do século XVI, a pintura retrata Stańczyk, o lendário bobo da corte conhecido por sua inteligência e franqueza. Enquanto um baile acontece ao fundo, ele permanece sozinho, mergulhado em seus próprios pensamentos, criando um contraste marcante entre a celebração e o silêncio."
            
        ),
        Obras(
            name: "andre",
            nameAutor: "oio",
            dataCriacao: Calendar.current.date(from: DateComponents(year: 1862, month: 10, day: 10)) ?? Date(),
            img:  UIImage(named:"ArtCover")?.jpegData(compressionQuality: 0.1) ?? Data(),
            origem: "bla",
            local: "sla",
            context: "Ambientada na Polônia do século XVI, a pintura retrata Stańczyk, o lendário bobo da corte conhecido por sua inteligência e franqueza. Enquanto um baile acontece ao fundo, ele permanece sozinho, mergulhado em seus próprios pensamentos, criando um contraste marcante entre a celebração e o silêncio."
        ),
        Obras(
            name: "junior",
            nameAutor: "oio",
            dataCriacao: Calendar.current.date(from: DateComponents(year: 1862, month: 10, day: 10)) ?? Date(),
            img:  UIImage(named:"ArtCover")?.jpegData(compressionQuality: 0.1) ?? Data(),
            origem: "bla",
            local: "sla",
            context: "Ambientada na Polônia do século XVI, a pintura retrata Stańczyk, o lendário bobo da corte conhecido por sua inteligência e franqueza. Enquanto um baile acontece ao fundo, ele permanece sozinho, mergulhado em seus próprios pensamentos, criando um contraste marcante entre a celebração e o silêncio."
        ),
        Obras(
            name: "carlos",
            nameAutor: "oio",
            dataCriacao: Calendar.current.date(from: DateComponents(year: 1862, month: 10, day: 10)) ?? Date(),
            img:  UIImage(named:"ArtCover")?.jpegData(compressionQuality: 0.1) ?? Data(),
            origem: "bla",
            local: "sla",
            context: "Ambientada na Polônia do século XVI, a pintura retrata Stańczyk, o lendário bobo da corte conhecido por sua inteligência e franqueza. Enquanto um baile acontece ao fundo, ele permanece sozinho, mergulhado em seus próprios pensamentos, criando um contraste marcante entre a celebração e o silêncio."
        )
    ]
    
    func rollArt() -> Int{
        return Int.random(in: 0..<objects.count)
    }
}
