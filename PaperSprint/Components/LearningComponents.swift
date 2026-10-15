import SwiftUI

enum Theme {
    static let accent = Color(red: 0.23, green: 0.29, blue: 0.78)
    static let teal = Color(red: 0.05, green: 0.48, blue: 0.42)
    static let background = Color(uiColor: .systemGroupedBackground)
    static let surface = Color(uiColor: .secondarySystemGroupedBackground)
}
struct PaperCard: ViewModifier {
    func body(content: Content) -> some View {
        content.padding(20).frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.surface, in: RoundedRectangle(cornerRadius: 22))
    }
}
extension View {
    func paperCard() -> some View { modifier(PaperCard()) }
}
struct SubjectCard: View {
    let subject: Subject
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: subject.icon).font(.title).foregroundStyle(Theme.accent)
                .frame(width: 50, height: 50).background(Theme.accent.opacity(0.09), in: RoundedRectangle(cornerRadius: 14))
            Text(subject.name).font(.title3.bold()).foregroundStyle(.primary)
            Text(subject.subtitle).font(.subheadline).foregroundStyle(.secondary)
            Label("\(LearningCatalog.lessons(for: subject).count) lessons", systemImage: "book.closed")
                .font(.caption.bold()).foregroundStyle(Theme.accent)
        }.paperCard()
    }
}

struct AnswerOptionView: View {
    let text: String
    let index: Int
    let isSelected: Bool
    let isChecked: Bool
    let correctIndex: Int
    let action: () -> Void
    private var correct: Bool { isChecked && index == correctIndex }
    private var wrong: Bool { isChecked && isSelected && index != correctIndex }
    private var color: Color { correct ? Theme.teal : wrong ? .red : isSelected ? Theme.accent : .secondary }
    var body: some View {
        Button(action: action) {
            HStack(alignment: .top, spacing: 14) {
                Text(index < 4 && index >= 0 ? ["A", "B", "C", "D"][index] : "\(index + 1)").font(.headline)
                    .frame(width: 34, height: 34)
                    .background(color.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
                Text(text).font(.body.weight(isSelected ? .semibold : .regular))
                    .frame(maxWidth: .infinity, alignment: .leading).foregroundStyle(.primary)
                if correct { Image(systemName: "checkmark.circle.fill").accessibilityLabel("Correct answer") }
                else if wrong { Image(systemName: "xmark.circle.fill").accessibilityLabel("Incorrect answer") }
                else if isSelected { Image(systemName: "largecircle.fill.circle").accessibilityHidden(true) }
            }.foregroundStyle(color).padding(16)
                .background(color.opacity(correct || wrong || isSelected ? 0.08 : 0.02), in: RoundedRectangle(cornerRadius: 17))
                .overlay(RoundedRectangle(cornerRadius: 17).stroke(color.opacity(isSelected || correct ? 0.8 : 0.18), lineWidth: isSelected || correct ? 2 : 1))
        }.buttonStyle(.plain).disabled(isChecked)
            .accessibilityLabel("Option \(index + 1). \(text)")
            .accessibilityValue(correct ? "Correct answer" : wrong ? "Your incorrect answer" : isSelected ? "Selected" : "Not selected")
            .accessibilityIdentifier("answer_\(index)")
    }
}
struct ScoreRing: View {
    let score: Double
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    var body: some View {
        ZStack {
            Circle().stroke(Theme.accent.opacity(0.12), lineWidth: 13)
            Circle().trim(from: 0, to: min(max(score / 100, 0), 1))
                .stroke(Theme.accent, style: StrokeStyle(lineWidth: 13, lineCap: .round)).rotationEffect(.degrees(-90))
            VStack(spacing: 4) {
                Text("\(Int(score.rounded()))%").font(.largeTitle.bold())
                Text("Your score").font(.caption).foregroundStyle(.secondary)
            }
        }.frame(width: 165, height: 165)
            .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: score)
            .accessibilityElement(children: .ignore).accessibilityLabel("Score \(Int(score.rounded())) percent")
    }
}
