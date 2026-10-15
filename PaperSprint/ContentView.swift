import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack { HomeView() }.tabItem { Label("Home", systemImage: "square.grid.2x2.fill") }
            NavigationStack { LessonsView() }.tabItem { Label("Lessons", systemImage: "books.vertical.fill") }
            NavigationStack { HistoryView() }.tabItem { Label("Results", systemImage: "chart.bar.fill") }
            NavigationStack { ScanView() }.tabItem { Label("Scan", systemImage: "doc.text.viewfinder") }
            NavigationStack { SettingsView() }.tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
    }
}
#Preview { ContentView().modelContainer(for: QuizResult.self, inMemory: true) }
