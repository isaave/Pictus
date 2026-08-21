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
            img:  UIImage(named:"Image 1")?.jpegData(compressionQuality: 0.1) ?? Data(),
            origem: "Minhas",
            local: "Polônia",
            context: "Ambientada na Polônia do século XVI, a pintura retrata Stańczyk, o lendário bobo da corte conhecido por sua inteligência e franqueza. Enquanto um baile acontece ao fundo, ele permanece sozinho, mergulhado em seus próprios pensamentos, criando um contraste marcante entre a celebração e o silêncio."
            
        ),
        Obras(
            name: "Céu de Ataíde",
            nameAutor: "Mestre Ataíde",
            dataCriacao: Calendar.current.date(from: DateComponents(year: 1812, month: 10, day: 10)) ?? Date(),
            img:  UIImage(named:"Image 3")?.jpegData(compressionQuality: 0.1) ?? Data(),
            origem: "Minhas",
            local: "",
            context: "O Céu de Ataíde é a famosa pintura em perspectiva do teto da nave da Igreja de São Francisco de Assis de Ouro Preto, criada por Manuel da Costa Ataíde, o Mestre Ataíde, entre 1801 e 1812. A obra-prima do barroco mineiro retrata a Assunção da Virgem Maria cercada por anjos com traços mestiços e tons de pele morena, sob um célebre fundo azul que dá a ilusão de que o teto da igreja se abre para o paraíso."
        ),
        Obras(
            name: "Fiel até a morte",
            nameAutor: "Edward Poynter",
            dataCriacao: Calendar.current.date(from: DateComponents(year: 1865, month: 10, day: 10)) ?? Date(),
            img:  UIImage(named:"ArtCover")?.jpegData(compressionQuality: 0.1) ?? Data(),
            origem: "Minhas",
            local: "",
            context: "Tema Histórico: A obra retrata a erupção do Monte Vesúvio em 79 d.C. e a destruição de Pompeia. Ela se baseia na lenda popular de um soldado romano que permaneceu em seu posto de guarda até o fim, recusando-se a fugir.O Soldado: Em vez de focar em um grande general, Poynter retrata um soldado comum ereto e imóvel. Seus pés firmes no chão e sua mão segurando a lança demonstram obediência militar e sacrifício diante do perigo.O Cenário de Fogo: Ao fundo, o cenário exibe caos, bolas de fogo, pessoas fugindo e mortas no chão, além de riquezas abandonadas que não puderam evitar a morte.Uso de Cores e Linhas: Tons quentes como laranja, vermelho e amarelo predominam para mostrar a destruição. A linha central da tela divide a imobilidade heroica do soldado e o frenesi do fundo"
        ),
        Obras(
            name: "A criação de adão",
            nameAutor: "Michelangelo",
            dataCriacao: Calendar.current.date(from: DateComponents(year: 1511, month: 10, day: 10)) ?? Date(),
            img:  UIImage(named:"Image 2")?.jpegData(compressionQuality: 0.1) ?? Data(),
            origem: "Minhas",
            local: "",
            context: "O Quase Toque: O espaço pequeno entre o dedo de Deus e o dedo de Adão mostra o momento antes da centelha da vida passar para o homem.Posturas: Deus surge em movimento, cercado por anjos. Adão fica deitado de forma relaxada, esperando a energia vital.Forma do Manto: O tecido vermelho ao redor de Deus tem o formato parecido com um cérebro humano, o que simboliza a mente e a razão divina"
        )
    ]
    
    func rollArt() -> Int{
        return Int.random(in: 0..<objects.count)
    }
}
