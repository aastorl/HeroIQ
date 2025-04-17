//
//  SuperheroSearcher.swift
//  HeroIQ
//
//  Created by Astor Ludueña  on 05/04/2025.
//

import SwiftUI

struct SuperheroSearchView: View {
    @StateObject private var viewModel = SuperheroSearcherViewModel()
    @State private var previousScrollOffset: CGFloat = 0
    @State private var isTitleVisible: Bool = true

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header: solo el título
                if isTitleVisible {
                    Text("HeroIQ")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 16)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: isTitleVisible)
                }

                // Buscador fijo
                HStack {
                    TextField("Search Superheroes", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    Button("Search") {
                        Task {
                            await viewModel.search()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial)
                .zIndex(1) // mantiene el buscador arriba

                // Resultados
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
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    let delta = value - previousScrollOffset
                    if delta < -10 {
                        withAnimation {
                            isTitleVisible = false
                        }
                    } else if delta > 10 {
                        withAnimation {
                            isTitleVisible = true
                        }
                    }
                    previousScrollOffset = value
                }
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




