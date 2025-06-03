import Foundation

struct GameResult {
    let correct: Int // правильные ответы
    let total: Int // кол-во вопросов в раунде
    let date: Date // дата
    
    func isBetterThan(_ another: GameResult) -> Bool {
        correct > another.correct
    }
}
