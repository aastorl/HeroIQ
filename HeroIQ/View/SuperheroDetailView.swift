//
//  SuperheroDetailView.swift
//  HeroIQ
//
//  Created by Astor Ludueña  on 04/04/2025.
//

import SwiftUI
import SDWebImageSwiftUI
import Charts

struct SuperheroDetailView: View {
    let id: String
    @StateObject private var viewModel = SuperheroDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            if viewModel.isLoading {
                LoadingDetailView()
            } else if let errorMessage = viewModel.errorMessage {
                ErrorDetailView(message: errorMessage) {
                    Task {
                        await viewModel.fetchHero(id: id)
                    }
                }
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Header con imagen y información básica
                        HeroHeaderView(
                            imageUrl: viewModel.imageUrl,
                            name: viewModel.name,
                            realName: viewModel.realName,
                            alignment: viewModel.alignment,
                            publisher: viewModel.publisher
                        )
                        
                        // Pestañas de contenido
                        TabSelectorView(selectedTab: $selectedTab)
                        
                        // Contenido de pestañas
                        TabView(selection: $selectedTab) {
                            // Pestaña 1: Estadísticas
                            StatsTabView(powerstats: viewModel.powerstats)
                                .tag(0)
                            
                            // Pestaña 2: Biografía
                            BiographyTabView(
                                biography: viewModel.biography,
                                appearance: viewModel.appearance
                            )
                            .tag(1)
                            
                            // Pestaña 3: Trabajo y Conexiones
                            WorkTabView(
                                work: viewModel.work,
                                connections: viewModel.connections
                            )
                            .tag(2)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(height: 400)
                    }
                }
                .ignoresSafeArea(edges: .top)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 36, height: 36)
                        )
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.fetchHero(id: id)
            }
        }
    }
}

// MARK: - Supporting Views

struct HeroHeaderView: View {
    let imageUrl: String
    let name: String
    let realName: String
    let alignment: String
    let publisher: String
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Imagen de fondo
            WebImage(url: URL(string: imageUrl))
                .resizable()
                .indicator(.activity)
                .scaledToFill()
                .frame(height: 400)
                .clipped()
                .overlay(
                    // Gradiente
                    LinearGradient(
                        colors: [
                            .clear,
                            .clear,
                            .black.opacity(0.3),
                            .black.opacity(0.8)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            // Información del héroe
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(name)
                            .font(.title.bold())
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 2)
                        
                        if !realName.isEmpty && realName != name {
                            Text(realName)
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.9))
                                .shadow(color: .black, radius: 1)
                        }
                    }
                    
                    Spacer()
                    
                    // Badge de alineación
                    AlignmentBadge(alignment: alignment)
                }
                
                if !publisher.isEmpty {
                    Text(publisher)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct AlignmentBadge: View {
    let alignment: String
    
    var alignmentColor: Color {
        switch alignment.lowercased() {
        case "good":
            return .blue
        case "bad":
            return .red
        case "neutral":
            return .orange
        default:
            return .gray
        }
    }
    
    var alignmentIcon: String {
        switch alignment.lowercased() {
        case "good":
            return "heart.fill"
        case "bad":
            return "flame.fill"
        case "neutral":
            return "minus.circle.fill"
        default:
            return "questionmark.circle.fill"
        }
    }
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: alignmentIcon)
                .font(.caption)
            
            Text(alignment.capitalized)
                .font(.caption.weight(.medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(alignmentColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: alignmentColor.opacity(0.3), radius: 4)
    }
}

struct TabSelectorView: View {
    @Binding var selectedTab: Int
    
    private let tabs = [
        ("chart.bar.fill", "Stats"),
        ("person.fill", "Bio"),
        ("briefcase.fill", "Work")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                let tab = tabs[index]
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: tab.0)
                            .font(.system(size: 18, weight: .medium))
                        
                        Text(tab.1)
                            .font(.caption.weight(.medium))
                    }
                    .foregroundColor(selectedTab == index ? .blue : .secondary)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                }
                .background(
                    Rectangle()
                        .fill(selectedTab == index ? Color.blue.opacity(0.1) : Color.clear)
                        .animation(.easeInOut(duration: 0.3), value: selectedTab)
                )
                .overlay(
                    Rectangle()
                        .fill(selectedTab == index ? Color.blue : Color.clear)
                        .frame(height: 3)
                        .animation(.easeInOut(duration: 0.3), value: selectedTab),
                    alignment: .bottom
                )
            }
        }
        .background(Color(.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
    }
}

