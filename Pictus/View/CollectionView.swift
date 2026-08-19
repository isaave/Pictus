//
//  CollectionView.swift
//  Pictus
//
//  Created by Pedro Henrique Hossaka Teruel on 17/08/26.
//

import SwiftUI

enum SegmentedClasses: String, CaseIterable {
    case all = "Todos"
    case discoveries = "Descobertas"
    case personal = "Minhas"
}

struct MockObra {
    let name: String
    let author: String
    let date: String
    let category: SegmentedClasses
}

struct MockAlbum {
    let name: String
    let category: SegmentedClasses
}

struct CollectionView: View {
    @StateObject var viewModel: CoreDataRelationshipViewModel = CoreDataRelationshipViewModel()
    @State private var selectedMode: SegmentedClasses = .all
    @State private var searchText = ""
    
    @AppStorage("selectedIndex") private var selectedIndex: Int = 0
    @AppStorage("hasDiscovered") private var hasDiscovered: Bool = false
    @AppStorage("lastRollDate") private var lastRollDate: String = ""
    
    @State private var mostrarToast = false
    @State private var irParaObraDoDia = false
    
    let albums = [
        MockAlbum(name: "Grafite", category: .discoveries),
        MockAlbum(name: "Realismo", category: .discoveries),
        MockAlbum(name: "Pintura", category: .discoveries),
        MockAlbum(name: "Barroco", category: .discoveries),
        MockAlbum(name: "Retrato", category: .discoveries),
        MockAlbum(name: "Meu Álbum", category: .personal)
    ]
    
    let obras = [
        MockObra(name: "Stańczyk", author: "Jan Matejko", date: "1862", category: .discoveries),
        MockObra(name: "A Criação de Adão", author: "Michelangelo", date: "1511", category: .discoveries),
        MockObra(name: "Fiel até a morte", author: "Edward Poynter", date: "1865", category: .discoveries),
        MockObra(name: "O céu de Ataíde", author: "Mestre Ataíde", date: "1812", category: .discoveries),
        MockObra(name: "Minha obra", author: "Minha coleção", date: "2026", category: .personal)
    ]
    
    let obrasColumns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // MARK: - Filtros Computados
    
    var filteredObras: [MockObra] {
        var result: [MockObra]
        
        switch selectedMode {
        case .all:
            result = obras
        case .discoveries:
            result = obras.filter { $0.category == .discoveries }
        case .personal:
            result = obras.filter { $0.category == .personal }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.author.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    var filteredAlbums: [MockAlbum] {
        var result: [MockAlbum]
        
        switch selectedMode {
        case .all:
            result = albums
        case .discoveries:
            result = albums.filter { $0.category == .discoveries }
        case .personal:
            result = albums.filter { $0.category == .personal }
        }
        
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 20) {
                        
                        // Header
                        HStack {
                            Text("Coleções")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            BtnDescobertas {
                                tratarCliqueDescoberta()
                            }
                            .frame(width: 48, height: 48)
                        }
                        .padding(.horizontal)
                        .padding(.top, -10)
                        
                        
                        // Segmented Control
                        ArtSegmentedControl(selection: $selectedMode)
                            .padding(.horizontal)
                        
                        // Álbuns
                        NavigationLink(destination: AlbunsView(searchText: "")) {
                            HStack {
                                Text("Álbuns")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.primary)
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.primary)
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        .buttonStyle(.plain)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(filteredAlbums, id: \.name) { album in
                                    AlbumCover(
                                        albumName: album.name,
                                        coverWidth: 130,
                                        coverHeight: 155
                                    )
                                }
                            }
                            .padding(.horizontal, 15)
                        }
                        
                        // Obras
                        HStack {
                            Text("Obras")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 2)
                            
                            Spacer()
                            
                            BtnAdd(
                                ButtonAction: { print("Add") },
                                icon: "plus"
                            )
                            .frame(width: 40, height: 40)
                            .padding(.horizontal, 9)
                        }
                    
                        .padding(.top, 10)
                        .padding(.horizontal)
                        
                        if filteredObras.isEmpty {
                            VStack(spacing: 10) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 40))
                                    .foregroundStyle(.secondary)
                                
                                Text("Nenhuma obra encontrada")
                                    .font(.headline)
                                
                                Text(
                                    selectedMode == .personal
                                    ? "Você ainda não possui obras na sua coleção."
                                    : "Não encontramos obras para esse filtro."
                                )
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .padding(.horizontal)
                        } else {
                            LazyVGrid(columns: obrasColumns, spacing: 12) {
                                ForEach(filteredObras, id: \.name) { obra in
                                    ArtPreview(
                                        artName: obra.name,
                                        authorName: obra.author,
                                        dateArt: obra.date
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 30)
                }
//                .searchable(text: $searchText, prompt: "Buscar obras e álbuns")
                
                // Toast Feedback
                if mostrarToast {
                    Text("Você já abriu esta obra hoje, espere até amanhã!")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 18)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.85))
                        )
                        .padding(.bottom, 25)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .navigationDestination(isPresented: $irParaObraDoDia) {
                WorkOfDay()
            }
            .onAppear {
                viewModel.seedObrasIfNeeded()
                verificarESortearObraDoDia()
            }
        }
        .searchable(text: $searchText, prompt: "Buscar obras e álbuns")
        .ignoresSafeArea()
    }
    
    // MARK: - Métodos Auxiliares
    
    private func tratarCliqueDescoberta() {
        let hojeString = Date().formatted(date: .numeric, time: .omitted)
        
        if lastRollDate == hojeString && hasDiscovered {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                mostrarToast = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    mostrarToast = false
                }
            }
        } else {
            executarSorteio()
            lastRollDate = hojeString
            hasDiscovered = true
            irParaObraDoDia = true
        }
    }
    
    private func verificarESortearObraDoDia() {
        guard !obras.isEmpty else { return }
        let hojeString = Date().formatted(date: .numeric, time: .omitted)
        
        if lastRollDate != hojeString {
            hasDiscovered = false
        }
        
        if lastRollDate != hojeString || !obras.indices.contains(selectedIndex) {
            executarSorteio()
        }
    }
    
    private func sortearNovaObraManual() {
        guard !obras.isEmpty else { return }
        executarSorteio()
        lastRollDate = Date().formatted(date: .numeric, time: .omitted)
    }
    
    private func executarSorteio() {
        if obras.count > 1 {
            var novoIndice = selectedIndex
            while novoIndice == selectedIndex {
                novoIndice = Int.random(in: 0..<obras.count)
            }
            selectedIndex = novoIndice
        } else {
            selectedIndex = 0
        }
    }
}
   

#Preview {
    CollectionView()
}
