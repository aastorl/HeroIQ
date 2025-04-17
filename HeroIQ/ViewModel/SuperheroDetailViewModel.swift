//
//  SuperheroDetailViewModel.swift
//  HeroIQ
//
//  Created by Astor Ludueña  on 16/04/2025.
//

import Foundation

@MainActor
class SuperheroDetailViewModel: ObservableObject {
    @Published var name = ""
    @Published var powerstats: [String: String] = [:]
    @Published var imageUrl = ""

    func fetchHero(id: String) async {
        do {
            let hero = try await ApiNetwork.getHeroById(id: id)
            self.name = hero.name
            self.powerstats = [
                "Intelligence": hero.powerstats.intelligence,
                "Strength": hero.powerstats.strength,
                "Speed": hero.powerstats.speed,
                "Durability": hero.powerstats.durability,
                "Power": hero.powerstats.power,
                "Combat": hero.powerstats.combat
            ]
            self.imageUrl = hero.image.url
        } catch {
            print("Error fetching hero detail: \(error)")
        }
    }
}


