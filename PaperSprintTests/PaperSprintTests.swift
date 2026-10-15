import Foundation
import SwiftData
import Testing
import UIKit
@testable import PaperSprint

@MainActor
struct PaperSprintTests {
    private let subject = LearningCatalog.subjects[0]
    private let lesson = LearningCatalog.lessons[0]
    private var questions: [Question] { LearningCatalog.questions(for: lesson) }

    @Test func catalogHasValidUniqueQuestionsAndRelationships() {
        #expect(LearningCatalog.subjects.count == 3)
        #expect(LearningCatalog.lessons.count == 6)
        #expect(LearningCatalog.questions.count == 30)
        #expect(Set(LearningCatalog.questions.map(\.id)).count == LearningCatalog.questions.count)
        for question in LearningCatalog.questions {
            #expect(QuizRules.valid(question))
            #expect(LearningCatalog.lessons.contains { $0.id == question.lessonID })
        }
        for lesson in LearningCatalog.lessons {
            #expect(LearningCatalog.subjects.contains { $0.id == lesson.subjectID })
            #expect(LearningCatalog.questions(for: lesson).count == 5)
        }
    }
    @Test func perfectAttemptScores100() {
        let quiz = QuizService(questions: questions)
        for question in questions {
            quiz.select(question.correctAnswerIndex); quiz.check(); quiz.advance()
        }
        #expect(quiz.isFinished)
        #expect(quiz.correctCount == questions.count)
        #expect(quiz.score == 100)
        #expect(quiz.records.count == questions.count)
    }
    @Test func checkIsIdempotentAndAnswerCannotChangeAfterChecking() {
        let quiz = QuizService(questions: questions)
        let correct = questions[0].correctAnswerIndex
        quiz.select(correct); quiz.check(); quiz.check()
        quiz.select((correct + 1) % questions[0].options.count)
        #expect(quiz.records.count == 1)
        #expect(quiz.correctCount == 1)
        #expect(quiz.selectedIndex == correct)
    }
    @Test func cannotSkipUncheckedOrSelectInvalidIndex() {
        let quiz = QuizService(questions: questions)
        quiz.advance(); quiz.select(-1); quiz.select(100); quiz.check()
        #expect(quiz.index == 0)
        #expect(quiz.selectedIndex == nil)
        #expect(quiz.records.isEmpty)
    }
    @Test func wrongAnswersAndEmptyQuizAreSafe() {
        let quiz = QuizService(questions: questions)
        for question in questions {
            quiz.select((question.correctAnswerIndex + 1) % question.options.count)
            quiz.check(); quiz.advance()
        }
        #expect(quiz.isFinished && quiz.score == 0)
        let empty = QuizService(questions: [])
        empty.check(); empty.advance()
        #expect(empty.current == nil && empty.score == 0 && !empty.isFinished)
        #expect(QuizRules.percentage(correct: 5, total: 0) == 0)
        #expect(QuizRules.percentage(correct: 3, total: 5) == 60)
    }
    @Test func resultRoundTripAndDeletion() throws {
        let schema = Schema([QuizResult.self])
        let container = try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)])
        let context = ModelContext(container)
        let quiz = QuizService(questions: questions)
        for q in questions { quiz.select(q.correctAnswerIndex); quiz.check(); quiz.advance() }
        let result = try QuizResult(id: quiz.attemptID, subject: subject, lesson: lesson, records: quiz.records, duration: 20)
        context.insert(result); try context.save()
        let rows = try context.fetch(FetchDescriptor<QuizResult>())
        let fetched = try #require(rows.first)
        #expect(fetched.score == 100)
        #expect(fetched.records == quiz.records)
        context.delete(fetched); try context.save()
        #expect(try context.fetchCount(FetchDescriptor<QuizResult>()) == 0)
    }
    @Test func historySurvivesReopeningDiskStore() throws {
        let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: folder) }
        let url = folder.appendingPathComponent("history.store")
        let schema = Schema([QuizResult.self])
        let record = AnswerRecord(id: "sample", questionText: "Question?", options: ["A", "B"], selectedIndex: 1, correctIndex: 1, explanation: "B is correct.")
        func write() throws {
            let config = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
            let container = try ModelContainer(for: schema, configurations: [config])
            let context = ModelContext(container)
            context.insert(try QuizResult(id: UUID(), subject: subject, lesson: lesson, records: [record], duration: 12))
            try context.save()
        }
        try write()
        let config = ModelConfiguration(schema: schema, url: url, cloudKitDatabase: .none)
        let container = try ModelContainer(for: schema, configurations: [config])
        let rows = try ModelContext(container).fetch(FetchDescriptor<QuizResult>())
        let fetched = try #require(rows.first)
        #expect(fetched.correctAnswers == 1 && fetched.score == 100)
        #expect(fetched.records == [record])
    }
    @Test func bundledImageProducesRecognizedText() async throws {
        let image = try #require(UIImage(named: "SamplePaper"))
        let data = try #require(image.pngData())
        let response = try await OCRWorker().recognize(data: data)
        #expect(response.text.localizedCaseInsensitiveContains("Swift"))
        #expect(!response.previewData.isEmpty)
    }
}
