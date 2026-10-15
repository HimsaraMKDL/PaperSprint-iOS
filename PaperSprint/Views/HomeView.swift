import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \QuizResult.date, order: .reverse) private var results: [QuizResult]
    @AppStorage("studentName") private var studentName = ""
    private var totalAnswers: Int { results.reduce(0) { $0 + $1.totalQuestions } }
    private var accuracy: Double {
        QuizRules.percentage(correct: results.reduce(0) { $0 + $1.correctAnswers }, total: totalAnswers)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 9) {
                    Text("YOUR NEXT SMALL WIN").font(.caption.weight(.semibold)).foregroundStyle(Theme.accent)
                    Text(studentName.isEmpty ? "Learn a little.\nGo a little further." : "Ready for a sprint, \(studentName)?")
                        .font(.largeTitle.bold())
                    Text("Read a lesson, test your understanding, and build your confidence.").foregroundStyle(.secondary)
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))], spacing: 12) {
                    metric("Quizzes taken", value: "\(results.count)", icon: "checklist")
                    metric("Accuracy", value: "\(Int(accuracy.rounded()))%", icon: "target")
                    metric("Best score", value: "\(Int((results.map(\.score).max() ?? 0).rounded()))%", icon: "trophy")
                }
                NavigationLink {
                    QuizView(subject: LearningCatalog.subjects[0], lesson: LearningCatalog.lessons[0])
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "bolt.fill").font(.title)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Start a quick sprint").font(.headline)
                            Text("5 questions · Swift values & optionals").font(.subheadline)
                        }
                        Spacer(minLength: 0)
                        Image(systemName: "arrow.up.right")
                    }.foregroundStyle(.white).padding(23)
                        .background(Theme.accent.gradient, in: RoundedRectangle(cornerRadius: 23))
                }.buttonStyle(.plain).accessibilityIdentifier("quickPractice")
                Text("Choose your subject").font(.title2.bold())
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 240), alignment: .top)], spacing: 14) {
                    ForEach(LearningCatalog.subjects) { subject in
                        NavigationLink { LessonsView(subject: subject) } label: { SubjectCard(subject: subject) }
                            .buttonStyle(.plain)
                    }
                }
                NavigationLink { ScanView() } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "doc.text.viewfinder").font(.title).foregroundStyle(Theme.teal)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Bring paper into your revision").font(.headline).foregroundStyle(.primary)
                            Text("Recognise text from a sample question paper or your own image.")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 0)
                    }.paperCard()
                }.buttonStyle(.plain)
                if let last = results.first {
                    Text("Your last sprint").font(.title2.bold())
                    NavigationLink { SavedResultView(result: last) } label: { ResultRow(result: last) }.buttonStyle(.plain)
                } else {
                    Text("Your results will appear here after your first quiz.").font(.subheadline).foregroundStyle(.secondary)
                }
            }.padding(22).frame(maxWidth: 1000).frame(maxWidth: .infinity)
        }.background(Theme.background).navigationTitle("PaperSprint").navigationBarTitleDisplayMode(.inline)
    }
    private func metric(_ title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon).foregroundStyle(Theme.accent)
            Text(value).font(.title.bold())
            Text(title).font(.caption).foregroundStyle(.secondary)
        }.paperCard()
    }
}

struct LessonsView: View {
    var subject: Subject? = nil
    @State private var query = ""
    private var lessons: [Lesson] {
        LearningCatalog.lessons.filter {
            (subject == nil || $0.subjectID == subject?.id)
            && (query.isEmpty || $0.title.localizedCaseInsensitiveContains(query)
                || LearningCatalog.subject(for: $0).name.localizedCaseInsensitiveContains(query))
        }
    }
    var body: some View {
        List {
            Section {
                Text("Read at your own pace, then practise five questions for each lesson.").foregroundStyle(.secondary)
            }
            if lessons.isEmpty {
                ContentUnavailableView.search(text: query)
            }
            ForEach(lessons) { lesson in
                NavigationLink { LessonDetailView(lesson: lesson) } label: {
                    HStack(alignment: .top, spacing: 15) {
                        Image(systemName: "book.closed.fill").foregroundStyle(Theme.accent).font(.title2)
                        VStack(alignment: .leading, spacing: 7) {
                            Text(lesson.title).font(.headline)
                            Text(LearningCatalog.subject(for: lesson).name).font(.caption).foregroundStyle(Theme.accent)
                            Text("\(lesson.minutes) min read · \(LearningCatalog.questions(for: lesson).count) questions")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }.padding(.vertical, 10)
                }.accessibilityIdentifier("lesson_\(lesson.id)")
            }
            Section { Text("Original sample revision content. Not an official SLIIT past paper.").font(.caption).foregroundStyle(.secondary) }
        }.navigationTitle(subject?.name ?? "Lessons")
            .searchable(text: $query, prompt: "Search lessons or subjects")
    }
}

struct LessonDetailView: View {
    let lesson: Lesson
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(LearningCatalog.subject(for: lesson).name.uppercased()).font(.caption.bold()).foregroundStyle(Theme.accent)
                Text(lesson.title).font(.largeTitle.bold())
                Text(lesson.introduction).font(.title3).foregroundStyle(.secondary)
                Label("\(lesson.minutes) minute read", systemImage: "clock").font(.caption).foregroundStyle(.secondary)
                ForEach(lesson.sections, id: \.heading) { section in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(section.heading).font(.title2.bold())
                        Text(section.body).font(.body).lineSpacing(5).textSelection(.enabled)
                    }.paperCard()
                }
                NavigationLink { QuizView(subject: LearningCatalog.subject(for: lesson), lesson: lesson) } label: {
                    Label("Practise this lesson", systemImage: "play.fill")
                        .frame(maxWidth: .infinity).padding(.vertical, 10)
                }.buttonStyle(.borderedProminent).accessibilityIdentifier("startLessonQuiz")
            }.padding(22).frame(maxWidth: 800).frame(maxWidth: .infinity)
        }.background(Theme.background).navigationTitle("Read & revise").navigationBarTitleDisplayMode(.inline)
    }
}
