import Foundation
import SwiftData

struct Subject: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let subtitle: String
    let icon: String
}
struct Lesson: Identifiable, Hashable, Codable {
    let id: String
    let subjectID: String
    let title: String
    let minutes: Int
    let introduction: String
    let sections: [LessonSection]
}
struct LessonSection: Hashable, Codable {
    let heading: String
    let body: String
}
struct Question: Identifiable, Hashable, Codable {
    let id: String
    let lessonID: String
    let questionText: String
    let options: [String]
    let correctAnswerIndex: Int
    let explanation: String
}
struct AnswerRecord: Identifiable, Codable, Hashable {
    let id: String
    let questionText: String
    let options: [String]
    let selectedIndex: Int
    let correctIndex: Int
    let explanation: String
    var isCorrect: Bool { selectedIndex == correctIndex }
}

/// Keep an answer snapshot with every result so old attempts remain reviewable.
@Model
final class QuizResult {
    @Attribute(.unique) var id: UUID
    var date: Date
    var subjectID: String
    var subjectName: String
    var lessonID: String
    var lessonTitle: String
    var totalQuestions: Int
    var correctAnswers: Int
    var score: Double
    var duration: Double
    var reviewData: Data

    init(id: UUID, date: Date = .now, subject: Subject, lesson: Lesson,
         records: [AnswerRecord], duration: Double) throws {
        self.id = id
        self.date = date
        subjectID = subject.id
        subjectName = subject.name
        lessonID = lesson.id
        lessonTitle = lesson.title
        totalQuestions = records.count
        correctAnswers = records.filter(\.isCorrect).count
        score = QuizRules.percentage(correct: records.filter(\.isCorrect).count, total: records.count)
        self.duration = max(0, duration)
        reviewData = try JSONEncoder().encode(records)
    }
    var records: [AnswerRecord] { (try? JSONDecoder().decode([AnswerRecord].self, from: reviewData)) ?? [] }
}

enum QuizRules {
    static func percentage(correct: Int, total: Int) -> Double {
        guard total > 0 else { return 0 }
        return Double(min(max(correct, 0), total)) / Double(total) * 100
    }
    static func valid(_ question: Question) -> Bool {
        !question.questionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        && question.options.count >= 2
        && question.options.indices.contains(question.correctAnswerIndex)
        && question.options.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}
