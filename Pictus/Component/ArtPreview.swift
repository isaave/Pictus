//
//  ArtPreview.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 17/08/26.
//

import SwiftUI

struct ArtPreview: View {
    let artName: String
    let authorName: String
    let dateArt: String
    let imgData: Data?

    private var uiImage: UIImage? {
        guard let data = imgData else { return nil }
        return UIImage(data: data)
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 174, height: 228)
                    .clipped()
            } else {
                ZStack {
                    Color.gray.opacity(0.3)
                    Image(systemName: "photo")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
                .frame(width: 174, height: 228)
            }

            LinearGradient(
                colors: [
                    .clear,
                    .black.opacity(0.90)
                ],
                startPoint: .center,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(artName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(1)

                Text("\(authorName) – \(dateArt)")
                    .font(.subheadline)
                    .lineLimit(1)
            }
            .foregroundStyle(.white)
            .padding(14)
        }
        .frame(width: 174, height: 228)
        .cornerRadius(12)
    }
}
