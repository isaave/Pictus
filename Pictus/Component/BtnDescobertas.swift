import SwiftUI

struct BtnDescobertas: View {
    @AppStorage("hasDiscovered") private var hasDiscovered: Bool = false
    var action: () -> Void 

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.primary)
                    .frame(width: 50, height: 50)
                    .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 55, style: .continuous))
                
                if !hasDiscovered {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 15, height: 15)
                        .offset(x: 1, y: 3)
                }
            }
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        ZStack {
            BtnDescobertas(action: {})
        }
    }
}
