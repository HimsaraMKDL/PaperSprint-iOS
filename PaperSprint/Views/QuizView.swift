import SwiftUI
import SwiftData

struct QuizView: View {
    let subject: Subject
    let lesson: Lesson
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var session: QuizService
    @State private var savedResult: QuizResult?
    @State private var saveError: String?
    @State private var showExit = false
    init(subject: Subject, lesson: Lesson) {
        self.subject = subject
        self.lesson = lesson
        _session = State(initialValue: QuizService(questions: LearningCatalog.questions(for: lesson)))
    }
    var body: some View {
        ScrollViewReader { proxy in
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                if session.isFinished {
                    completedView
                } else if let question = session.current {
                    HStack {
                        Text("QUESTION \(session.index + 1) OF \(session.questions.count)").font(.caption.bold()).foregroundStyle(Theme.accent)
                        Spacer()
                        Label("\(session.correctCount)", systemImage: "checkmark.circle").font(.subheadline).foregroundStyle(Theme.teal)
                    }
                    ProgressView(value: session.progress).accessibilityLabel("Quiz progress")
                    Text(lesson.title).font(.subheadline).foregroundStyle(.secondary)
                    Text(question.questionText).font(.title2.bold()).accessibilityIdentifier("questionText")
                    VStack(spacing: 12) {
                        ForEach(question.options.indices, id: \.self) { index in
                            AnswerOptionView(text: question.options[index], index: index,
                                isSelected: session.selectedIndex == index, isChecked: session.isChecked,
                                correctIndex: question.correctAnswerIndex) {
                                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.15)) { session.select(index) }
                                }
                        }
                    }
                    if session.isChecked {
                        VStack(alignment: .leading, spacing: 10) {
                            Label(session.records.last?.isCorrect == true ? "That's correct" : "Keep learning",
                                  systemImage: session.records.last?.isCorrect == true ? "checkmark.circle.fill" : "lightbulb.fill")
                                .font(.headline).foregroundStyle(session.records.last?.isCorrect == true ? Theme.teal : Theme.accent)
                            Text(question.explanation).font(.body)
                        }.paperCard().transition(.opacity)
                        Button(session.index + 1 == session.questions.count ? "See results" : "Next question") {
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) { session.advance() }
                            if session.isFinished { saveAttempt() }
                        }.buttonStyle(.borderedProminent).accessibilityIdentifier("nextQuestion")
                    } else {
                        Button("Check answer") {
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) { session.check() }
                        }.buttonStyle(.borderedProminent).disabled(session.selectedIndex == nil)
                            .accessibilityIdentifier("checkAnswer")
                    }
                    Text("Choose one answer, then check it. Each question can be scored only once.")
                        .font(.caption).foregroundStyle(.secondary)
                } else {
                    ContentUnavailableView("No questions available", systemImage: "questionmark.folder",
                        description: Text("Return to Lessons and choose another lesson."))
                }
            }.padding(22).frame(maxWidth: 800).frame(maxWidth: .infinity).id("quizTop")
        }
        .onChange(of: session.index) { _, _ in proxy.scrollTo("quizTop", anchor: .top) }
        .onChange(of: session.isFinished) { _, _ in proxy.scrollTo("quizTop", anchor: .top) }
        }
        .background(Theme.background).navigationTitle(session.isFinished ? "Your results" : "Practice quiz")
        .navigationBarTitleDisplayMode(.inline).navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(session.isFinished ? "Done" : "Close") {
                    if session.isFinished || session.records.isEmpty && session.selectedIndex == nil { dismiss() }
                    else { showExit = true }
                }
            }
        }
        .confirmationDialog("Leave this quiz?", isPresented: $showExit, titleVisibility: .visible) {
            Button("Leave quiz", role: .destructive) { dismiss() }
        } message: { Text("This unfinished attempt will not be saved.") }
    }
    private var completedView: some View {
        VStack(alignment: .leading, spacing: 24) {
            ScoreRing(score: session.score).frame(maxWidth: .infinity).padding(.vertical, 12)
            Text(session.score >= 80 ? "A strong sprint." : "Every attempt moves you forward.").font(.title.bold())
            Text("\(session.correctCount) of \(session.questions.count) correct · \(Int(session.duration)) seconds")
                .font(.headline).foregroundStyle(.secondary).accessibilityIdentifier("resultScore")
            Text(lesson.title).font(.subheadline).foregroundStyle(.secondary)
            if savedResult != nil {
                Label("Saved to your results", systemImage: "checkmark.circle.fill").foregroundStyle(Theme.teal)
                    .accessibilityIdentifier("savedResult")
            } else if let saveError {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Result not saved", systemImage: "exclamationmark.triangle").foregroundStyle(.red)
                    Text(saveError).font(.caption)
                    Button("Retry saving") { saveAttempt() }
                }.paperCard()
            }
            Button("Try this quiz again", systemImage: "arrow.clockwise") {
                session = QuizService(questions: LearningCatalog.questions(for: lesson))
                savedResult = nil; saveError = nil
            }.buttonStyle(.borderedProminent)
            NavigationLink {
                AnswerReviewView(records: session.records)
            } label: {
                Label("Review your answers", systemImage: "text.magnifyingglass")
            }.buttonStyle(.bordered)
            Text("Results reflect this five-question practice set, not an official grade.").font(.caption).foregroundStyle(.secondary)
        }
    }
    private func saveAttempt() {
        guard session.isFinished, savedResult == nil else { return }
        do {
            let id = session.attemptID
            let descriptor = FetchDescriptor<QuizResult>(predicate: #Predicate { $0.id == id })
            if let existing = try context.fetch(descriptor).first { savedResult = existing; saveError = nil; return }
            let result = try QuizResult(id: id, subject: subject, lesson: lesson,
                records: session.records, duration: session.duration)
            context.insert(result)
            do { try context.save() } catch { context.rollback(); throw error }
            savedResult = result; saveError = nil
        } catch { saveError = error.localizedDescription }
    }
}
