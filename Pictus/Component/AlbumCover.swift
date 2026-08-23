//
//  AlbumCover.swift
//  Pictus
//
//  Created by Andre on 17/08/26.
//

import SwiftUI
struct AlbumCover: View {
    @State var albumName: String
    var coverData: Data? = nil
    var coverWidth: CGFloat
    var coverHeight: CGFloat

     var body: some View {
        albumImage
            .resizable()
            .scaledToFill()
            .frame(width: coverWidth, height: coverHeight)
            .cornerRadius(10)
            .clipped()  
            .overlay(
                Rectangle()
                    .frame(width: coverWidth, height: coverHeight * 0.24)
                    .padding(.top, coverHeight * 0.67)
                    .opacity(0.4)
                    .blur(radius: 100)
                    .shadow(color: .black, radius: 10, x: 0, y: 0)
            )
            .overlay(
                Text(albumName)
                    .foregroundStyle(.white)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .padding(.top, coverHeight * 0.71)
            )
    }

    private var albumImage: Image {
        if let coverData,
           let uiImage = UIImage(data: coverData) {
            return Image(uiImage: uiImage)
        }

        return Image("Image")
    }
}
#Preview {
    AlbumCover(albumName: "Grafite", coverWidth: 175, coverHeight: 210)
}
