//
//  ArtPreview.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 17/08/26.
//

import SwiftUI

struct ArtPreview: View {
    @State var artName: String
    @State var authorName: String
    @State var dateArt: String

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image("ArtCover")
                .resizable()
                .scaledToFill()

            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.90)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading) {
                Text(artName)
                    .font(.title3)
                    .fontWeight(.bold)

                Text("\(authorName) – \(dateArt)")
                    .font(.subheadline)
            }
            .foregroundStyle(.white)
            .padding(14)
        }
        .frame(width: 174, height: 228)
        .cornerRadius(12)
    }
}

#Preview {
    ArtPreview(
        artName: "Stańczyk",
        authorName: "Jan Matejko",
        dateArt: "1862"
    )
}
