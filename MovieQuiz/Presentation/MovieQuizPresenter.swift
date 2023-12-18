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
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController as? MovieQuizViewController
            
            questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
            questionFactory?.loadData()
            viewController.showLoadingIndicator()
        }
    
    // MARK: - QuestionFactoryDelegate
    
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
        
    private func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
        }
        
    func restartGame() {
            currentQuestionIndex = 0
            correctAnswers = 0
            questionFactory?.requestNextQuestion()
        }
        
    private func switchToNextQuestion() {
            currentQuestionIndex += 1
        }
        
    private func didAnswer(isCorrectAnswer: Bool) {
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
        
    private func didAnswer(isYes: Bool) {
            guard let currentQuestion = currentQuestion else {
                return
            }
            
            let givenAnswer = isYes
            
            proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
        }
        
    private func proceedToNextQuestionOrResults() {
            if self.isLastQuestion() {
                viewController?.show()
            } else {
                self.switchToNextQuestion()
                self.questionFactory?.requestNextQuestion()
            }
        }
    
    private func proceedWithAnswer(isCorrect: Bool) {
            didAnswer(isCorrectAnswer: isCorrect)
            
            viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.proceedToNextQuestionOrResults()
                self.viewController?.hideImageBorder()
            }
        }
    }
