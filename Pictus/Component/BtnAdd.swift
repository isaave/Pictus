//
//  BtnAdd.swift
//  Pictus
//
//  Created by Andre on 17/08/26.
//

import SwiftUI
struct BtnAdd:View{
    var ButtonAction: () -> Void
    var icon: String
    var body: some View{
        Button{
            ButtonAction()
        }label: {
            Image(systemName: icon)
            
        }
    }
}

#Preview {
    BtnAdd(ButtonAction: {
        print("Add")
    },icon: "plus")
}
