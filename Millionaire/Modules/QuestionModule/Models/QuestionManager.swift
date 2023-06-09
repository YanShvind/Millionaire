import Foundation

/// Data Manager to fetch any questions from QuestionDataBase
final class QuestionManager {
    
    static let shared = QuestionManager()
    
    enum HelpType {
        case hall
        case possibleError
    }
    
    var isTheFirstGame = true
    var currentTotalSum = 0
    var currentUsername: String = "Guest"
    
    private var lowQuestions = QuestionDataBase.shared.fetchRandomLowQuestions()
    private var mediumQuestions = QuestionDataBase.shared.fetchRandomMediumQuestions()
    private var hardQuestions = QuestionDataBase.shared.fetchRandomHardQuestions()
    
    private (set) var currentQuestion: Question?
    private (set) var currentNumberQuestion = 0
    private (set) var currentQuestionCost = 100
    
    private let totalQuestions = 15
    private let countOfAnswersInQuestion = 4
    private var currentQuestionIndex = 0
    
    private var currentTypeQuestion: QuestionType = .low
    
    //States for help buttons
    private (set) var isFiftyEnabled: Bool = true
    private (set) var isHallEnabled: Bool = true
    private (set) var isPossibleErrorEnebled: Bool = true
    
    func newGame() {
        lowQuestions = QuestionDataBase.shared.fetchRandomLowQuestions()
        mediumQuestions = QuestionDataBase.shared.fetchRandomMediumQuestions()
        hardQuestions = QuestionDataBase.shared.fetchRandomHardQuestions()
        
        currentNumberQuestion = 0
        currentQuestionCost = 100
        currentQuestionIndex = 0
        currentTypeQuestion = .low
        isHallEnabled = true
        isFiftyEnabled = true
        isPossibleErrorEnebled = true
        currentTotalSum = 0
    }
    
    // MARK: - SaveToScore
    
    func saveIfLoseGame() {
        var score = 0
        switch currentTotalSum {
        case 1000...16000:
            score = 1000
            let score = ScoreModel(name: currentUsername, sum: score)
            ScoreManager.shared.create(score: score)
        case 32000...500_000:
            score = 32000
            let score = ScoreModel(name: currentUsername, sum: score)
            ScoreManager.shared.create(score: score)
        case 1000000:
            score = 1000000
            let score = ScoreModel(name: currentUsername, sum: score)
            ScoreManager.shared.create(score: score)
        default:
            break
        }
        newGame()
    }
    
    // MARK: - Help
    
    func safeMoney() {
        if currentTotalSum >= 100 {
            let score = ScoreModel(name: currentUsername, sum: currentTotalSum)
            ScoreManager.shared.create(score: score)
            newGame()
        }
    }
    
    func userHelp(typeOfHelp: HelpType) {
        switch typeOfHelp {
        case .hall:
            useHallHelp()
        case .possibleError:
            usePossibleError()
        }
    }
    
    // Func to use callToFriend help
    private func usePossibleError() {
        guard let currentQuestion = currentQuestion,
              isPossibleErrorEnebled else {
            return
        }
        
        var answers: [[Bool:String]] = []
        
        let currentAnswers = [currentQuestion.answers.aAnswer, currentQuestion.answers.bAnswer,
                              currentQuestion.answers.cAnswer, currentQuestion.answers.dAnswer].shuffled()
        
        for answer in currentAnswers {
            if answer[true] != nil {
                answers.append(answer)
            } else {
                while answers.count < countOfAnswersInQuestion / 2 {
                    answers.append(answer)
                }
            }
        }
        isPossibleErrorEnebled = false
    }
    
    // Func to use hall help
    private func useHallHelp() {
        isHallEnabled = false
    }
    
    // Func to use 50 percent help
    func useFiftyHelp() -> [Int]? {
        guard let currentQuestion = currentQuestion,
              isFiftyEnabled else {
            return nil
        }
        var tags = [Int]()
        
        let currentAnswers = [currentQuestion.answers.aAnswer, currentQuestion.answers.bAnswer,
                              currentQuestion.answers.cAnswer, currentQuestion.answers.dAnswer]
        
        for (i, answer) in currentAnswers.enumerated() {
            if answer[true] == nil {
                tags.append(i + 1)
            }
        }
        isFiftyEnabled = false
        return tags
    }
    
    // MARK: - Questions
    
    // Func to fetch new request for different levels
    func fetchNewQuestion() -> Question? {
        updateCurrentQuestion()
        return currentQuestion
    }
    
    // Func to check on the right answer
    func checkAnswer() -> Int {
        if currentQuestion?.answers.aAnswer[true] != nil {
            return 1
        } else if currentQuestion?.answers.bAnswer[true] != nil {
            return 2
        } else if currentQuestion?.answers.cAnswer[true] != nil {
            return 3
        } else {
            return 4
        }
    }
    
    //
    private func updateCurrentQuestionCost(numberOrQuestion: Int) {
        switch numberOrQuestion {
        case 1:
            currentQuestionCost = 100
        case 2:
            currentQuestionCost = 200
            currentTotalSum = 100
        case 3:
            currentQuestionCost = 300
            currentTotalSum = 200
        case 4:
            currentQuestionCost = 500
            currentTotalSum = 300
        case 5:
            currentQuestionCost = 1000
            currentTotalSum = 500
        case 6:
            currentQuestionCost = 2000
            currentTotalSum = 1000
        case 7:
            currentQuestionCost = 4000
            currentTotalSum = 2000
        case 8:
            currentQuestionCost = 8000
            currentTotalSum = 4000
        case 9:
            currentQuestionCost = 16_000
            currentTotalSum = 8000
        case 10:
            currentQuestionCost = 32_000
            currentTotalSum = 16_000
        case 11:
            currentQuestionCost = 64_000
            currentTotalSum = 32_000
        case 12:
            currentQuestionCost = 125_000
            currentTotalSum = 64_000
        case 13:
            currentQuestionCost = 250_000
            currentTotalSum = 125_000
        case 14:
            currentQuestionCost = 500_000
            currentTotalSum = 250_000
        case 15:
            currentQuestionCost = 1_000_000
            currentTotalSum = 500_000
        default:
            currentQuestionCost = 0
        }
    }
    
    // Private func to generate random quesion
    private func updateCurrentQuestion() {
        let totalForEach = totalQuestions / 3
        
        if totalQuestions % 3 != 0 {
            return
        }
        
        if lowQuestions.count < totalForEach || mediumQuestions.count < totalForEach || hardQuestions.count < totalForEach {
            return
        }
        
        currentNumberQuestion += 1
        
        updateCurrentQuestionCost(numberOrQuestion: currentNumberQuestion)
        
        switch currentTypeQuestion {
        case .low:
            if currentQuestionIndex < totalForEach {
                currentQuestion = lowQuestions[currentQuestionIndex]
                currentQuestionIndex += 1
            } else {
                currentTypeQuestion = .medium
                currentQuestionIndex = 0
                currentQuestion = mediumQuestions[currentQuestionIndex]
                currentQuestionIndex += 1
            }
        case .medium:
            if currentQuestionIndex < totalForEach {
                currentQuestion = mediumQuestions[currentQuestionIndex]
                currentQuestionIndex += 1
            } else {
                currentTypeQuestion = .hard
                currentQuestionIndex = 0
                currentQuestion = hardQuestions[currentQuestionIndex]
                currentQuestionIndex += 1
            }
        case .hard:
            if currentQuestionIndex < totalForEach {
                currentQuestion = hardQuestions[currentQuestionIndex]
                currentQuestionIndex += 1
            }
        }
    }
}
