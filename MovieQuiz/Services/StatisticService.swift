import Foundation

class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
        case total
        case totalQuestion
        case date
        case totalCorrectAnswer
    }
    
    var totalQuestions: Int {
        get {
            storage.integer(forKey: Keys.totalQuestion.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestion.rawValue)
        }
    }
    
    var gamesCount: Int {// счетчик сыгранных игр
        get{
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        let total = totalQuestions
        guard total > 0 else { return 0.0}
        return (Double(totalCorrectAnswer) / Double(total) * 100)
    }
    private var totalCorrectAnswer: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswer.rawValue)
        }
        set{
            storage.set(newValue, forKey: Keys.totalCorrectAnswer.rawValue)
        }
    }
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        totalCorrectAnswer += count
        totalQuestions += amount
        
        let currentGame = GameResult(correct: count, total: amount, date: Date())
        if currentGame.isBetterThan(bestGame){
            bestGame = currentGame
        }
    }
    
    
}
