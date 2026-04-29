# SitStandTracker Spec

## 1. Executive Summary

SitStandTracker is a native macOS app that helps a desk worker alternate between sitting and standing during active computer time. The app combines a full dashboard window with a persistent menu bar presence so posture tracking stays available even when the main window is closed.

The first release should optimize for speed, clarity, and low friction rather than deep health analytics. The user should be able to set a simple work cycle, start tracking immediately, receive lightweight menu bar transition prompts, and review how closely the day matched the intended sit/stand rhythm.

## 2. Product Goals

- Make posture tracking feel effortless during a workday.
- Help the user alternate sitting and standing according to a simple work cycle.
- Show clear daily totals and ratio status for active tracked time.
- Preserve tracking history locally without requiring sign-in or a backend.
- Make quick posture switching available from the macOS menu bar.

## 3. Non-Goals

- Team reporting or shared dashboards
- Cloud sync across devices
- Detailed health coaching or medical guidance
- Calorie tracking
- Complex charts beyond focused local analytics
- Watch, iPhone, or web companion apps in the first release

## 4. Target User

The primary user is an individual Mac user who works at a desk and wants a lightweight way to alternate between sitting and standing while actively working.

## 5. Core User Stories

1. As a user, I want to set a simple sit/stand cycle so the app matches how I work.
2. As a user, I want to switch posture with one click so the app fits naturally into my routine.
3. As a user, I want the app to prompt me when I have sat or stood too long.
4. As a user, I want to see my posture balance for today and whether I stayed close to my target ratio.
5. As a user, I want my sessions to persist if I close and reopen the app so I do not lose my history.

## 6. MVP Scope

### Included

- Native macOS app built with SwiftUI
- Hybrid app model: standard window plus menu bar access
- Sidebar pages for `Dashboard`, `History`, `Analytics`, and `Settings`
- Two posture states: `Sitting` and `Standing`
- Start tracking by selecting a posture
- Switch posture at any time
- Stop tracking the active posture
- Automatic stop on screen lock and automatic resume on unlock
- Live timer for the current posture
- Daily totals and ratio status for sitting and standing
- Session list for the current day
- Local persistence on device
- Background availability while the app remains open
- Menu bar transition alerts when the user has stayed in one posture too long

### Excluded

- System notification banners by default
- Multi-device sync
- Export to CSV or HealthKit
- Break as a first-class posture type
- Tags, notes, or custom posture types

## 7. Functional Requirements

### 7.1 Work Cycle

- The app must let the user define one paired work cycle:
  - stand for `X` minutes
  - after sitting for `Y` minutes
- The app must derive both alert directions from that one pair:
  - after `Y` minutes of sitting, prompt standing
  - after `X` minutes of standing, prompt sitting
- The app must derive the daily target ratio from the same `X/Y` pair.

### 7.2 Posture Tracking

- The app must allow the user to choose `Sitting` or `Standing`.
- If no posture is active, selecting a posture starts a new active session.
- If a different posture is selected while one is active, the current session ends and a new session begins immediately for the new posture.
- If the same posture is selected while already active, the app should not create a duplicate session.
- The user must be able to stop tracking, which closes the current session without starting a new one.

### 7.3 Screen Lock Behavior

- When the screen locks, the app must stop active posture tracking.
- Screen-locked time must not count toward sitting totals, standing totals, streaks, ratios, or alerts.
- When the screen unlocks, the app must automatically resume tracking in the same posture that was active before the lock.
- A screen lock must not count as a posture transition.

### 7.4 Time And Goal Display

- The app must show the elapsed time for the active posture in real time.
- The app must show total sitting time for the current day.
- The app must show total standing time for the current day.
- The app must show the relative share of tracked active time for each posture.
- The app must show whether the day met, exceeded, or did not meet the target ratio.

### 7.5 Session History

