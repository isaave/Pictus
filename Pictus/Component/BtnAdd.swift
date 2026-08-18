//
//  BtnAdd.swift
//  Pictus
//
//  Created by Andre on 17/08/26.
//

import SwiftUI
struct BtnAdd:View{
    var ButtonAction: () -> Void
    var body: some View{
        Button{
            ButtonAction()
        }label: {
            Image(systemName: "plus")
            
        }
    }
}

#Preview {
    BtnAdd(ButtonAction: {
        print("Add")
    })
}
