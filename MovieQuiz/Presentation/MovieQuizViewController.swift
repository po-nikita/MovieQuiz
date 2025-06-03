import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    private var questionAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter!
    private var currentQuestionIndex = 0
    private var correctAnswer = 0
    private var statisticService: StatisticServiceProtocol?
    
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else{
            return
        }
        let givenAnswer = false
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = true
        
        noButton.isEnabled = false
        yesButton.isEnabled = false
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel{
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
        return questionStep
    }
    
    private func show(quiz step: QuizStepViewModel){
        imageView.image = step.image
        imageView.layer.cornerRadius = 20
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool){
        if isCorrect{
            correctAnswer += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){[weak self] in
            guard let self = self else {return}
            self.showNextQuestionOrResult()
        }
    }
    
    private func showNextQuestionOrResult(){
        noButton.isEnabled = true
        yesButton.isEnabled = true
        
        imageView.layer.borderWidth = 0
        imageView.layer.borderColor = nil
        
        if currentQuestionIndex == questionAmount - 1 {
            statisticService?.store(correct: correctAnswer, total: questionAmount)
            
            if let statisticService = statisticService {
                let bestGame = statisticService.bestGame
                let totalGames = statisticService.gamesCount
                let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
                
                let text = """
                Ваш результат: \(correctAnswer)/\(questionAmount)
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
                currentQuestionIndex += 1
                questionFactory?.requestNextQuestion()
            }
        }
    
    private func show(quiz result: QuizResultsViewModel) {
       
        let alertModel = AlertModel(
            title: result.title,
            message: result.text,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self else {return}
                self.correctAnswer = 0
                self.currentQuestionIndex = 0
                self.questionFactory?.requestNextQuestion()
            })
        alertPresenter?.show(alert: alertModel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(viewController: self)
        questionFactory = QuestionFactory(delegate: self)
        statisticService = StatisticService()
        
        if let firstQuestion = questionFactory?.requestNextQuestion(){
            questionFactory?.requestNextQuestion()
        }
    }
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
}
