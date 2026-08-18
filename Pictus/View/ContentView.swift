//
//  ContentView.swift
//  Pictus
//
//  Created by Isabella Avelina on 14/08/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            NavigationLink(destination: AlbunsView(searchText: "", )) {
                Text("Hello, world!")
            }
        }
    }
}
#Preview {
    ContentView()
}
