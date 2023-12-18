import Foundation

final class QuestionFactory: QuestionFactoryProtocol {
    
    private var movies: [MostPopularMovie] = []
    
    weak var delegate: QuestionFactoryDelegate?
    private let moviesLoader: MoviesLoading
    
    init(moviesLoader: MoviesLoading, delegate: QuestionFactoryDelegate?) {
        self.moviesLoader = moviesLoader
        self.delegate = delegate
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
            }
            
            let rating = Float(movie.rating) ?? 0
            let randomNumber = Int(arc4random_uniform(5)) + 1
            let text: String
            let correctAnswer: Bool
            
            switch randomNumber {
            case 1:
                text = "Рейтинг этого фильма больше чем 3?"
                correctAnswer = rating > 3
            case 2:
                text = "Рейтинг этого фильма больше чем 6?"
                correctAnswer = rating > 6
            case 3:
                text = "Рейтинг этого фильма больше чем 8?"
                correctAnswer = rating > 8
            case 4:
                text = "Рейтинг этого фильма меньше чем 7?"
                correctAnswer = rating < 7
            default:
                text = "Рейтинг этого фильма меньше чем 6?"
                correctAnswer = rating < 6
            }
            
            let question = QuizQuestion(image: imageData,
                                        text: text,
                                        correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func loadData() {
        moviesLoader.loadMovies { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let mostPopularMovies):
                    self.movies = mostPopularMovies.items
                    self.delegate?.didLoadDataFromServer()
                case .failure(let error):
                    self.delegate?.didFailToLoadData(with: error)
                }
            }
        }
    }
}
