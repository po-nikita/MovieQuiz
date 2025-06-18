import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet private var noButton: UIButton!
    @IBOutlet private var yesButton: UIButton!
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var textLabel: UILabel!
    @IBOutlet private var counterLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var alertPresenter: AlertPresenter!
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
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
            imageView.layer.masksToBounds = true
            imageView.layer.borderWidth = 8
            imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultMessage()
        
        let alert = UIAlertController(
                    title: result.title,
                    message: message,
                    preferredStyle: .alert)
                    
        let action = UIAlertAction(title: result.buttonText, style: .default) { [weak self] _ in
                        guard let self = self else { return }
                        
                        self.presenter.restartGame()
                }
        alert.addAction(action)
        self.present(alert,animated: true, completion: nil)
        }
    func resetUIState(){
        yesButton.isEnabled = true
        noButton.isEnabled = true
        imageView.layer.borderWidth = 0
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        alertPresenter = AlertPresenter(viewController: self)
        presenter = MovieQuizPresenter(viewController: self)
    }
    
}