- The app must show a list of completed sessions for the current day.
- Each session entry should include posture type, start time, end time, and duration.
- Sessions should be sorted with the most recent first.
- The app must support browsing prior days locally.
- The history page should visually distinguish whether each day met, exceeded, or did not meet the target ratio.

### 7.6 Persistence

- The app must persist completed sessions locally on the device.
- The app must persist enough runtime state to restore same-day behavior after relaunch.
- The app may use `UserDefaults` for MVP persistence.

### 7.7 Menu Bar And Background Behavior

- The app must expose a menu bar item while it is running.
- The menu bar item must let the user see the current posture and elapsed time at a glance.
- The menu bar item must let the user switch posture without opening the main window.
- The menu bar item must let the user stop tracking.
- Closing the main window must not stop tracking if the app is still running in the menu bar.
- The user must be able to quit the app explicitly from the menu bar or main application menu.
- In the normal non-alert state, clicking the menu bar item should open a compact active-session panel.
- The active-session panel should show the current posture, large elapsed timer, target-ratio text, a switch-posture action, a stop-tracking action, today's current-posture total, and longest streak.

### 7.8 Transition Alerts

- When the active posture exceeds its configured threshold, the menu bar item must visibly change state.
- The alert state for `time to stand` must look different from the alert state for `time to sit`.
- The alert treatment may vary by icon, accent color, badge, or symbol, but the two transitions must be distinguishable at a glance.
- When a threshold is reached, the app should expose a compact quick-action panel from the menu bar.
- The alert panel must include:
  - the recommended transition action
  - a short snooze option such as `+5 min`
  - a dismiss action
- Choosing the recommended transition action must immediately switch the posture and start the next session.
- Dismissing or snoozing an alert must not delete the active session.

## 8. UX Requirements

### 8.1 Main Window

The main window should contain:

- sidebar navigation for `Dashboard`, `History`, `Analytics`, and `Settings`
- current status
- large live timer
- two posture controls
- stop control
- a cycle-goal summary area
- daily summary tiles
- recent activity

### 8.2 Dashboard Metrics

The MVP dashboard tiles should be:

- `Avg Sit`
- `Avg Stand`
- `Sit Streak`
- `Stand Streak`

### 8.3 History

The history page should:

- group sessions by day
- default to newest days first
- show a day-level badge for `Met`, `Exceeded`, or `Not Met`

### 8.4 Analytics

The analytics page should stay narrow and useful. It should include:

- recent-days ratio chart
- counts of `Met`, `Exceeded`, and `Not Met` days
- average active tracked time
- average sit session length
- average stand session length

### 8.5 Settings

The settings page should contain:

- stand duration
- sit duration
- default snooze duration
- reset data control

### 8.6 Empty States

- If there is no active posture, the app should clearly prompt the user to start tracking.
- If there are no completed sessions today, the history area should explain that no sessions have been recorded yet.

## 9. Data Model Summary

The MVP data model should cover:

- user preferences for the work cycle
- runtime tracking state
- alert state
- completed posture sessions
- derived daily summaries

## 10. State Rules

- There can be at most one active posture session at a time.
- Completed sessions are immutable after they are stored.
- Daily totals include completed sessions plus the currently active session if it belongs to today.
- If the date changes while the app is open, active posture may continue across midnight, but reporting must split at the day boundary.
- Tracking continues when the main window is closed, as long as the app remains running from the menu bar.
- Screen-locked time is excluded from active tracked ratios and totals.

## 11. Technical Approach

- Platform: macOS
- UI framework: SwiftUI
- Local state and domain logic: in-app store or view model
- Persistence: `UserDefaults` with Codable models
- Timer updates: one-second UI refresh for active elapsed time
- App structure: main window plus menu bar extra

## 12. Success Criteria

- A user can begin tracking within 5 seconds of opening the app.
- Switching posture requires one click.
- Menu bar alerts are understandable without opening the dashboard.
- Same-day relaunch restores prior sessions and state accurately.
- The user can understand today’s posture balance and goal status at a glance.
