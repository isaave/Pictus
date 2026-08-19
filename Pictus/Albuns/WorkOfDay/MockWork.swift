//
//  MockWork.swift
//  Pictus
//
//  Created by Andre on 17/08/26.
//

import Foundation
import SwiftUI

class Obras{
    var name: String = ""
    var nameAutor: String = ""
    var dataCriacao: Date = Date()
    var context: Bool = false
    var img: Data = Data()
    var origem: String = ""
    var local: String = ""
    
    init(name: String, nameAutor: String, dataCriacao: Date = Date(), img: Data, origem: String,local: String) {
            self.name = name
            self.nameAutor = nameAutor
            self.dataCriacao = dataCriacao
            self.img = img
            self.origem = origem
        }
}


