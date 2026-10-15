import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("studentName") private var name = ""
    @AppStorage("appearance") private var appearance = "system"
    @Environment(\.modelContext) private var context
    @Query private var results: [QuizResult]
    @State private var showClear = false
    @State private var error: String?
    var body: some View {
        Form {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: "bolt.square.fill").font(.largeTitle).foregroundStyle(Theme.accent)
                    VStack(alignment: .leading, spacing: 5) {
                        Text("PaperSprint").font(.title2.bold())
                        Text("Learn. Practise. Improve.").font(.caption).foregroundStyle(.secondary)
                    }
                }.padding(.vertical, 12)
            }
            Section("Make it yours") {
                TextField("Your name (optional)", text: $name).textContentType(.givenName)
                Picker("Appearance", selection: $appearance) {
                    Text("System").tag("system"); Text("Light").tag("light"); Text("Dark").tag("dark")
                }
            }
            Section("Your learning library") {
                LabeledContent("Subjects", value: "\(LearningCatalog.subjects.count)")
                LabeledContent("Lessons", value: "\(LearningCatalog.lessons.count)")
                LabeledContent("Questions", value: "\(LearningCatalog.questions.count)")
                LabeledContent("Saved attempts", value: "\(results.count)")
            }
            Section("Help & information") {
                NavigationLink("How to use PaperSprint") { HelpView() }
                NavigationLink("About & privacy") {
                    List {
                        Section("PaperSprint 1.0 · Part A iOS") {
                            Text("A revision and multiple-choice practice app for students, built with SwiftUI, SwiftData, Apple Vision and PhotosUI.")
                            Text("All lessons and questions are original sample revision material. They are not official exam questions or a complete module syllabus.")
                        }
                        Section("Privacy") {
                            Text("Completed quiz attempts and answer reviews stay in this device's local SwiftData store. Your name and appearance use device preferences. OCR processes the selected image on-device; the image and text are not saved by PaperSprint. Share and Copy are explicit user actions.")
                            Text("No login, server, cloud sync, analytics, camera or location permission is required. PhotosPicker gives access only to the image you choose; an iCloud photo may require internet to download.")
                        }
                        Section("Credits") {
                            Text("Apple SwiftUI, SwiftData, Vision, PhotosUI, ImageIO and SF Symbols. The app icon and sample paper are original project assets.")
                        }
                    }.navigationTitle("About & privacy")
                }
            }
            Section {
                Button("Delete all quiz history", role: .destructive) { showClear = true }
            } footer: { Text("Deletes saved attempts and answer reviews. Lessons, questions, name and appearance stay available.") }
        }.navigationTitle("Settings")
            .confirmationDialog("Delete all quiz history?", isPresented: $showClear, titleVisibility: .visible) {
                Button("Delete all quiz history", role: .destructive) {
                    results.forEach { context.delete($0) }
                    do { try context.save() } catch { context.rollback(); self.error = error.localizedDescription }
                }
            } message: { Text("This cannot be undone.") }
            .alert("Couldn't delete history", isPresented: Binding(get: { error != nil }, set: { if !$0 { error = nil } })) {
                Button("OK", role: .cancel) { error = nil }
            } message: { Text(error ?? "Please try again.") }
    }
}
struct HelpView: View {
    var body: some View {
        List {
            Section("Read") { Text("Choose a subject on Home or open Lessons. Select a lesson and read its short sections. Tap Practise this lesson when ready.") }
            Section("Practise") { Text("Select one option, tap Check answer and read the explanation. Tap Next question. After the final question, tap See results. Checked answers cannot be changed or scored again.") }
            Section("Review") { Text("A completed attempt saves automatically. Results shows your history. Open an attempt and tap Review answers to compare your choices with the correct answers. Try a quiz again to create a new attempt.") }
            Section("Scan") { Text("Open Scan and tap Recognise sample paper. You can also choose a photo or import an image from Files. Apple Vision recognises English text; review it before copying or sharing. Scanned text is not converted into a quiz.") }
            Section("Personalise") { Text("Set an optional name or Light/Dark/System appearance. Larger system text sizes are supported. Closing an unfinished quiz discards it; completed results remain after reopening the app.") }
        }.navigationTitle("Quick guide")
    }
}
