import Foundation
import Observation

enum Posture: String, Codable, CaseIterable, Identifiable {
    case sitting
    case standing

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sitting:
            return "Sitting"
        case .standing:
            return "Standing"
        }
    }

    var symbolName: String {
        switch self {
        case .sitting:
            return "chair.lounge.fill"
        case .standing:
            return "figure.stand"
        }
    }
}

enum SessionSource: String, Codable {
    case initialDefault = "initial_default"
    case manualStart = "manual_start"
    case manualSwitch = "manual_switch"
    case resumeAfterUnlock = "resume_after_unlock"
    case alertSwitch = "alert_switch"
    case restoredAfterRelaunch = "restored_after_relaunch"
    case midnightSplitContinuation = "midnight_split_continuation"
}

enum TrackingState: String, Codable {
    case setup
    case activeSitting = "active_sitting"
    case activeStanding = "active_standing"
    case lockedSitting = "locked_sitting"
    case lockedStanding = "locked_standing"
    case alertTimeToStand = "alert_time_to_stand"
    case alertTimeToSit = "alert_time_to_sit"
    case snoozedSitting = "snoozed_sitting"
    case snoozedStanding = "snoozed_standing"
    case stopped
}

enum AlertKind: String, Codable {
    case timeToStand = "time_to_stand"
    case timeToSit = "time_to_sit"
}

struct AlertState: Codable, Equatable {
    var currentAlertKind: AlertKind?
    var alertTriggeredAt: Date?
    var snoozeUntil: Date?
    var lastDismissedAt: Date?
    var isAlertVisible: Bool

    static let inactive = AlertState(
        currentAlertKind: nil,
        alertTriggeredAt: nil,
        snoozeUntil: nil,
        lastDismissedAt: nil,
        isAlertVisible: false
    )
}

struct UserPreferences: Codable, Equatable {
    var targetStandingBlockMinutes: Int
    var targetSittingBlockMinutes: Int
    var defaultSnoozeMinutes: Int
    var hasCompletedInitialSetup: Bool
    var lastUpdatedAt: Date

    static let `default` = UserPreferences(
        targetStandingBlockMinutes: 15,
        targetSittingBlockMinutes: 45,
        defaultSnoozeMinutes: 5,
        hasCompletedInitialSetup: false,
        lastUpdatedAt: Date()
    )

    var targetSittingShare: Double {
        let total = targetSittingBlockMinutes + targetStandingBlockMinutes
        guard total > 0 else { return 0 }
        return Double(targetSittingBlockMinutes) / Double(total)
    }

    var targetStandingShare: Double {
        let total = targetSittingBlockMinutes + targetStandingBlockMinutes
        guard total > 0 else { return 0 }
        return Double(targetStandingBlockMinutes) / Double(total)
    }

    var targetRatioText: String {
        let divisor = greatestCommonDivisor(targetStandingBlockMinutes, targetSittingBlockMinutes)
        let standingRatio = max(targetStandingBlockMinutes / divisor, 1)
        let sittingRatio = max(targetSittingBlockMinutes / divisor, 1)
        return "\(standingRatio) stand / \(sittingRatio) sit"
    }

    private func greatestCommonDivisor(_ lhs: Int, _ rhs: Int) -> Int {
        var a = max(abs(lhs), 1)
        var b = max(abs(rhs), 1)
        while b != 0 {
            let next = a % b
            a = b
            b = next
        }
        return max(a, 1)
    }
}

enum GoalStatus: String, Codable {
    case met
    case exceeded
    case notMet = "not_met"
    case insufficientData = "insufficient_data"

    var title: String {
        switch self {
        case .met:
            return "Met"
        case .exceeded:
            return "Exceeded"
        case .notMet:
            return "Not Met"
        case .insufficientData:
            return "Insufficient Data"
        }
    }
}

struct TrackingSession: Codable, Identifiable, Hashable {
    let id: UUID
    let posture: Posture
    let startDate: Date
    let endDate: Date
    let source: SessionSource
    let createdAt: Date

