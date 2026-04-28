import SwiftUI

@main
struct SitStandTrackerApp: App {
    @State private var trackerStore = TrackerStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(trackerStore)
                .frame(minWidth: 760, minHeight: 620)
        }
        .windowResizability(.contentSize)
    }
}
