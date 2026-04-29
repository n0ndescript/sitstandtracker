import AppKit
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    var prepareForQuit: (() -> Void)?
    var handleScreenLocked: (() -> Void)?
    var handleScreenUnlocked: (() -> Void)?

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
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(screenLocked(_:)),
            name: Notification.Name("com.apple.screenIsLocked"),
            object: nil
        )
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(screenUnlocked(_:)),
            name: Notification.Name("com.apple.screenIsUnlocked"),
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

    @objc private func screenLocked(_ notification: Notification) {
        handleScreenLocked?()
    }

    @objc private func screenUnlocked(_ notification: Notification) {
        handleScreenUnlocked?()
    }

    private func isDashboardWindow(_ window: NSWindow?) -> Bool {
        window?.title == "SitStandTracker"
    }
}

@main
struct SitStandTrackerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var trackerStore = TrackerStore()
    private let dashboardMinimumSize = CGSize(width: 1060, height: 680)
    private let dashboardDefaultSize = CGSize(width: 1120, height: 760)

    var body: some Scene {
        Window("SitStandTracker", id: "dashboard") {
            ContentView()
                .environment(trackerStore)
                .frame(
                    minWidth: dashboardMinimumSize.width,
                    minHeight: dashboardMinimumSize.height
                )
                .onAppear {
                    appDelegate.prepareForQuit = {
                        trackerStore.prepareForQuit()
                    }
                    appDelegate.handleScreenLocked = {
                        trackerStore.handleScreenLocked()
                    }
                    appDelegate.handleScreenUnlocked = {
                        trackerStore.handleScreenUnlocked()
                    }
                }
        }
        .defaultSize(width: dashboardDefaultSize.width, height: dashboardDefaultSize.height)
        .windowResizability(.contentMinSize)

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
