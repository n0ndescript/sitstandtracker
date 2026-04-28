import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var prepareForQuit: (() -> Void)?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dashboardWindowWillClose(_:)),
            name: NSWindow.willCloseNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(dashboardWindowDidBecomeKey(_:)),
            name: NSWindow.didBecomeKeyNotification,
            object: nil
        )
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        false
    }

    func applicationWillTerminate(_ notification: Notification) {
        prepareForQuit?()
        UserDefaults.standard.synchronize()
    }

    @objc private func dashboardWindowWillClose(_ notification: Notification) {
        guard isDashboardWindow(notification.object as? NSWindow) else { return }
        NSApp.setActivationPolicy(.accessory)
    }

    @objc private func dashboardWindowDidBecomeKey(_ notification: Notification) {
        guard isDashboardWindow(notification.object as? NSWindow) else { return }
        NSApp.setActivationPolicy(.regular)
    }

    private func isDashboardWindow(_ window: NSWindow?) -> Bool {
        window?.title == "SitStandTracker"
    }
}

@main
struct SitStandTrackerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var trackerStore = TrackerStore()

    var body: some Scene {
        Window("SitStandTracker", id: "dashboard") {
            ContentView()
                .environment(trackerStore)
                .frame(minWidth: 980, minHeight: 680)
                .onAppear {
                    appDelegate.prepareForQuit = {
                        trackerStore.prepareForQuit()
                    }
                }
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
