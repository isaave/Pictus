//
//  BtnDescobertas.swift
//  Pictus
//
//  Created by Isabella Avelina on 17/08/26.
//
import SwiftUI

struct BtnDescobertas: View {


    @State private var Descoberta: Bool = true

    var body: some View {
        Button {
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                    .frame(width: 48, height: 48)
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 55, style: .continuous))

                if Descoberta {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 15, height: 15)
                        .offset(x: 1, y: 3)
                }
            }
        }
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ZStack {
        BtnDescobertas()
    }
}
