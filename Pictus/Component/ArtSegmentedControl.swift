//
//  ArtSegmentedControl.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 17/08/26.
//

import SwiftUI

struct ArtSegmentedControl: View {
    
    @Binding var selection: SegmentedClasses
    
    var body: some View {
        HStack(spacing: 0) {
            
            ForEach(SegmentedClasses.allCases, id: \.self) { mode in
                
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selection = mode
                    }
                } label: {
                    Text(mode.rawValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(
                            selection == mode
                            ? Color.white
                            : Color.primary
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background {
                            if selection == mode {
                                Capsule()
                                    .fill(Color.accent)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .background {
            Capsule()
                .fill(Color(.secondarySystemFill))
        }
    }
}

#Preview {
    NavigationStack {
        ArtSegmentedControl(selection: .constant(.all))
    }
}
