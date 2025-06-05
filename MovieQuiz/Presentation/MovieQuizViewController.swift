import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenter!
    private var statisticService: StatisticServiceProtocol?
    private var presenter: MovieQuizPresenter!

    
    @IBAction private func noButtonClicked(_ sender: Any) {
        presenter.noButtonClicked()
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        presenter.yesButtonClicked()
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
    }
    
     func showLoadingIndicator(){
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
     func hideLoadingIndicator(){
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
     func showNetworkError(message: String){
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка", message: message, buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else {return}
        
            self.presenter.resetQuestionIndex()
            self.presenter.restartGame()
        }
        alertPresenter.show(alert: model)
    }
    
     func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        imageView.layer.cornerRadius = 20
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool){
        if isCorrect{
            presenter.correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                   guard let self = self else { return }
                   self.presenter.showNextQuestionOrResults()
            noButton.isEnabled = true
            yesButton.isEnabled = true
            
            imageView.layer.borderWidth = 0
            imageView.layer.borderColor = nil
               }
    }
    
   private func showNextQuestionOrResult(){
        
        if presenter.isLastQuestion() {
            statisticService?.store(correct: presenter.correctAnswers, total: presenter.questionAmount)
            
            if let statisticService = statisticService {
                let bestGame = statisticService.bestGame
                let totalGames = statisticService.gamesCount
                let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
                
                let text = """
                Ваш результат: \(presenter.correctAnswers)/\(presenter.questionAmount)
                Количество сыгранных квизов: \(totalGames)
                Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
                Средняя точность: \(accuracy)%
                """
                
                let viewModel = QuizResultsViewModel( // 2
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                
                show(quiz: viewModel) // 3
            }
            } else {
                presenter.switchToNextQuestion()
                presenter.restartGame()
            }
        }
    
    func show(quiz result: QuizResultsViewModel) {
        
        if let statisticService = statisticService {
            statisticService.store(correct: presenter.correctAnswers, total: presenter.questionAmount)
            
            let alertModel = AlertModel(
                title: result.title,
                message: result.text,
                buttonText: result.buttonText,
                completion: { [weak self] in
                    guard let self else {return}
                    self.presenter.restartGame()
                    self.presenter.resetQuestionIndex()
                })
            alertPresenter?.show(alert: alertModel)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter = MovieQuizPresenter(viewController: self)
        alertPresenter = AlertPresenter(viewController: self)
        statisticService = StatisticService()
        
        showLoadingIndicator()
    }
    
}
