//
//  BestGame.swift
//  MovieQuiz
//
//  Created by Олег Спиридонов on 19.11.2023.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameRecord) -> Bool  {
        correct > another.correct
    }
}

