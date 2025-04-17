//
//  SuperheroDetail.swift
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

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                WebImage(url: URL(string: viewModel.imageUrl))
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                    .cornerRadius(20)

                Text(viewModel.name)
                    .font(.largeTitle.bold())
                    .padding(.top)

                Chart {
                    ForEach(viewModel.powerstats.sorted(by: { $0.key < $1.key }), id: \.key) { stat, value in
                        if let intValue = Int(value) {
                            BarMark(
                                x: .value("Stat", stat),
                                y: .value("Value", intValue)
                            )
                        }
                    }
                }
                .frame(height: 200)
                .padding()
            }
            .padding()
        }
        .navigationTitle(viewModel.name)
        .onAppear {
            Task {
                await viewModel.fetchHero(id: id)
            }
        }
    }
}


