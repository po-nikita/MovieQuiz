import Foundation
import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    let statisticService: StatisticServiceProtocol!
    var questionFactory: QuestionFactoryProtocol?
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewControllerProtocol?
    
    let questionAmount: Int = 10
    var currentQuestionIndex: Int = 0
    var correctAnswers = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel{
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionAmount)")
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    func didFailToLoadData(with error: any Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
            self?.viewController?.resetUIState()
        }
    }
    func makeResultMessage() -> String {
        statisticService?.store(correct: correctAnswers, total: questionAmount)
            let bestGame = statisticService.bestGame
            let totalGames = statisticService.gamesCount
            let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
            
            let message = [
                "Ваш результат: \(correctAnswers)/\(questionAmount)",
                "Количество сыгранных квизов: \(totalGames)",
                "Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))",
                "Средняя точность: \(accuracy)%"
            ].joined(separator: "\n")
            
            return message
    }
        func isLastQuestion() -> Bool {
            currentQuestionIndex == questionAmount - 1
        }
        
        func resetQuestionIndex(){
            currentQuestionIndex = 0
        }
        
        func switchToNextQuestion(){
            currentQuestionIndex += 1
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
                let text = correctAnswers == self.questionAmount ?
                "Поздравляем, вы ответили на 10 из 10!" :
                "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"

                let viewModel = QuizResultsViewModel(
                    title: "Этот раунд окончен!",
                    text: text,
                    buttonText: "Сыграть ещё раз")
                    viewController?.show(quiz: viewModel)
            } else {
                self.switchToNextQuestion()
                questionFactory?.requestNextQuestion()
            }
        }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        if isCorrect{
            correctAnswers += 1
        }
            viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.proceedToNextQuestionOrResults()
            }
        }
    
        func restartGame() {
            correctAnswers = 0
            currentQuestionIndex = 0
            questionFactory?.requestNextQuestion()
            
        }
        
    }
