//
//  SuperheroSearcher.swift
//  HeroIQ
//
//  Created by Astor Ludueña  on 05/04/2025.
//

import SwiftUI

struct FeaturedHero: Identifiable {
    let id = UUID()
    let name: String
    let imageUrl: String
}

struct SuperheroSearchView: View {
    @StateObject private var viewModel = SuperheroSearcherViewModel()
    @State private var previousScrollOffset: CGFloat = 0
    @State private var isTitleVisible: Bool = true

    private let featuredHeroes: [FeaturedHero] = [
        FeaturedHero(name: "Iron Man", imageUrl: "https://www.superherodb.com/pictures2/portraits/10/100/10476.jpg"),
        FeaturedHero(name: "Superman", imageUrl: "https://www.superherodb.com/pictures2/portraits/10/100/639.jpg"),
        FeaturedHero(name: "Spider-Man", imageUrl: "https://www.superherodb.com/pictures2/portraits/10/100/83.jpg"),
        FeaturedHero(name: "Batman", imageUrl: "https://www.superherodb.com/pictures2/portraits/10/100/30.jpg")
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Título fijo arriba
                Text("HeroIQ")
                    .font(.system(size: 36, weight: .heavy, design: .rounded))
                    .padding(.top, 20)

                // Buscador
                HStack {
                    TextField("Search Superheroes", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    Button {
                        guard !viewModel.searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        Task { await viewModel.search() }
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .padding(10)
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.vertical)
                .background(.ultraThinMaterial)
                .zIndex(1)

                // Carrusel destacado (solo si no hay resultados)
                if viewModel.results.isEmpty {
                    FeaturedCarouselView(featuredHeroes: featuredHeroes)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: viewModel.results.isEmpty)
                }

                // Resultados de búsqueda
                if !viewModel.results.isEmpty {
                    ScrollView {
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: geo.frame(in: .named("scroll")).minY)
                        }
                        .frame(height: 0)

                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.results, id: \.id) { hero in
                                NavigationLink(destination: SuperheroDetailView(id: hero.id)) {
                                    SuperheroItem(hero: hero)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeOut(duration: 0.4), value: viewModel.results)
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        let delta = value - previousScrollOffset
                        if delta < -10 {
                            withAnimation { isTitleVisible = false }
                        } else if delta > 10 {
                            withAnimation { isTitleVisible = true }
                        }
                        previousScrollOffset = value
                    }
                }

                Spacer()
            }
            .background(Color(.systemBackground))
        }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}


#Preview {
    SuperheroSearchView()
}






