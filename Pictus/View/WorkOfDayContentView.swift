import SwiftUI
internal import CoreData

struct WorkOfDayContentView: View {
    let obraAtual: ArtEntity
    @ObservedObject var viewModel: CoreDataRelationshipViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let data = obraAtual.imgArt, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.secondary.opacity(0.15))
                        Image(systemName: "photo")
                            .font(.system(size: 48, weight: .regular))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 220)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(obraAtual.nameArt ?? "Sem Título")
                        .font(.title.bold())
                    Text(obraAtual.nameAuthor ?? obraAtual.local ?? "Desconhecido")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    if let date = obraAtual.dateArt {
                        Text(date.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if let notes = obraAtual.ctxArt, !notes.isEmpty {
                    Text(notes)
                        .font(.body)
                        .foregroundStyle(.primary)
                }

                Spacer(minLength: 0)
            }
            .padding()
        }
        .navigationTitle("Obra do dia")
        .navigationBarTitleDisplayMode(.inline)
    }
}