struct StatsTabView: View {
    let powerstats: [String: String]
    
    var validStats: [(String, Int)] {
        powerstats.compactMap { stat, value in
            if let intValue = Int(value), intValue > 0 {
                return (stat, intValue)
            }
            return nil
        }.sorted { $0.1 > $1.1 }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if !validStats.isEmpty {
                // Gráfico de barras
                Chart(validStats, id: \.0) { stat, value in
                    BarMark(
                        x: .value("Value", value),
                        y: .value("Stat", stat.capitalized)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue.opacity(0.7), .purple.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(4)
                }
                .chartXScale(domain: 0...100)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .frame(height: 200)
                .padding()
                
                // Lista de estadísticas
                VStack(spacing: 12) {
                    ForEach(validStats, id: \.0) { stat, value in
                        StatRowView(statName: stat.capitalized, value: value)
                    }
                }
                .padding(.horizontal)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "chart.bar.xaxis")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No stats available")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct StatRowView: View {
    let statName: String
    let value: Int
    
    var body: some View {
        HStack {
            Text(statName)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 100, alignment: .leading)
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(value) / 100, height: 8)
                        .animation(.easeOut(duration: 1.0), value: value)
                }
            }
            .frame(height: 8)
            
            Text("\(value)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(width: 30, alignment: .trailing)
        }
    }
}

struct BiographyTabView: View {
    let biography: SuperheroDetailViewModel.BiographyInfo
    let appearance: SuperheroDetailViewModel.AppearanceInfo
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Información biográfica
                InfoSectionView(title: "Biography", items: [
                    ("Full Name", biography.fullName),
                    ("Place of Birth", biography.placeOfBirth),
                    ("First Appearance", biography.firstAppearance),
                    ("Aliases", biography.aliases.joined(separator: ", "))
                ].filter { !$0.1.isEmpty })
                
                // Información de apariencia
                InfoSectionView(title: "Appearance", items: [
                    ("Gender", appearance.gender),
                    ("Race", appearance.race),
                    ("Height", appearance.height.joined(separator: " / ")),
                    ("Weight", appearance.weight.joined(separator: " / ")),
                    ("Eye Color", appearance.eyeColor),
                    ("Hair Color", appearance.hairColor)
                ].filter { !$0.1.isEmpty })
            }
            .padding()
        }
    }
}

struct WorkTabView: View {
    let work: SuperheroDetailViewModel.WorkInfo
    let connections: SuperheroDetailViewModel.ConnectionsInfo
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Información laboral
                InfoSectionView(title: "Work", items: [
                    ("Occupation", work.occupation),
                    ("Base", work.base)
                ].filter { !$0.1.isEmpty })
                
                // Conexiones
                InfoSectionView(title: "Connections", items: [
                    ("Group Affiliation", connections.groupAffiliation),
                    ("Relatives", connections.relatives)
                ].filter { !$0.1.isEmpty })
            }
            .padding()
        }
    }
}

struct InfoSectionView: View {
    let title: String
    let items: [(String, String)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                ForEach(items, id: \.0) { item in
                    InfoRowView(label: item.0, value: item.1)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct InfoRowView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            
            Text(value.isEmpty ? "Unknown" : value)
                .font(.body)
                .foregroundColor(value.isEmpty ? .secondary : .primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color(.systemGray6).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct LoadingDetailView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("Loading hero details...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

struct ErrorDetailView: View {
    let message: String
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.orange)
            
            Text("Error Loading Hero")
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

#Preview {
    SuperheroDetailView(id: "1")
}

