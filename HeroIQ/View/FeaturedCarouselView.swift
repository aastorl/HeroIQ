//
//  FeaturedCarouselView.swift
//  HeroIQ
//
//  Created by Astor Ludueña  on 24/04/2025.
//

import Foundation

import SwiftUI

struct FeaturedCarouselView: View {
    let featuredHeroes: [FeaturedHero]

    var body: some View {
        ZStack {
            // Fondo difuminado
            if let firstHero = featuredHeroes.first,
               let url = URL(string: firstHero.imageUrl) {
                AsyncImage(url: url) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .scaledToFill()
                            .blur(radius: 40)
                            .opacity(0.4)
                            .frame(height: 360)
                            .clipped()
                            .cornerRadius(10)
                    }
                }
            }

            TabView {
                ForEach(featuredHeroes) { hero in
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Discover Superheroes")
                            .font(.title.bold())
                            .foregroundColor(.primary)
                            .padding(.leading)

                        GeometryReader { geo in
                            ZStack(alignment: .bottomLeading) {
                                AsyncImage(url: URL(string: hero.imageUrl)) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: geo.size.width * 0.85, height: 280)
                                            .clipped()
                                            .cornerRadius(20)
                                            .shadow(radius: 10)
                                            .offset(x: parallaxOffset(geo: geo))
                                    case .failure:
                                        Color.gray
                                    @unknown default:
                                        EmptyView()
                                    }
                                }

                                Text(hero.name)
                                    .font(.title2.bold())
                                    .foregroundStyle(.white)
                                    .padding(10)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(12)
                                    .padding([.bottom, .leading], 16)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(height: 280)
                    }
                    .padding(.horizontal)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
            .frame(height: 360)
        }
        .frame(height: 360)
        .clipped()
    }

    private func parallaxOffset(geo: GeometryProxy) -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let midX = geo.frame(in: .global).midX
        return (midX - screenWidth / 2) / -20
    }
}




