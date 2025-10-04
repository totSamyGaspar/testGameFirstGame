//
//  ScoreRecords.swift
//  TestGame
//
//  Created by Edward Gasparian on 04.10.2025.
//

import SwiftUI

struct ScoreRecords: View {
    @State private var scores: [Int] = []
    
    var bestScore: Int {
        scores.max() ?? 0
    }
    
    var body: some View {
        VStack {
            Text("High Scores")
                .font(.title)
                .bold()
            List {
                ForEach(Array(scores.prefix(10).enumerated()), id: \.offset) { index, score in
                    HStack {
                        Text("Game \(index + 1)")
                            .frame(width: 80, alignment: .leading)
                        Spacer()
                        Text("\(score)")
                            .fontWeight(score == bestScore ? .bold : .regular)
                            .foregroundColor(score == bestScore ? .yellow : .primary)
                            .frame(width: 80, alignment: .trailing)
                    }
                }
            }
            Spacer()
        }
        .padding()
        .onAppear {
            loadScores()
        }
    }
    private func loadScores() {
        scores = UserDefaults.standard.array(forKey: "scores") as? [Int] ?? []
    }
}

#Preview {
    ScoreRecords()
}