    var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }

    init(
        id: UUID = UUID(),
        posture: Posture,
        startDate: Date,
        endDate: Date,
        source: SessionSource,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.posture = posture
        self.startDate = startDate
        self.endDate = endDate
        self.source = source
        self.createdAt = createdAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case posture
        case startDate
        case endDate
        case source
        case createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        posture = try container.decode(Posture.self, forKey: .posture)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        source = try container.decodeIfPresent(SessionSource.self, forKey: .source) ?? .manualSwitch
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? endDate
    }
}

struct ActiveSession: Codable {
    let posture: Posture
    let startDate: Date
    let source: SessionSource

    init(posture: Posture, startDate: Date, source: SessionSource = .manualStart) {
        self.posture = posture
        self.startDate = startDate
        self.source = source
    }

    private enum CodingKeys: String, CodingKey {
        case posture
        case startDate
        case source
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        posture = try container.decode(Posture.self, forKey: .posture)
        startDate = try container.decode(Date.self, forKey: .startDate)
        source = try container.decodeIfPresent(SessionSource.self, forKey: .source) ?? .restoredAfterRelaunch
    }
}

struct DaySummary {
    static let minimumTrackedDuration: TimeInterval = 30 * 60
    static let goalTolerance = 0.05

    let sittingDuration: TimeInterval
    let standingDuration: TimeInterval
    let averageSitDuration: TimeInterval
    let averageStandDuration: TimeInterval
    let longestSittingDuration: TimeInterval
    let longestStandingDuration: TimeInterval
    let targetSittingShare: Double
    let targetStandingShare: Double
    let goalStatus: GoalStatus

    var totalDuration: TimeInterval {
        sittingDuration + standingDuration
    }

    func duration(for posture: Posture) -> TimeInterval {
        switch posture {
        case .sitting:
            return sittingDuration
        case .standing:
            return standingDuration
        }
    }

    func percentage(for posture: Posture) -> Double {
        guard totalDuration > 0 else { return 0 }
        return duration(for: posture) / totalDuration
    }

    init(
        sittingDuration: TimeInterval,
        standingDuration: TimeInterval,
        averageSitDuration: TimeInterval = 0,
        averageStandDuration: TimeInterval = 0,
        longestSittingDuration: TimeInterval = 0,
        longestStandingDuration: TimeInterval = 0,
        targetSittingShare: Double = 0,
        targetStandingShare: Double = 0,
        goalStatus: GoalStatus = .insufficientData
    ) {
        self.sittingDuration = sittingDuration
        self.standingDuration = standingDuration
        self.averageSitDuration = averageSitDuration
        self.averageStandDuration = averageStandDuration
        self.longestSittingDuration = longestSittingDuration
        self.longestStandingDuration = longestStandingDuration
        self.targetSittingShare = targetSittingShare
        self.targetStandingShare = targetStandingShare
        self.goalStatus = goalStatus
    }
}

struct DayHistory: Identifiable {
    let id: Date
    let date: Date
    let summary: DaySummary
    let sessions: [TrackingSession]
}

@Observable
final class TrackerStore {
    private enum StorageKeys {
        static let sessions = "sit-stand-sessions"
        static let activeSession = "sit-stand-active-session"
        static let preferences = "sit-stand-preferences"
        static let trackingState = "sit-stand-tracking-state"
        static let alertState = "sit-stand-alert-state"
    }

