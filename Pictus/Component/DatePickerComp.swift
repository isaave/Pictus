//
//  DatePickerComp.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 20/08/26.
//

import SwiftUI

struct DatePickerComp: View {
    
    @State private var dataCriacao = Date()
    
    var body: some View {
        DatePicker(
            "Data da obra",
            selection: $dataCriacao,
            in: ...Date(),
            displayedComponents: .date
        )
        .labelsHidden()
        .datePickerStyle(.compact)
        .colorScheme(.dark)
        .background(
            .black.opacity(0.35),
            in: Capsule()
        )
    }
}

#Preview {
    DatePickerComp()
}
