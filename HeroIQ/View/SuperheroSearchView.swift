//
//  SuperheroSearchView.swift
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
                // Header con título y buscador
                VStack(spacing: 16) {
                    // Título animado
                    Text("HeroIQ")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .scaleEffect(isTitleVisible ? 1.0 : 0.8)
                        .opacity(isTitleVisible ? 1.0 : 0.7)
                        .animation(.spring(response: 0.6), value: isTitleVisible)

                    // Buscador mejorado
                    SearchBarView(
                        searchText: $viewModel.searchText,
                        isLoading: viewModel.isLoading,
                        onSearchTapped: {
                            Task { await viewModel.search() }
                        },
                        onClearTapped: {
                            viewModel.clearSearch()
                        }
                    )
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 16)
                .background(.ultraThinMaterial)
                .zIndex(1)

                // Contenido principal
                ZStack {
                    // Estado vacío - Carousel de héroes destacados
                    if viewModel.results.isEmpty && !viewModel.isLoading && viewModel.searchText.isEmpty {
                        FeaturedCarouselView()
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Estado de carga
                    else if viewModel.isLoading {
                        LoadingView()
                            .transition(.opacity)
                    }
                    
                    // Estado de error
                    else if let errorMessage = viewModel.errorMessage {
                        ErrorView(
                            message: errorMessage,
                            onRetry: {
                                Task { await viewModel.search() }
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // Resultados de búsqueda
                    else if !viewModel.results.isEmpty {
                        SearchResultsView(
                            results: viewModel.results,
                            onScrollOffsetChanged: { offset in
                                handleScrollOffset(offset)
                            }
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    
                    // Estado sin resultados
                    else if !viewModel.searchText.isEmpty {
                        NoResultsView(searchText: viewModel.searchText)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: viewModel.results.isEmpty)
                .animation(.easeInOut(duration: 0.3), value: viewModel.isLoading)
                .animation(.easeInOut(duration: 0.3), value: viewModel.errorMessage)
                
                Spacer()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .onAppear {
            // Pre-cargar héroes destacados si es necesario
            if viewModel.results.isEmpty {
                Task {
                    await viewModel.loadFeaturedHeroes()
                }
            }
        }
    }
    
    private func handleScrollOffset(_ offset: CGFloat) {
        let delta = offset - previousScrollOffset
        if delta < -10 {
            withAnimation(.spring(response: 0.4)) {
                isTitleVisible = false
            }
        } else if delta > 10 {
            withAnimation(.spring(response: 0.4)) {
                isTitleVisible = true
            }
        }
        previousScrollOffset = offset
    }
}

// MARK: - Supporting Views

struct SearchBarView: View {
    @Binding var searchText: String
    let isLoading: Bool
    let onSearchTapped: () -> Void
    let onClearTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Campo de búsqueda
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search superheroes...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onSubmit {
                        onSearchTapped()
                    }
                    .disabled(isLoading)
                
                if !searchText.isEmpty {
                    Button(action: onClearTapped) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // Botón de búsqueda
            Button(action: onSearchTapped) {
                Group {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isLoading || searchText.trimmingCharacters(in: .whitespaces).isEmpty)
        }
    }
}

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Searching heroes...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Oops!")
                .font(.title.bold())
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button("Try Again", action: onRetry)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct NoResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No heroes found")
                .font(.title2.bold())
            
            Text("We couldn't find any superheroes matching '\(searchText)'")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Text("Try a different search term")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct SearchResultsView: View {
    let results: [SuperheroViewModel]
    let onScrollOffsetChanged: (CGFloat) -> Void
    
    var body: some View {
        ScrollView {
            GeometryReader { geo in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self,
                              value: geo.frame(in: .named("scroll")).minY)
            }
            .frame(height: 0)
            
            LazyVStack(spacing: 16) {
                ForEach(results, id: \.id) { hero in
                    NavigationLink(destination: SuperheroDetailView(id: hero.id)) {
                        SuperheroItemView(hero: hero)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            onScrollOffsetChanged(value)
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






