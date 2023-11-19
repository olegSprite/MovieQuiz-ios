//
//  BestGame.swift
//  MovieQuiz
//
//  Created by Олег Спиридонов on 19.11.2023.
//

import Foundation

struct BestGame {
    let correct: Int
    let total: Int
    let date: Date
}

extension BestGame: Comparable {
    private var caccuracy: Double {
        guard total != 0 else {
            return 0
        }
        return Double(correct / total)
    }
    static func < (lhs: BestGame, rhs: BestGame) -> Bool {
        lhs.correct < rhs.correct
    }
}
