import SwiftUI

struct ContentView: View {
    @Environment(TrackerStore.self) private var trackerStore
    @State private var selectedPage = AppPage.dashboard
    @State private var expandedHistoryDayIDs: Set<Date> = []
    private let sidebarWidth: CGFloat = 236
    private let sidebarContentInset: CGFloat = 22
    private var sidebarContentWidth: CGFloat {
        sidebarWidth - (sidebarContentInset * 2)
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar

            Divider()

            ScrollView {
                currentPage
                    .padding(28)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .background(pageBackground)
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Tracker")
                    .font(.system(size: 26, weight: .bold, design: .rounded))

                Text("Productive Session")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 30)

            VStack(spacing: 6) {
                ForEach(AppPage.allCases) { page in
                    Button {
                        selectedPage = page
                    } label: {
                        Label(page.title, systemImage: page.symbolName)
                            .font(.headline)
                            .frame(width: sidebarContentWidth - 28, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(
                                selectedPage == page ? Color.accentColor.opacity(0.14) : Color.clear,
                                in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                            )
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(selectedPage == page ? Color.accentColor : Color.primary)
                }
            }
            .frame(width: sidebarContentWidth, alignment: .leading)

            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text(statusText)
                    .font(.subheadline.weight(.semibold))

                Text(elapsedLabel)
                    .font(.title3.monospacedDigit().weight(.bold))
            }
            .padding(16)
            .frame(width: sidebarContentWidth, alignment: .leading)
            .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.bottom, 16)
        }
        .frame(width: sidebarContentWidth, alignment: .leading)
        .padding(.horizontal, sidebarContentInset)
        .frame(width: sidebarWidth, alignment: .leading)
        .background(Color(red: 0.95, green: 0.96, blue: 0.94))
        .clipped()
    }

    @ViewBuilder
    private var currentPage: some View {
        switch selectedPage {
        case .dashboard:
            dashboardPage
        case .history:
            historyPage
        case .analytics:
            analyticsPage
        case .settings:
            settingsPage
        }
    }

    private var dashboardPage: some View {
        VStack(alignment: .leading, spacing: 22) {
            pageHeader(title: "Dashboard", subtitle: trackerStore.now.formatted(date: .abbreviated, time: .shortened))

            HStack(alignment: .top, spacing: 18) {
                currentStatusCard
                    .frame(minWidth: 430)

                goalCard
                    .frame(width: 280)
            }

            metricsRow
            recentActivityPanel
        }
    }

    private var currentStatusCard: some View {
        VStack(alignment: .leading, spacing: 22) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Current Status")
                        .font(.title2.weight(.bold))

                    Label(statusText, systemImage: trackerStore.currentPosture?.symbolName ?? "pause.circle")
                        .font(.headline)
                        .foregroundStyle(statusColor)
                }

                Spacer()

                Button {
                    stopOrStartDefault()
                } label: {
                    Image(systemName: trackerStore.currentPosture == nil ? "play.fill" : "stop.fill")
                        .font(.headline)
                        .frame(width: 38, height: 38)
                }
                .buttonStyle(.borderedProminent)
                .clipShape(Circle())
                .help(trackerStore.currentPosture == nil ? "Start Sitting" : "Stop Tracking")
                .accessibilityLabel(trackerStore.currentPosture == nil ? "Start sitting" : "Stop tracking")
            }

            Text(elapsedLabel)
                .font(.system(size: 58, weight: .bold, design: .rounded))
                .monospacedDigit()
                .lineLimit(1)
                .minimumScaleFactor(0.72)

            Text("Target ratio: \(trackerStore.targetRatioText)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            alertSurface
            actionButtons
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.78), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    @ViewBuilder
    private var alertSurface: some View {
        if let alertKind = trackerStore.activeAlertKind {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: alertKind.symbolName)
                        .font(.title2)
                        .foregroundStyle(alertKind.tint)
                        .frame(width: 34, height: 34)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(alertKind.title)
                            .font(.headline)

                        Text("You've been \(alertKind.activePosture.title.lowercased()) for \(trackerStore.elapsedInCurrentPosture.formattedShortDuration).")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }

                HStack(spacing: 10) {
                    Button {
                        trackerStore.switchToAlertRecommendation()
                    } label: {
                        Label("Switch to \(alertKind.recommendedPosture.title)", systemImage: alertKind.recommendedPosture.symbolName)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

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
            }
            .padding(16)
            .background(alertKind.tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        } else if trackerStore.isAlertSnoozed, let snoozeUntil = trackerStore.alertState.snoozeUntil {
            Label("Alert snoozed until \(snoozeUntil.formatted(date: .omitted, time: .shortened))", systemImage: "moon.zzz.fill")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.58), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private var goalCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Daily Goal")
                .font(.title3.weight(.bold))

            VStack(alignment: .leading, spacing: 12) {
                compactPreferenceStepper(
                    title: "Stand",
                    value: trackerStore.preferences.targetStandingBlockMinutes,
                    binding: standingMinutesBinding,
                    range: 1...240
                )

                compactPreferenceStepper(
                    title: "After sitting",
                    value: trackerStore.preferences.targetSittingBlockMinutes,
                    binding: sittingMinutesBinding,
                    range: 1...240
                )
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Text("Target ratio")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(trackerStore.targetRatioText)
                    .font(.headline)
            }

            statusBadge(for: trackerStore.todaySummary.goalStatus)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color(red: 0.97, green: 0.93, blue: 0.86), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var metricsRow: some View {
        HStack(spacing: 14) {
            metricCard(title: "Avg Sit", value: trackerStore.todaySummary.averageSitDuration.formattedShortDuration, symbolName: "chair.lounge.fill")
            metricCard(title: "Avg Stand", value: trackerStore.todaySummary.averageStandDuration.formattedShortDuration, symbolName: "figure.stand")
            metricCard(title: "Sit Streak", value: trackerStore.todaySummary.longestSittingDuration.formattedShortDuration, symbolName: "timer")
            metricCard(title: "Stand Streak", value: trackerStore.todaySummary.longestStandingDuration.formattedShortDuration, symbolName: "chart.line.uptrend.xyaxis")
        }
    }

    private var recentActivityPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Recent Activity")
                    .font(.title2.weight(.bold))

                Spacer()

                Button {
                    selectedPage = .history
                } label: {
                    Label("View All", systemImage: "clock.arrow.circlepath")
                }
                .buttonStyle(.borderless)
            }

            sessionList(limit: 5)
        }
        .panelStyle()
    }

    private var historyPage: some View {
        VStack(alignment: .leading, spacing: 22) {
            pageHeader(title: "History", subtitle: "\(trackerStore.historyDays.count) tracked \(trackerStore.historyDays.count == 1 ? "day" : "days")")

            if trackerStore.historyDays.isEmpty {
                Text("No history yet.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .panelStyle()
            } else {
                VStack(spacing: 14) {
                    ForEach(trackerStore.historyDays) { day in
                        historyDayCard(for: day)
                    }
                }
            }
        }
        .onAppear {
            if let today = trackerStore.historyDays.first?.id {
                expandedHistoryDayIDs.insert(today)
            }
        }
    }

    private var analyticsPage: some View {
        let analytics = trackerStore.sevenDayAnalytics

        return VStack(alignment: .leading, spacing: 22) {
            pageHeader(title: "Analytics", subtitle: "Last 7 days")

            VStack(alignment: .leading, spacing: 16) {
                Text("Recent Ratio")
                    .font(.title2.weight(.bold))

                recentDaysChart(for: analytics.days)
            }
            .panelStyle()

            HStack(spacing: 14) {
                analyticsTile(title: "Avg Tracked", value: analytics.averageActiveTrackedDuration.formattedShortDuration)
                analyticsTile(title: "Avg Sit", value: analytics.averageSitDuration.formattedShortDuration)
                analyticsTile(title: "Avg Stand", value: analytics.averageStandDuration.formattedShortDuration)
            }

            VStack(alignment: .leading, spacing: 16) {
                Text("Goal Status")
                    .font(.title2.weight(.bold))

                HStack(spacing: 14) {
                    analyticsStatusTile(title: "Met", value: analytics.metCount, status: .met)
                    analyticsStatusTile(title: "Exceeded", value: analytics.exceededCount, status: .exceeded)
                    analyticsStatusTile(title: "Not Met", value: analytics.notMetCount, status: .notMet)
                    analyticsStatusTile(title: "Low Data", value: analytics.insufficientDataCount, status: .insufficientData)
                }
            }
            .panelStyle()
        }
    }

    private var settingsPage: some View {
        VStack(alignment: .leading, spacing: 22) {
            pageHeader(title: "Settings", subtitle: "Work cycle")

            VStack(alignment: .leading, spacing: 18) {
                preferenceStepperRow(
                    title: "Stand for",
                    value: trackerStore.preferences.targetStandingBlockMinutes,
                    symbolName: "figure.stand",
                    binding: standingMinutesBinding,
                    range: 1...240,
                    step: 5
                )

                preferenceStepperRow(
                    title: "After sitting for",
                    value: trackerStore.preferences.targetSittingBlockMinutes,
                    symbolName: "chair.lounge.fill",
                    binding: sittingMinutesBinding,
                    range: 1...240,
                    step: 5
                )

                preferenceStepperRow(
                    title: "Default snooze",
                    value: trackerStore.preferences.defaultSnoozeMinutes,
                    symbolName: "moon.zzz.fill",
                    binding: snoozeMinutesBinding,
                    range: 1...60,
                    step: 1
                )

                HStack {
                    Text("Target ratio")
                        .font(.headline)

                    Spacer()

                    Text(trackerStore.targetRatioText)
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.secondary)
                }

                Divider()

                Button(role: .destructive) {
                    trackerStore.clearHistory()
                } label: {
                    Label("Reset Data", systemImage: "trash")
                }
                .buttonStyle(.bordered)
            }
            .panelStyle()
        }
    }

    private var dailySummaryStrip: some View {
        HStack(spacing: 14) {
            summaryCard(for: .sitting, color: Color(red: 0.20, green: 0.39, blue: 0.63))
            summaryCard(for: .standing, color: Color(red: 0.16, green: 0.50, blue: 0.37))
        }
    }

    private func historyDayCard(for day: DayHistory) -> some View {
        let isExpanded = expandedHistoryDayIDs.contains(day.id)

        return VStack(alignment: .leading, spacing: 16) {
            Button {
                toggleHistoryDay(day.id)
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: isExpanded ? "chevron.down.circle.fill" : "chevron.right.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.accentColor)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(historyTitle(for: day.date))
                            .font(.title3.weight(.bold))

                        Text("\(day.sessions.count) completed \(day.sessions.count == 1 ? "session" : "sessions")")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    statusBadge(for: day.summary.goalStatus)
                }
            }
            .buttonStyle(.plain)

            HStack(spacing: 14) {
                dayMetric(title: "Sitting", value: day.summary.sittingDuration.formattedShortDuration, symbolName: Posture.sitting.symbolName)
                dayMetric(title: "Standing", value: day.summary.standingDuration.formattedShortDuration, symbolName: Posture.standing.symbolName)
                dayMetric(title: "Standing Share", value: "\(Int((day.summary.percentage(for: .standing) * 100).rounded()))%", symbolName: "percent")
            }

            if isExpanded {
                Divider()

                if day.sessions.isEmpty {
                    Text("No completed sessions for this day.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)
                } else {
                    VStack(spacing: 10) {
                        ForEach(day.sessions) { session in
                            historySessionRow(session)
                        }
                    }
                }
            }
        }
        .panelStyle()
    }

    private func historySessionRow(_ session: TrackingSession) -> some View {
        HStack(spacing: 14) {
            Image(systemName: session.posture.symbolName)
                .font(.headline)
                .foregroundStyle(session.posture == .standing ? Color(red: 0.16, green: 0.50, blue: 0.37) : Color(red: 0.20, green: 0.39, blue: 0.63))
                .frame(width: 34, height: 34)
                .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(session.posture.title)
                    .font(.headline)

                Text(sessionRangeText(for: session))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(session.duration.formattedShortDuration)
                .font(.headline.monospacedDigit())
        }
        .padding(12)
        .background(Color.white.opacity(0.56), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var ratioBar: some View {
        let sittingShare = trackerStore.todaySummary.percentage(for: .sitting)
        let standingShare = trackerStore.todaySummary.percentage(for: .standing)

        return VStack(alignment: .leading, spacing: 10) {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(red: 0.20, green: 0.39, blue: 0.63))
                        .frame(width: geometry.size.width * sittingShare)

                    Rectangle()
                        .fill(Color(red: 0.16, green: 0.50, blue: 0.37))
                        .frame(width: geometry.size.width * standingShare)
                }
                .background(Color.black.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .frame(height: 18)

            HStack {
                Label("Sitting \(Int((sittingShare * 100).rounded()))%", systemImage: "chair.lounge.fill")
                Spacer()
                Label("Standing \(Int((standingShare * 100).rounded()))%", systemImage: "figure.stand")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
    }

    private func recentDaysChart(for days: [DayHistory]) -> some View {
        let maxDuration = max(days.map(\.summary.totalDuration).max() ?? 0, 1)

        return VStack(spacing: 12) {
            ForEach(days) { day in
                analyticsDayRow(day, maxDuration: maxDuration)
            }
        }
    }

    private func analyticsDayRow(_ day: DayHistory, maxDuration: TimeInterval) -> some View {
        let sittingWidth = day.summary.sittingDuration / maxDuration
        let standingWidth = day.summary.standingDuration / maxDuration
        let standingShare = Int((day.summary.percentage(for: .standing) * 100).rounded())

        return HStack(spacing: 12) {
            Text(shortDayLabel(for: day.date))
                .font(.subheadline.weight(.semibold))
                .frame(width: 46, alignment: .leading)

            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(red: 0.20, green: 0.39, blue: 0.63))
                        .frame(width: geometry.size.width * sittingWidth)

                    Rectangle()
                        .fill(Color(red: 0.16, green: 0.50, blue: 0.37))
                        .frame(width: geometry.size.width * standingWidth)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.black.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .frame(height: 18)

            Text(day.summary.totalDuration.formattedShortDuration)
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 58, alignment: .trailing)

            Text("\(standingShare)%")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(width: 42, alignment: .trailing)

            statusBadge(for: day.summary.goalStatus)
                .frame(width: 116, alignment: .trailing)
        }
    }

    @ViewBuilder
    private func sessionList(limit: Int?) -> some View {
        let sessions = limit.map { Array(trackerStore.todaySessions.prefix($0)) } ?? trackerStore.todaySessions

        if sessions.isEmpty {
            Text("No completed sessions yet today.")
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(18)
                .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        } else {
            VStack(spacing: 10) {
                ForEach(sessions) { session in
                    HStack(spacing: 14) {
                        Image(systemName: session.posture.symbolName)
                            .font(.headline)
                            .foregroundStyle(session.posture == .standing ? Color(red: 0.16, green: 0.50, blue: 0.37) : Color(red: 0.20, green: 0.39, blue: 0.63))
                            .frame(width: 36, height: 36)
                            .background(Color.white.opacity(0.8), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.posture.title)
                                .font(.headline)

                            Text(sessionRangeText(for: session))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(session.duration.formattedShortDuration)
                            .font(.headline.monospacedDigit())
                    }
                    .padding(14)
                    .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            if let currentPosture = trackerStore.currentPosture {
                let nextPosture = currentPosture == .sitting ? Posture.standing : Posture.sitting

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
                    Label("Stop Tracking", systemImage: "stop.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            } else {
                Button {
                    trackerStore.start(posture: .sitting)
                } label: {
                    Label("Start Sitting", systemImage: Posture.sitting.symbolName)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    trackerStore.start(posture: .standing)
                } label: {
                    Label("Start Standing", systemImage: Posture.standing.symbolName)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func pageHeader(title: String, subtitle: String) -> some View {
        HStack(alignment: .lastTextBaseline) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 34, weight: .bold, design: .rounded))

                Text(subtitle)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private func compactPreferenceStepper(
        title: String,
        value: Int,
        binding: Binding<Int>,
        range: ClosedRange<Int>
    ) -> some View {
        Stepper(value: binding, in: range, step: 5) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text("\(value) min")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .monospacedDigit()
            }
        }
    }

    private func metricCard(title: String, value: String, symbolName: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: symbolName)
                .font(.headline)
                .foregroundStyle(Color.accentColor)

            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.monospacedDigit().weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(18)
        .frame(maxWidth: .infinity, minHeight: 126, alignment: .leading)
        .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func summaryCard(for posture: Posture, color: Color) -> some View {
        let duration = trackerStore.todaySummary.duration(for: posture)
        let percentage = trackerStore.todaySummary.percentage(for: posture)

        return VStack(alignment: .leading, spacing: 14) {
            Label(posture.title, systemImage: posture.symbolName)
                .font(.headline)

            Text(duration.formattedShortDuration)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .monospacedDigit()

            Text("\(Int((percentage * 100).rounded()))% of tracked time")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.78))
        }
        .foregroundStyle(.white)
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func analyticsTile(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title3.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.62), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func analyticsStatusTile(title: String, value: Int, status: GoalStatus) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("\(value)")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(status.tint)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(status.tint.opacity(0.10), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func dayMetric(title: String, value: String, symbolName: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: symbolName)
                .foregroundStyle(Color.accentColor)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.headline.monospacedDigit())
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.56), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private func preferenceStepperRow(
        title: String,
        value: Int,
        symbolName: String,
        binding: Binding<Int>,
        range: ClosedRange<Int>,
        step: Int
    ) -> some View {
        Stepper(value: binding, in: range, step: step) {
            HStack(spacing: 12) {
                Image(systemName: symbolName)
                    .font(.headline)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 28)

                Text(title)
                    .font(.headline)

                Spacer()

                Text("\(value) min")
                    .font(.headline.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func statusBadge(for status: GoalStatus) -> some View {
        Text(status.title)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(status.tint.opacity(0.16), in: Capsule())
            .foregroundStyle(status.tint)
    }

    private func stopOrStartDefault() {
        if trackerStore.currentPosture == nil {
            trackerStore.start(posture: .sitting)
        } else {
            trackerStore.stopTracking()
        }
    }

    private func toggleHistoryDay(_ id: Date) {
        if expandedHistoryDayIDs.contains(id) {
            expandedHistoryDayIDs.remove(id)
        } else {
            expandedHistoryDayIDs.insert(id)
        }
    }

    private func historyTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) {
            return "Today"
        }

        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }

        return date.formatted(date: .abbreviated, time: .omitted)
    }

    private func shortDayLabel(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        }

        return date.formatted(.dateTime.weekday(.abbreviated))
    }

    private var standingMinutesBinding: Binding<Int> {
        Binding(
            get: { trackerStore.preferences.targetStandingBlockMinutes },
            set: { newValue in
                trackerStore.updatePreferences(
                    targetStandingBlockMinutes: newValue,
                    targetSittingBlockMinutes: trackerStore.preferences.targetSittingBlockMinutes,
                    defaultSnoozeMinutes: trackerStore.preferences.defaultSnoozeMinutes
                )
            }
        )
    }

    private var sittingMinutesBinding: Binding<Int> {
        Binding(
            get: { trackerStore.preferences.targetSittingBlockMinutes },
            set: { newValue in
                trackerStore.updatePreferences(
                    targetStandingBlockMinutes: trackerStore.preferences.targetStandingBlockMinutes,
                    targetSittingBlockMinutes: newValue,
                    defaultSnoozeMinutes: trackerStore.preferences.defaultSnoozeMinutes
                )
            }
        )
    }

    private var snoozeMinutesBinding: Binding<Int> {
        Binding(
            get: { trackerStore.preferences.defaultSnoozeMinutes },
            set: { newValue in
                trackerStore.updatePreferences(
                    targetStandingBlockMinutes: trackerStore.preferences.targetStandingBlockMinutes,
                    targetSittingBlockMinutes: trackerStore.preferences.targetSittingBlockMinutes,
                    defaultSnoozeMinutes: newValue
                )
            }
        )
    }

    private var statusText: String {
        guard let currentPosture = trackerStore.currentPosture else {
            return "No active posture"
        }

        return currentPosture.title
    }

    private var elapsedLabel: String {
        guard trackerStore.currentPosture != nil else {
            return "00:00:00"
        }

        return trackerStore.elapsedInCurrentPosture.formattedDuration
    }

    private var statusColor: Color {
        switch trackerStore.currentPosture {
        case .sitting:
            return Color(red: 0.20, green: 0.39, blue: 0.63)
        case .standing:
            return Color(red: 0.16, green: 0.50, blue: 0.37)
        case nil:
            return .secondary
        }
    }

    private var pageBackground: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.93, green: 0.95, blue: 0.94),
                Color(red: 0.88, green: 0.92, blue: 0.94),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func sessionRangeText(for session: TrackingSession) -> String {
        let start = session.startDate.formatted(date: .omitted, time: .shortened)
        let end = session.endDate.formatted(date: .omitted, time: .shortened)
        return "\(start) - \(end)"
    }
}

private enum AppPage: String, CaseIterable, Identifiable {
    case dashboard
    case history
    case analytics
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard:
            return "Dashboard"
        case .history:
            return "History"
        case .analytics:
            return "Analytics"
        case .settings:
            return "Settings"
        }
    }

    var symbolName: String {
        switch self {
        case .dashboard:
            return "square.grid.2x2.fill"
        case .history:
            return "clock.fill"
        case .analytics:
            return "chart.bar.xaxis"
        case .settings:
            return "gearshape.fill"
        }
    }
}

private extension View {
    func panelStyle() -> some View {
        padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.72), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private extension GoalStatus {
    var tint: Color {
        switch self {
        case .met:
            return Color(red: 0.16, green: 0.50, blue: 0.37)
        case .exceeded:
            return Color(red: 0.20, green: 0.39, blue: 0.63)
        case .notMet:
            return Color(red: 0.72, green: 0.43, blue: 0.12)
        case .insufficientData:
            return .secondary
        }
    }
}

private extension AlertKind {
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

    var formattedShortDuration: String {
        let totalSeconds = max(Int(self.rounded()), 0)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        }

        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }

        return "\(seconds)s"
    }
}
