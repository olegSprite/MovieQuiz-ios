//
//  AlertPresetor.swift
//  MovieQuiz
//
//  Created by Олег Спиридонов on 19.11.2023.
//

import Foundation
import UIKit

final class AlertPresetor {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController? = nil) {
        self.viewController = viewController
    }
    
    func show(alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            
            alertModel.buttonAction()
        }
        alert.addAction(action)
        viewController?.present(alert, animated: true)
    }
    
}
