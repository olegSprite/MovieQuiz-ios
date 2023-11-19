//
//  Statistic.swift
//  MovieQuiz
//
//  Created by Олег Спиридонов on 19.11.2023.
//

import Foundation

final class Statistic {
    
    private enum Keys: String {
        case correct, total, bestGame, gemesCount
    }
    
    private let userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults) {
        self.userDefaults = userDefaults
    }
}

extension Statistic: StatisticProtocol {
    
    var gameCount: Int {
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rowValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rowValue)
        }
    }
    
    func store(correct correst: Int, total: Int) {
        
    }
}

