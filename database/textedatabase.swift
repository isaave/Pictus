//
//  textedatabase.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 17/08/26.
//

import SwiftUI

struct textedatabase: View {
    @StateObject var vm =  CoreDataRelationshipViewModel()
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button {
            vm.addator(name: "test")
        }label: {
            Text("Save")
        }
    }
}

#Preview {
    textedatabase()
}
