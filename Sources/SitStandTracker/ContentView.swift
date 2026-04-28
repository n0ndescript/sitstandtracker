import SwiftUI

struct ContentView: View {
    @Environment(TrackerStore.self) private var trackerStore
    @State private var currentTime = Date()

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                heroCard
                quickActions
                summarySection
                historySection
            }
            .padding(28)
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.97, blue: 0.99),
                    Color(red: 0.88, green: 0.93, blue: 0.96),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .onReceive(timer) { value in
            currentTime = value
            trackerStore.tick()
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sit / Stand Tracker")
                        .font(.system(size: 30, weight: .bold, design: .rounded))

                    Text(statusText)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(currentTime.formatted(date: .omitted, time: .shortened))
                    .font(.title3.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(elapsedLabel)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()

                Text("Target ratio: \(trackerStore.targetRatioText)")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    private var quickActions: some View {
        HStack(spacing: 16) {
            ForEach(Posture.allCases) { posture in
                Button {
                    trackerStore.start(posture: posture)
                } label: {
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: posture.symbolName)
                            .font(.system(size: 24))
                        Text(posture.title)
                            .font(.headline)
                        Text(buttonSubtitle(for: posture))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 120, alignment: .leading)
                    .padding(20)
                    .background(buttonBackground(for: posture), in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var summarySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today")
                        .font(.title2.weight(.bold))

                    Text("Goal status: \(trackerStore.todaySummary.goalStatus.title)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button("Stop Tracking") {
                    trackerStore.stopTracking()
                }
                .disabled(trackerStore.currentPosture == nil)

                Button("Reset") {
                    trackerStore.clearHistory()
                }
                .buttonStyle(.bordered)
            }

            HStack(spacing: 16) {
                summaryCard(for: .sitting, color: Color(red: 0.18, green: 0.39, blue: 0.67))
                summaryCard(for: .standing, color: Color(red: 0.13, green: 0.53, blue: 0.42))
            }

            HStack(spacing: 16) {
                metricCard(title: "Avg Sit", value: trackerStore.todaySummary.averageSitDuration.formattedDuration)
                metricCard(title: "Avg Stand", value: trackerStore.todaySummary.averageStandDuration.formattedDuration)
                metricCard(title: "Sit Streak", value: trackerStore.todaySummary.longestSittingDuration.formattedDuration)
                metricCard(title: "Stand Streak", value: trackerStore.todaySummary.longestStandingDuration.formattedDuration)
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Sessions")
                .font(.title2.weight(.bold))

            if trackerStore.todaySessions.isEmpty {
                Text("No completed sessions yet today. Start with Sitting or Standing above.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
            } else {
                VStack(spacing: 12) {
                    ForEach(trackerStore.todaySessions) { session in
                        HStack(spacing: 14) {
                            Image(systemName: session.posture.symbolName)
                                .font(.title3)
                                .frame(width: 36, height: 36)
                                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.posture.title)
                                    .font(.headline)
                                Text(sessionRangeText(for: session))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text(session.duration.formattedDuration)
                                .font(.headline.monospacedDigit())
                        }
                        .padding(16)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
            }
        }
    }

    private func summaryCard(for posture: Posture, color: Color) -> some View {
        let duration = trackerStore.todaySummary.duration(for: posture)
        let percentage = trackerStore.todaySummary.percentage(for: posture)

        return VStack(alignment: .leading, spacing: 14) {
            Label(posture.title, systemImage: posture.symbolName)
                .font(.headline)

            Text(duration.formattedDuration)
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .monospacedDigit()

            Text("\(Int((percentage * 100).rounded()))% of tracked time")
                .foregroundStyle(.secondary)

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 999)
                        .fill(Color.white.opacity(0.3))
                    RoundedRectangle(cornerRadius: 999)
                        .fill(color)
                        .frame(width: max(8, geometry.size.width * percentage))
                }
            }
            .frame(height: 10)
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.gradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func metricCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline.monospacedDigit())
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func buttonSubtitle(for posture: Posture) -> String {
        if trackerStore.currentPosture == posture {
            return "Currently active"
        }
        return "Switch to \(posture.title.lowercased())"
    }

    private func buttonBackground(for posture: Posture) -> LinearGradient {
        let isActive = trackerStore.currentPosture == posture
        switch posture {
        case .sitting:
            return LinearGradient(
                colors: isActive
                    ? [Color(red: 0.2, green: 0.42, blue: 0.74), Color(red: 0.12, green: 0.27, blue: 0.51)]
                    : [Color.white.opacity(0.85), Color(red: 0.85, green: 0.91, blue: 0.98)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .standing:
            return LinearGradient(
                colors: isActive
                    ? [Color(red: 0.17, green: 0.57, blue: 0.46), Color(red: 0.08, green: 0.36, blue: 0.29)]
                    : [Color.white.opacity(0.85), Color(red: 0.84, green: 0.95, blue: 0.89)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var statusText: String {
        guard let currentPosture = trackerStore.currentPosture else {
            return "No active posture yet"
        }

        return "\(currentPosture.title) right now"
    }

    private var elapsedLabel: String {
        guard trackerStore.currentPosture != nil else {
            return "00:00:00"
        }

        return trackerStore.elapsedInCurrentPosture.formattedDuration
    }

    private func sessionRangeText(for session: TrackingSession) -> String {
        let start = session.startDate.formatted(date: .omitted, time: .shortened)
        let end = session.endDate.formatted(date: .omitted, time: .shortened)
        return "\(start) - \(end)"
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
}
