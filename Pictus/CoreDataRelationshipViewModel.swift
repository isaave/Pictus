//
//  SwiftDataRelationshipViewModel.swift
//  Pictus
//
//  Created by Pedro Monge Silveira on 17/08/26.
//

import Foundation
import SwiftData
import Combine



@MainActor
final class SwiftDataRelationshipViewModel: ObservableObject {
    private var modelContext: ModelContext?

    @Published var obrasEntities: [ArtEntity] = []
    @Published var albunsEntities: [AlbumEntity] = []

    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext
        fetchObras()
        fetchAlbuns()
    }

    func configure(modelContext: ModelContext) {
        guard self.modelContext !== modelContext else { return }
        self.modelContext = modelContext
        fetchObras()
        fetchAlbuns()
    }

    func seedObrasIfNeeded() {
        if !hasObras() {
            let objetosIniciais = ObrasObjects().objects
            for obra in objetosIniciais {
                addArt(obra: obra)
            }
        }
    }

    private func hasObras() -> Bool {
        guard let modelContext else { return false }

        do {
            let descriptor = FetchDescriptor<ArtEntity>()
            return try modelContext.fetchCount(descriptor) > 0
        } catch {
            print("Erro ao checar existência de obras: \(error)")
            return false
        }
    }

    func fetchObras() {
        guard let modelContext else { return }

        do {
            let descriptor = FetchDescriptor<ArtEntity>(
                sortBy: [SortDescriptor(\.dateArt, order: .reverse)]
            )
            obrasEntities = try modelContext.fetch(descriptor)
        } catch {
            print("Erro ao buscar Obras: \(error.localizedDescription)")
        }
    }

    @discardableResult
    func addArt(obra: Obras) -> UUID {
        guard let modelContext else { return UUID() }

        let id = UUID()
        let newObra = ArtEntity(
            ctxArt: obra.context.trimmingCharacters(in: .whitespaces).isEmpty ? nil : obra.context,
            ctxReleased: false,
            dateArt: obra.dataCriacao > Date() ? Date() : obra.dataCriacao,
            id: id,
            imgArt: obra.img,
            local: obra.local,
            nameArt: obra.name.trimmingCharacters(in: .whitespaces).isEmpty ? "Desconhecido" : obra.name,
            nameAuthor: obra.nameAutor.trimmingCharacters(in: .whitespaces).isEmpty ? nil : obra.nameAutor,
            origin: obra.origem
        )

        modelContext.insert(newObra)
        saveData()
        return id
    }

    func addEmptyArt() -> UUID {
        guard let modelContext else { return UUID() }

        let id = UUID()
        let emptyArt = ArtEntity(
            dateArt: Date(),
            id: id,
            origin: "Minhas"
        )

        modelContext.insert(emptyArt)
        saveData()
        return id
    }

    func getAllOrigin() -> [String] {
        fetchObras()
        return obrasEntities.compactMap(\.origin)
    }

    func editDescription(uuid: UUID) {
        guard let obra = findObra(uuid: uuid) else { return }
        obra.ctxReleased = true
        saveData()
    }

    func editObra(name: String?, nameArt: String?, data: Date?, local: String?, img: Data?, uuid: UUID) {
        guard let obra = findObra(uuid: uuid) else { return }
        obra.nameArt = nameArt ?? obra.nameArt
        obra.nameAuthor = name ?? obra.nameAuthor
        obra.dateArt = data ?? obra.dateArt
        obra.local = local ?? obra.local
        obra.imgArt = img ?? obra.imgArt
        saveData()
    }

    func deleteArt(uuid: UUID) {
        guard let modelContext, let obra = findObra(uuid: uuid) else { return }
        modelContext.delete(obra)
        saveData()
    }

    func addReflection(rfx: String, obra: ArtEntity) {
        guard let modelContext else { return }

        let newReflexao = ReflectionEntity(
            dateReflx: Date(),
            textReflx: rfx,
            art: obra
        )

        modelContext.insert(newReflexao)
        obra.reflections.append(newReflexao)
        saveData()
    }

    func addReflectionToID(rfx: String, obra: UUID) {
        guard let modelContext, let obra = findObra(uuid: obra) else { return }

        let newReflexao = ReflectionEntity(
            dateReflx: Date(),
            textReflx: rfx,
            art: obra
        )

        modelContext.insert(newReflexao)
        obra.reflections.append(newReflexao)
        saveData()
    }

    func fetchReflexoesDaObra(obra: ArtEntity) -> [ReflectionEntity] {
        obra.reflections.sorted {
            ($0.dateReflx ?? .distantPast) > ($1.dateReflx ?? .distantPast)
        }
    }

    func addAlbuns(nome: String, obras: [ArtEntity]) {
        guard let modelContext else { return }

        let newAlbum = AlbumEntity(
            idAlbum: UUID(),
            imgAlbum: obras.first?.imgArt,
            nameAlbum: nome,
            art: obras
        )

        for obra in obras where !obra.albuns.contains(where: { $0.idAlbum == newAlbum.idAlbum }) {
            obra.albuns.append(newAlbum)
        }

        modelContext.insert(newAlbum)
        saveData()
    }

    func addObrasToAlbum(nomeAlbum: String, novasObras: [ArtEntity]) {
        guard let album = albunsEntities.first(where: { $0.nameAlbum == nomeAlbum }) else {
            print("Álbum não encontrado: \(nomeAlbum)")
            return
        }

        for obra in novasObras where !album.art.contains(where: { $0.id == obra.id }) {
            album.art.append(obra)
        }

        album.imgAlbum = album.art.first?.imgArt
        saveData()
    }

    func addObraToAlbuns(idAlbuns: [UUID], idArt: UUID) {
        guard let novaObra = findObra(uuid: idArt) else {
            print("Obra não encontrada: \(idArt)")
            return
        }

        let albuns = albunsEntities.filter { idAlbuns.contains($0.idAlbum) }

        for album in albuns where !album.art.contains(where: { $0.id == novaObra.id }) {
            album.art.append(novaObra)
            album.imgAlbum = album.art.first?.imgArt
        }

        saveData()
        print("Obra adicionada a \(albuns.count) álbum(s)")
    }

    func deleteAlbun(id: UUID) {
        guard let modelContext else { return }
        guard let album = albunsEntities.first(where: { $0.idAlbum == id }) else {
            print("Álbum não encontrado")
            return
        }

        modelContext.delete(album)
        saveData()
    }

    func fetchAlbuns() {
        guard let modelContext else { return }

        do {
            let descriptor = FetchDescriptor<AlbumEntity>(
                sortBy: [SortDescriptor(\.nameAlbum)]
            )
            albunsEntities = try modelContext.fetch(descriptor)
        } catch {
            print("erro au subir uma nova obra\(error.localizedDescription)")
        }
    }

    private func findObra(uuid: UUID) -> ArtEntity? {
        fetchObras()
        return obrasEntities.first { $0.id == uuid }
    }

    private func saveData() {
        guard let modelContext else { return }

        do {
            try modelContext.save()
            fetchObras()
            fetchAlbuns()
        } catch {
            print("Erro ao salvar SwiftData: \(error.localizedDescription)")
        }
    }
}
