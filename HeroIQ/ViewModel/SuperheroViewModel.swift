//
//  SuperheroViewModel.swift
//  HeroIQ
//
//  Created by Astor Ludueña  on 16/04/2025.
//

import Foundation

struct SuperheroViewModel: Identifiable, Equatable {
    let id: String
    let name: String
    let imageUrl: String

    init(superhero: ApiNetwork.Superhero) {
        self.id = superhero.id
        self.name = superhero.name
        self.imageUrl = superhero.image.url
    }
    
    static func == (lhs: SuperheroViewModel, rhs: SuperheroViewModel) -> Bool {
            return lhs.id == rhs.id
        }
}


