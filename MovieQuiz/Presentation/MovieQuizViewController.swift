import UIKit


final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLable: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
//    private let questionsAmount: Int = 10
//    private var questionFactory: QuestionFactory?
    private var currentQuestion: QuizQuestion?
//    private var currentQuestionIndex = 0
//    private var correctAnswers = 0
    private var alertPresenter: ResultAlertPresenter?
    private var statisticServie: StatisticServiceProtocol?
//    private var presenter = MovieQuizPresenter()
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = ResultAlertPresenter(viewController: self)
        statisticServie = StatisticService()
        showLoadingIndicator()
        presenter.questionFactory?.loadData()
//        presenter.viewController = self
    }
    
//    // MARK: - QuestionFactoryDelegate
//    
//    func didReceiveNextQuestion(question: QuizQuestion?) {
//        presenter.didReceiveNextQuestion(question: question)
//    }
//    
//    func didLoadDataFromServer() {
//        activityIndicator.isHidden = true
//        questionFactory?.requestNextQuestion()
//    }
//    
//    func didFailToLoadData(with error: Error) {
//        showNetworkError(message: error.localizedDescription)
//    }
    
    // MARK: - Private functions
    
//    private func convert(model: QuizQuestion) -> QuizStepViewModel {
//        let questionStep = QuizStepViewModel(
//            image: UIImage(data: model.image) ?? UIImage(),
//            question: model.text,
//            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
//        )
//        return questionStep
//    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLable.text = step.question
    }
    
//    func showAnswerResult(isCorrect: Bool) {
//        imageView.layer.masksToBounds = true
//        imageView.layer.borderWidth = 10
//        imageView.layer.cornerRadius = 15
//        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
//        presenter.didAnswer(isCorrectAnswer: isCorrect)
//        yesButton.isEnabled = false
//        noButton.isEnabled = false
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
//            guard let self = self else { return }
//            
////            self.presenter.correctAnswers = self.correctAnswers
////            self.presenter.questionFactory = self.questionFactory
//            self.presenter.showNextQuestionOrResults()
//            self.imageView.layer.borderWidth = 0
//            self.yesButton.isEnabled = true
//            self.noButton.isEnabled = true
//        }
//    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }
    
    func hideImageBorder() {
        imageView.layer.borderWidth = 0
    }
    
    
    
//    private func showNextQuestionOrResults() {
//        if presenter.isLastQuestion() {
//            show()
//        } else {
//            presenter.switchToNextQuestion()
//            self.questionFactory?.requestNextQuestion()
//        }
//    }
    
    func show() {
        
        statisticServie?.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        
        guard let bestGame = statisticServie?.bestGame, let statService = statisticServie else {
            print("Error")
            return
        }
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: """
                    Ваш результат: \(presenter.correctAnswers)/\(presenter.questionsAmount)
                    Колличество сыгранных квизов: \(statService.gamesCount)
                    Рекорд: \(bestGame.correct)/\(bestGame.total) \(bestGame.date.dateTimeString)
                    Средняя точность: \(String(format: "%.2f", statService.totalAccuracy))%
                    """,
            buttonText: "Сыграть еще раз",
            buttonAction: { [weak self] in
                self?.presenter.restartGame()
//                self?.correctAnswers = 0
//                self?.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.show(alertModel: alertModel)
    }
    
    func showLoadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
            activityIndicator.isHidden = true
        }
    
    func showNetworkError(message: String) {
        
        activityIndicator.isHidden = true
        
        let model = AlertModel(
            title: "Ошибка",
            message: message,
            buttonText: "Попробовать еще раз") { [weak self] in
                guard let self = self else { return }
                
                self.presenter.restartGame()
//                self.correctAnswers = 0
                
                self.showLoadingIndicator()
                self.presenter.questionFactory?.loadData()
            }
        alertPresenter?.show(alertModel: model)
    }
    
    // MARK: - Actions
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
    }
}
