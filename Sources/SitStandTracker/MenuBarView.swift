import AppKit
import SwiftUI

struct MenuBarLabel: View {
    @Environment(TrackerStore.self) private var trackerStore

    var body: some View {
        if let alertKind = trackerStore.activeAlertKind {
            Label(alertKind.shortTitle, systemImage: alertKind.symbolName)
                .foregroundStyle(alertKind.tint)
        } else if let posture = trackerStore.currentPosture {
            Label("\(posture.menuTitle) \(trackerStore.elapsedInCurrentPosture.formattedCompactDuration)", systemImage: posture.symbolName)
        } else {
            Label("Idle", systemImage: "pause.circle")
        }
    }
}

struct MenuBarPanel: View {
    @Environment(TrackerStore.self) private var trackerStore
    @Environment(\.openWindow) private var openWindow

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let alertKind = trackerStore.activeAlertKind {
                alertPanel(for: alertKind)
            } else {
                normalPanel
            }

            Divider()

            HStack {
                Button {
                    openWindow(id: "dashboard")
                    NSApp.activate(ignoringOtherApps: true)
                } label: {
                    Label("Open Dashboard", systemImage: "macwindow")
                }

                Spacer()

                Button {
                    NSApp.terminate(nil)
                } label: {
                    Label("Quit", systemImage: "power")
                }
            }
            .buttonStyle(.borderless)
        }
        .padding(18)
        .frame(width: 340)
        .onReceive(timer) { _ in
            trackerStore.tick()
        }
    }

    private var normalPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Label(statusTitle, systemImage: trackerStore.currentPosture?.symbolName ?? "pause.circle")
                        .font(.headline)

                    Text(trackerStore.currentPosture == nil ? "IDLE" : "ACTIVE SESSION")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Text(elapsedLabel)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text("Target ratio: \(trackerStore.targetRatioText)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            if trackerStore.isAlertSnoozed, let snoozeUntil = trackerStore.alertState.snoozeUntil {
                Label("Snoozed until \(snoozeUntil.formatted(date: .omitted, time: .shortened))", systemImage: "moon.zzz.fill")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            actionButtons

            footerMetrics
        }
    }

    private func alertPanel(for alertKind: AlertKind) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: alertKind.symbolName)
                    .font(.title2)
                    .foregroundStyle(alertKind.tint)
                    .frame(width: 34, height: 34)

                VStack(alignment: .leading, spacing: 5) {
                    Text(alertKind.title)
                        .font(.headline)

                    Text("You've been \(alertKind.activePosture.title.lowercased()) for \(trackerStore.elapsedInCurrentPosture.formattedShortDuration).")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Text(elapsedLabel)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .monospacedDigit()

            Button {
                trackerStore.switchToAlertRecommendation()
            } label: {
                Label("Switch to \(alertKind.recommendedPosture.title)", systemImage: alertKind.recommendedPosture.symbolName)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            HStack(spacing: 10) {
                Button {
                    trackerStore.snoozeAlert()
                } label: {
                    Label("+\(trackerStore.preferences.defaultSnoozeMinutes) min", systemImage: "moon.zzz.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    trackerStore.dismissAlert()
                } label: {
                    Label("Dismiss", systemImage: "xmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 12) {
                summaryMetric(title: "Sit", value: trackerStore.todaySummary.sittingDuration.formattedShortDuration)
                summaryMetric(title: "Stand", value: trackerStore.todaySummary.standingDuration.formattedShortDuration)
            }
        }
        .padding(14)
        .background(alertKind.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var actionButtons: some View {
        HStack(spacing: 10) {
            if let posture = trackerStore.currentPosture {
                let nextPosture = posture == .sitting ? Posture.standing : Posture.sitting

                Button {
                    trackerStore.start(posture: nextPosture)
                } label: {
                    Label("Switch to \(nextPosture.title)", systemImage: nextPosture.symbolName)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    trackerStore.stopTracking()
                } label: {
                    Label("Stop", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            } else {
                Button {
                    trackerStore.start(posture: .sitting)
                } label: {
                    Label("Sit", systemImage: Posture.sitting.symbolName)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    trackerStore.start(posture: .standing)
                } label: {
                    Label("Stand", systemImage: Posture.standing.symbolName)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var footerMetrics: some View {
        HStack(spacing: 12) {
            if let posture = trackerStore.currentPosture {
                summaryMetric(title: "Today", value: trackerStore.todaySummary.duration(for: posture).formattedShortDuration)
                summaryMetric(title: "Longest", value: longestDuration(for: posture).formattedShortDuration)
            } else {
                summaryMetric(title: "Sit Today", value: trackerStore.todaySummary.sittingDuration.formattedShortDuration)
                summaryMetric(title: "Stand Today", value: trackerStore.todaySummary.standingDuration.formattedShortDuration)
            }
        }
    }

    private func summaryMetric(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline.monospacedDigit())
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private func longestDuration(for posture: Posture) -> TimeInterval {
        switch posture {
        case .sitting:
            return trackerStore.todaySummary.longestSittingDuration
        case .standing:
            return trackerStore.todaySummary.longestStandingDuration
        }
    }

    private var statusTitle: String {
        trackerStore.currentPosture?.title ?? "No active posture"
    }

    private var elapsedLabel: String {
        guard trackerStore.currentPosture != nil else {
            return "00:00:00"
        }

        return trackerStore.elapsedInCurrentPosture.formattedDuration
    }
}

private extension Posture {
    var menuTitle: String {
        switch self {
        case .sitting:
            return "sit"
        case .standing:
            return "stand"
        }
    }
}

private extension AlertKind {
    var shortTitle: String {
        switch self {
        case .timeToStand:
            return "Stand!"
        case .timeToSit:
            return "Sit!"
        }
    }

    var tint: Color {
        switch self {
        case .timeToStand:
            return Color(red: 0.72, green: 0.43, blue: 0.12)
        case .timeToSit:
            return Color(red: 0.20, green: 0.39, blue: 0.63)
        }
    }

    var symbolName: String {
        switch self {
        case .timeToStand:
            return "figure.stand"
        case .timeToSit:
            return "chair.lounge.fill"
        }
    }
}

private extension TimeInterval {
    var formattedDuration: String {
        let totalSeconds = max(Int(self.rounded()), 0)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var formattedCompactDuration: String {
        let totalSeconds = max(Int(self.rounded()), 0)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60

        if hours > 0 {
            return String(format: "%d:%02d", hours, minutes)
        }

        return String(format: "%02d:%02d", minutes, totalSeconds % 60)
    }

    var formattedShortDuration: String {
        let totalMinutes = max(Int((self / 60).rounded()), 0)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        }

        if hours > 0 {
            return "\(hours)h"
        }

        return "\(minutes)m"
    }
}
