//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Олег Спиридонов on 14.12.2023.
//

import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var correctAnswers = 0
    var questionFactory: QuestionFactory?
    
    init(viewController: MovieQuizViewController) {
            self.viewController = viewController
            
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            questionFactory?.loadData()
            viewController.showLoadingIndicator()
        }
    
    // MARK: - Functions
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
        
        func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
        }
        
        func restartGame() {
            currentQuestionIndex = 0
            correctAnswers = 0
            questionFactory?.requestNextQuestion()
        }
        
        func switchToNextQuestion() {
            currentQuestionIndex += 1
        }
        
        func didAnswer(isCorrectAnswer: Bool) {
            if isCorrectAnswer { correctAnswers += 1 }
        }
        
        func convert(model: QuizQuestion) -> QuizStepViewModel {
            let questionStep = QuizStepViewModel(
                image: UIImage(data: model.image) ?? UIImage(),
                question: model.text,
                questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
            )
            return questionStep
        }
        
        func yesButtonClicked() {
            didAnswer(isYes: true)
        }
        
        func noButtonClicked() {
            didAnswer(isYes: false)
        }
        
        func didAnswer(isYes: Bool) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            
            let givenAnswer = isYes
            
            viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
        
//        func didReceiveNextQuestion(question: QuizQuestion?) {
//            
//            guard let question = question else {
//                return
//            }
//            currentQuestion = question
//            let viewModel = convert(model: question)
//            DispatchQueue.main.async { [weak self] in
//                self?.viewController?.show(quiz: viewModel)
//            }
//        }
        
        func showNextQuestionOrResults() {
            if self.isLastQuestion() {
                viewController?.show()
            } else {
                self.switchToNextQuestion()
                self.questionFactory?.requestNextQuestion()
            }
        }
    }
