//
//  SuperheroItemView.swift
//  HeroIQ
//
//  Created by Astor Ludueña  on 16/04/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct SuperheroItemView: View {
    let hero: SuperheroViewModel
    @State private var isPressed = false
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Imagen del héroe
            WebImage(url: URL(string: hero.imageUrl))
                .resizable()
                .indicator(.activity)
                .transition(.fade(duration: 0.5))
                .scaledToFill()
                .frame(height: 200)
                .clipped()
                .overlay(
                    // Gradiente para mejor legibilidad
                    LinearGradient(
                        colors: [
                            .black.opacity(0.6),
                            .black.opacity(0.3),
                            .clear
                        ],
                        startPoint: .bottom,
                        endPoint: .center
                    )
                )
            
            // Información del héroe
            VStack(alignment: .leading, spacing: 6) {
                Text(hero.name)
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .shadow(color: .black, radius: 3, x: 1, y: 1)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Superhero")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(16)
        }
        .frame(height: 200)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: .black.opacity(0.1),
            radius: isPressed ? 2 : 8,
            x: 0,
            y: isPressed ? 2 : 4
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .onTapGesture {
            // Feedback háptico
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .onTapGesture {
            // Animación rápida de tap
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = false
                }
            }
            
            // Feedback háptico
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        }
    }
}