    var sessions: [TrackingSession] = []
    var activeSession: ActiveSession?
    var preferences = UserPreferences.default
    var trackingState = TrackingState.stopped
    var alertState = AlertState.inactive
    var now = Date()

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        load()
    }

    var currentPosture: Posture? {
        activeSession?.posture
    }

    var elapsedInCurrentPosture: TimeInterval {
        guard let activeSession else { return 0 }
        return now.timeIntervalSince(activeSession.startDate)
    }

    var todaySummary: DaySummary {
        let calendar = Calendar.current
        return summary(for: now, calendar: calendar)
    }

    var todaySessions: [TrackingSession] {
        let calendar = Calendar.current
        return sessions
            .filter { calendar.isDateInToday($0.startDate) }
            .sorted { $0.startDate > $1.startDate }
    }

    var targetRatioText: String {
        preferences.targetRatioText
    }

    var historyDays: [DayHistory] {
        let calendar = Calendar.current
        var dayStarts = Set(sessions.map { calendar.startOfDay(for: $0.startDate) })
        dayStarts.insert(calendar.startOfDay(for: now))

        if let activeSession {
            dayStarts.insert(calendar.startOfDay(for: activeSession.startDate))
        }

        return dayStarts
            .sorted(by: >)
            .map { dayStart in
                DayHistory(
                    id: dayStart,
                    date: dayStart,
                    summary: summary(for: dayStart, calendar: calendar),
                    sessions: sessions(for: dayStart, calendar: calendar)
                )
            }
    }

    func tick() {
        now = Date()
    }

    func start(posture: Posture) {
        let currentTime = Date()
        defer {
            now = currentTime
            persist()
        }

        guard let activeSession else {
            self.activeSession = ActiveSession(posture: posture, startDate: currentTime, source: .manualStart)
            trackingState = trackingState(for: posture)
            return
        }

        guard activeSession.posture != posture else {
            return
        }

        sessions.append(
            TrackingSession(
                id: UUID(),
                posture: activeSession.posture,
                startDate: activeSession.startDate,
                endDate: currentTime,
                source: activeSession.source,
                createdAt: currentTime
            )
        )
        self.activeSession = ActiveSession(posture: posture, startDate: currentTime, source: .manualSwitch)
        trackingState = trackingState(for: posture)
        alertState = .inactive
    }

    func stopTracking() {
        guard let activeSession else { return }

        let currentTime = Date()
        sessions.append(
            TrackingSession(
                id: UUID(),
                posture: activeSession.posture,
                startDate: activeSession.startDate,
                endDate: currentTime,
                source: activeSession.source,
                createdAt: currentTime
            )
        )
        self.activeSession = nil
        trackingState = .stopped
        alertState = .inactive
        now = currentTime
        persist()
    }

    func clearHistory() {
        sessions = []
        activeSession = nil
        trackingState = .stopped
        alertState = .inactive
        now = Date()
        persist()
    }

    func updatePreferences(
        targetStandingBlockMinutes: Int,
        targetSittingBlockMinutes: Int,
        defaultSnoozeMinutes: Int
    ) {
        preferences.targetStandingBlockMinutes = max(targetStandingBlockMinutes, 1)
        preferences.targetSittingBlockMinutes = max(targetSittingBlockMinutes, 1)
        preferences.defaultSnoozeMinutes = max(defaultSnoozeMinutes, 1)
        preferences.hasCompletedInitialSetup = true
        preferences.lastUpdatedAt = Date()
        persist()
    }

    private func load() {
        if let preferencesData = defaults.data(forKey: StorageKeys.preferences),
           let decodedPreferences = try? decoder.decode(UserPreferences.self, from: preferencesData) {
            preferences = decodedPreferences
        }

        if let sessionData = defaults.data(forKey: StorageKeys.sessions),
           let decodedSessions = try? decoder.decode([TrackingSession].self, from: sessionData) {
            sessions = decodedSessions
        }

        if let activeData = defaults.data(forKey: StorageKeys.activeSession),
           let decodedActiveSession = try? decoder.decode(ActiveSession.self, from: activeData) {
            activeSession = decodedActiveSession
        }

        if let trackingStateData = defaults.data(forKey: StorageKeys.trackingState),
           let decodedTrackingState = try? decoder.decode(TrackingState.self, from: trackingStateData) {
            trackingState = decodedTrackingState
        } else if let activeSession {
            trackingState = trackingState(for: activeSession.posture)
        }

        if let alertStateData = defaults.data(forKey: StorageKeys.alertState),
           let decodedAlertState = try? decoder.decode(AlertState.self, from: alertStateData) {
            alertState = decodedAlertState
        }

        now = Date()
    }

    private func persist() {
        if let encodedPreferences = try? encoder.encode(preferences) {
            defaults.set(encodedPreferences, forKey: StorageKeys.preferences)
        }

        if let encodedSessions = try? encoder.encode(sessions) {
            defaults.set(encodedSessions, forKey: StorageKeys.sessions)
        }

        if let encodedTrackingState = try? encoder.encode(trackingState) {
            defaults.set(encodedTrackingState, forKey: StorageKeys.trackingState)
        }

        if let encodedAlertState = try? encoder.encode(alertState) {
            defaults.set(encodedAlertState, forKey: StorageKeys.alertState)
        }

        if let activeSession,
           let encodedActiveSession = try? encoder.encode(activeSession) {
            defaults.set(encodedActiveSession, forKey: StorageKeys.activeSession)
        } else {
            defaults.removeObject(forKey: StorageKeys.activeSession)
        }
    }

    private func summary(for date: Date, calendar: Calendar) -> DaySummary {
        let daySessions = sessions(for: date, calendar: calendar)
        var sittingDuration = duration(for: .sitting, in: daySessions)
        var standingDuration = duration(for: .standing, in: daySessions)

        if let activeSession, calendar.isDate(activeSession.startDate, inSameDayAs: date) {
            switch activeSession.posture {
            case .sitting:
                sittingDuration += now.timeIntervalSince(activeSession.startDate)
            case .standing:
                standingDuration += now.timeIntervalSince(activeSession.startDate)
            }
        }

        let completedSittingSessions = daySessions.filter { $0.posture == .sitting }
        let completedStandingSessions = daySessions.filter { $0.posture == .standing }

        return DaySummary(
            sittingDuration: sittingDuration,
            standingDuration: standingDuration,
            averageSitDuration: averageDuration(for: completedSittingSessions),
            averageStandDuration: averageDuration(for: completedStandingSessions),
            longestSittingDuration: longestDuration(for: .sitting, on: date, in: daySessions, calendar: calendar),
            longestStandingDuration: longestDuration(for: .standing, on: date, in: daySessions, calendar: calendar),
            targetSittingShare: preferences.targetSittingShare,
            targetStandingShare: preferences.targetStandingShare,
            goalStatus: goalStatus(sittingDuration: sittingDuration, standingDuration: standingDuration)
        )
    }

    private func sessions(for date: Date, calendar: Calendar) -> [TrackingSession] {
        sessions
            .filter { calendar.isDate($0.startDate, inSameDayAs: date) }
            .sorted { $0.startDate > $1.startDate }
    }

    private func duration(for posture: Posture, in sessions: [TrackingSession]) -> TimeInterval {
        sessions
            .filter { $0.posture == posture }
            .reduce(0) { $0 + $1.duration }
    }

    private func averageDuration(for sessions: [TrackingSession]) -> TimeInterval {
        guard !sessions.isEmpty else { return 0 }
        return sessions.reduce(0) { $0 + $1.duration } / Double(sessions.count)
    }

    private func longestDuration(
        for posture: Posture,
        on date: Date,
        in sessions: [TrackingSession],
        calendar: Calendar
    ) -> TimeInterval {
        let completedLongest = sessions
            .filter { $0.posture == posture }
            .map(\.duration)
            .max() ?? 0

        guard let activeSession,
              activeSession.posture == posture,
              calendar.isDate(activeSession.startDate, inSameDayAs: date) else {
            return completedLongest
        }

        return max(completedLongest, now.timeIntervalSince(activeSession.startDate))
    }

    private func goalStatus(sittingDuration: TimeInterval, standingDuration: TimeInterval) -> GoalStatus {
        let totalDuration = sittingDuration + standingDuration
        guard totalDuration >= DaySummary.minimumTrackedDuration else {
            return .insufficientData
        }

        let actualStandingShare = standingDuration / totalDuration
        let lowerBound = preferences.targetStandingShare - DaySummary.goalTolerance
        let upperBound = preferences.targetStandingShare + DaySummary.goalTolerance

        if actualStandingShare < lowerBound {
            return .notMet
        }

        if actualStandingShare > upperBound {
            return .exceeded
        }

        return .met
    }

    private func trackingState(for posture: Posture) -> TrackingState {
        switch posture {
        case .sitting:
            return .activeSitting
        case .standing:
            return .activeStanding
        }
    }
}
