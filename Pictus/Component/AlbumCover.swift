//
//  AlbumCover.swift
//  Pictus
//
//  Created by Andre on 17/08/26.
//

import SwiftUI
struct AlbumCover:View {
    @State var albumName : String
    var coverWidth: CGFloat
    var coverHeight: CGFloat
    
    var body: some View {
        Image("Image")
            .resizable()
            .scaledToFill()
            .frame(width: coverWidth,height: coverHeight)
            .cornerRadius(10)
            .padding()
            .overlay(
                Rectangle()
                    .frame(width: 175,height: 50)
                    .padding(.top,140)
                    .opacity(0.4)
                    .blur(radius: 100)
                    .shadow(color: .black, radius: 10, x: 0, y: 0)
            )
            .overlay(
                Text(albumName)
                    .foregroundStyle(.white)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top,150)
            )
//        Rectangle()
//            .frame(width: 175,height: 210)
//            .cornerRadius(10)
//            .padding()
//            .overlay(
//                Text(albumName)
//                    .foregroundStyle(.white)
//                    .font(.title3)
//                    .fontWeight(.semibold)
//                    .padding(.top,150)
//            )
    }
}
#Preview {
    AlbumCover(albumName: "Grafite",coverWidth: 175,coverHeight: 210)
}
