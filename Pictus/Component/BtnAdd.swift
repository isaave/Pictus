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
                .font(.system(size: 20))
                .foregroundColor(.primary)
                .frame(width: 48, height: 48)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 55, style: .continuous))

        }
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        .buttonStyle(.plain)

    }
}

#Preview {
    BtnAdd(ButtonAction: {
        print("Add")
    },icon: "plus")
}

