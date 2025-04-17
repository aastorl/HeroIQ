//
//  SuperheroItem.swift
//  HeroIQ
//
//  Created by Astor Ludueña  on 16/04/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct SuperheroItem: View {
    let hero: SuperheroViewModel

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            WebImage(url: URL(string: hero.imageUrl))
                .resizable()
                .indicator(.activity)
                .scaledToFill()
                .frame(height: 200)
                .clipped()

            LinearGradient(
                colors: [.black.opacity(0.6), .clear],
                startPoint: .bottom,
                endPoint: .center
            )
            .frame(height: 80)

            Text(hero.name)
                .foregroundStyle(.white)
                .font(.title2.bold())
                .padding()
                .shadow(radius: 4)
        }
        .frame(height: 200)
        .background(.ultraThinMaterial)
        .contentShape(Rectangle())
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 6)
    }
}



