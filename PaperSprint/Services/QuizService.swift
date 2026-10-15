import Foundation
import Observation

/// One checked answer per question. Scores are derived from records, never incremented by button taps.
@Observable
final class QuizService {
    let attemptID = UUID()
    let questions: [Question]
    private(set) var index = 0
    private(set) var selectedIndex: Int?
    private(set) var records: [AnswerRecord] = []
    private(set) var isChecked = false
    private(set) var isFinished = false
    private(set) var finishedAt: Date?
    let startedAt: Date
    init(questions: [Question], startedAt: Date = .now) {
        self.questions = questions.filter(QuizRules.valid)
        self.startedAt = startedAt
    }
    var current: Question? { questions.indices.contains(index) ? questions[index] : nil }
    var correctCount: Int { records.filter(\.isCorrect).count }
    var score: Double { QuizRules.percentage(correct: correctCount, total: questions.count) }
    var duration: TimeInterval { max(0, (finishedAt ?? .now).timeIntervalSince(startedAt)) }
    var progress: Double { questions.isEmpty ? 0 : Double(records.count) / Double(questions.count) }

    func select(_ option: Int) {
        guard !isChecked, !isFinished, let question = current, question.options.indices.contains(option) else { return }
        selectedIndex = option
    }
    func check() {
        guard !isChecked, !isFinished, let question = current, let choice = selectedIndex else { return }
        records.append(AnswerRecord(id: question.id, questionText: question.questionText,
            options: question.options, selectedIndex: choice, correctIndex: question.correctAnswerIndex,
            explanation: question.explanation))
        isChecked = true
    }
    func advance(now: Date = .now) {
        guard isChecked, !isFinished else { return }
        if index + 1 == questions.count {
            finishedAt = now
            isFinished = true
        } else {
            index += 1
            selectedIndex = nil
            isChecked = false
        }
    }
}
