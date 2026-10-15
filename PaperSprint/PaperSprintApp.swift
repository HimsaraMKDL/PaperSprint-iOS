import SwiftUI
import SwiftData

@main
struct PaperSprintApp: App {
    @AppStorage("appearance") private var appearance = "system"
    private let container: ModelContainer?
    private let storageError: String?
    init() {
        do {
            let schema = Schema([QuizResult.self])
            let config = ModelConfiguration("PaperSprint", schema: schema,
                isStoredInMemoryOnly: ProcessInfo.processInfo.arguments.contains("--uitesting"),
                cloudKitDatabase: .none)
            container = try ModelContainer(for: schema, configurations: [config])
            storageError = nil
        } catch {
            container = nil
            storageError = error.localizedDescription
        }
    }
    var body: some Scene {
        WindowGroup {
            if let container {
                ContentView().modelContainer(container).tint(Theme.accent)
                    .preferredColorScheme(appearance == "dark" ? .dark : appearance == "light" ? .light : nil)
            } else {
                ContentUnavailableView("Couldn't open quiz history", systemImage: "externaldrive.badge.exclamationmark",
                    description: Text("Reopen PaperSprint and try again. Existing data has not been deleted.\n\(storageError ?? "Storage error")"))
            }
        }
    }
}
