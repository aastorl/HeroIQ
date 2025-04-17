//
//  ApiNetwork.swift
//  HeroIQ
//
//  Created by Astor Ludueña  on 04/04/2025.
//

import Foundation

class ApiNetwork {
    
    struct Wrapper: Codable {
        let response: String
        let results: [Superhero]
    }
    
    struct Superhero: Codable, Identifiable {
        let id: String
        let name: String
        let image: ImageSuperhero
    }
    struct SuperheroDetailed: Codable{
        let id: String
        let name: String
        let image: ImageSuperhero
        let powerstats: Powerstats
        let biography: Biography
    }
    
    struct Powerstats: Codable{
        let intelligence: String
        let strength: String
        let speed: String
        let durability: String
        let power: String
        let combat: String
    }
    
    struct ImageSuperhero: Codable{
        let url: String
    }
    
    struct Biography: Codable{
        let alignment: String
        let publisher: String
        let aliases: [String]
        let fullName: String
        
        enum CodingKeys: String, CodingKey { // full-name from JSON
            case fullName = "full-name"
            case alignment = "alignment"
            case publisher = "publisher"
            case aliases = "aliases"
        }
    }
    
    static func getHeroesByQuery(query: String) async throws -> Wrapper {
            let url = URL(string: "https://superheroapi.com/api/2dc85729f7460e4ee9ddbd9f279ce327/search/\(query)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(Wrapper.self, from: data)
        }

        static func getHeroById(id: String) async throws -> SuperheroDetailed {
            let url = URL(string: "https://superheroapi.com/api/2dc85729f7460e4ee9ddbd9f279ce327/\(id)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(SuperheroDetailed.self, from: data)
    }
}
