//
//  ContentView.swift
//  Pictus
//
//  Created by Isabella Avelina on 14/08/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            HStack {
                Spacer()
                BtnDescobertas()
                    .frame(width: 48, height: 48) 
            }
            Spacer()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
