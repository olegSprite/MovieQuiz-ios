import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show()
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var counterLabel: UILabel!
    @IBOutlet private var textLable: UILabel!
    @IBOutlet private var yesButton: UIButton!
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: ResultAlertPresenter?
    private var statisticServie: StatisticServiceProtocol?
    private var presenter: MovieQuizPresenter!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = ResultAlertPresenter(viewController: self)
        statisticServie = StatisticService()
        showLoadingIndicator()
        presenter.questionFactory?.loadData()
    }
    
    // MARK: - Functions
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLable.text = step.question
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func hideImageBorder() {
        imageView.layer.borderWidth = 0
    }
    
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
