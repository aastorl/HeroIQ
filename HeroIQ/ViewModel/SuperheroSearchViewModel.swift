//
//  SuperheroSearchViewModel.swift
//  HeroIQ
//
//  Created by Astor Ludueña  on 16/04/2025.
//

import Foundation

@MainActor
class SuperheroSearcherViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var results: [SuperheroViewModel] = []

    func search() async {
        do {
            let wrapper = try await ApiNetwork.getHeroesByQuery(query: searchText)
            results = wrapper.results.map { SuperheroViewModel(superhero: $0) }
        } catch {
            print("Error fetching heroes: \(error)")
        }
    }
}

