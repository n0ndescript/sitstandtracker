import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct SitStandTrackerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var trackerStore = TrackerStore()

    var body: some Scene {
        WindowGroup("SitStandTracker", id: "dashboard") {
            ContentView()
                .environment(trackerStore)
                .frame(minWidth: 980, minHeight: 680)
        }
        .windowResizability(.contentSize)

        MenuBarExtra {
            MenuBarPanel()
                .environment(trackerStore)
        } label: {
            MenuBarLabel()
                .environment(trackerStore)
        }
        .menuBarExtraStyle(.window)
    }
}
