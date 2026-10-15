import SwiftUI
import SwiftData

struct ResultRow: View {
    let result: QuizResult
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(result.lessonTitle).font(.headline).foregroundStyle(.primary)
                Text(result.subjectName).font(.caption).foregroundStyle(Theme.accent)
                Text(result.date, format: .dateTime.month(.abbreviated).day().hour().minute())
                    .font(.caption).foregroundStyle(.secondary)
                Text("\(result.correctAnswers)/\(result.totalQuestions) correct").font(.caption).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
            Text("\(Int(result.score.rounded()))%").font(.title2.bold()).foregroundStyle(Theme.accent)
        }.paperCard()
    }
}
struct HistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \QuizResult.date, order: .reverse) private var results: [QuizResult]
    @State private var query = ""
    @State private var deletion: QuizResult?
    @State private var error: String?
    private var visible: [QuizResult] {
        results.filter { query.isEmpty || $0.lessonTitle.localizedCaseInsensitiveContains(query) || $0.subjectName.localizedCaseInsensitiveContains(query) }
    }
    var body: some View {
        List {
            if results.isEmpty {
                ContentUnavailableView("Your first sprint starts here", systemImage: "chart.bar",
                    description: Text("Complete a practice quiz. Your score and answer review will be saved automatically."))
            } else {
                Section("\(results.count) completed attempts") {
                    ForEach(visible) { result in
                        NavigationLink { SavedResultView(result: result) } label: { ResultRow(result: result) }
                            .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                            .swipeActions(allowsFullSwipe: false) {
                                Button("Delete", role: .destructive) { deletion = result }
                            }
                    }
                    if visible.isEmpty { ContentUnavailableView.search(text: query) }
                }
            }
        }.navigationTitle("Results").searchable(text: $query, prompt: "Search lesson or subject")
            .confirmationDialog("Delete this saved result?", isPresented: Binding(get: { deletion != nil }, set: { if !$0 { deletion = nil } }), titleVisibility: .visible) {
                Button("Delete result", role: .destructive) {
                    guard let deletion else { return }
                    context.delete(deletion)
                    do { try context.save() } catch { context.rollback(); self.error = error.localizedDescription }
                    self.deletion = nil
                }
            }
            .alert("Couldn't delete result", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
                Button("OK", role: .cancel) { error = nil }
            } message: { Text(error ?? "Please try again.") }
    }
}
struct SavedResultView: View {
    let result: QuizResult
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                ScoreRing(score: result.score).frame(maxWidth: .infinity).padding(.vertical)
                Text(result.lessonTitle).font(.largeTitle.bold())
                VStack(alignment: .leading, spacing: 14) {
                    LabeledContent("Subject", value: result.subjectName)
                    LabeledContent("Correct", value: "\(result.correctAnswers) / \(result.totalQuestions)")
                    LabeledContent("Time", value: "\(Int(result.duration)) seconds")
                    LabeledContent("Date", value: result.date.formatted(date: .abbreviated, time: .shortened))
                }.paperCard()
                NavigationLink {
                    AnswerReviewView(records: result.records)
                } label: {
                    Label("Review answers", systemImage: "text.magnifyingglass")
                }.buttonStyle(.borderedProminent)
            }.padding(22).frame(maxWidth: 800).frame(maxWidth: .infinity)
        }.background(Theme.background).navigationTitle("Saved result").navigationBarTitleDisplayMode(.inline)
    }
}
struct AnswerReviewView: View {
    let records: [AnswerRecord]
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Question \(index + 1) · \(record.isCorrect ? "Correct" : "Incorrect")",
                              systemImage: record.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.caption.bold()).foregroundStyle(record.isCorrect ? Theme.teal : .red)
                        Text(record.questionText).font(.headline)
                        if record.options.indices.contains(record.selectedIndex) {
                            Text("Your answer: \(record.options[record.selectedIndex])")
                        }
                        if record.options.indices.contains(record.correctIndex) {
                            Text("Correct answer: \(record.options[record.correctIndex])").foregroundStyle(Theme.teal)
                        }
                        Text(record.explanation).font(.subheadline).foregroundStyle(.secondary)
                    }.paperCard()
                }
                if records.isEmpty { ContentUnavailableView("No answer review available", systemImage: "doc.text") }
            }.padding(22).frame(maxWidth: 800).frame(maxWidth: .infinity)
        }.background(Theme.background).navigationTitle("Answer review").navigationBarTitleDisplayMode(.inline)
    }
}
