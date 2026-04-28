# Phase 9 Handoff

## Purpose

This document records what Phase 9 completed, what remains incomplete, and what later polish work should verify.

Refer to `PROJECT-PLAN.md` for the full phased roadmap and the prior phase handoff files for earlier implementation context.

## Phase 9 Scope

Phase 9 implemented screen-lock suspend/resume behavior and day-boundary accounting.

The focus was correct tracked-time semantics:

- locked time should not count
- unlocking should resume the prior posture
- sessions and summaries should behave correctly across midnight

## Files Changed

- `Sources/SitStandTracker/TrackerStore.swift`
- `Sources/SitStandTracker/SitStandTrackerApp.swift`
- `PROJECT-PLAN.md`

## Completed

### Screen Lock API

`TrackerStore` now exposes:

```swift
func handleScreenLocked()
func handleScreenUnlocked()
```

### Lock Behavior

When the screen locks and an active session exists:

1. the active session is closed at lock time
2. any session crossing midnight is split into day-sized segments
3. `activeSession` is cleared
4. tracking state becomes:
   - `.lockedSitting`
   - `.lockedStanding`
5. alert state is cleared
6. state is persisted

This prevents locked time from counting toward:

- sitting totals
- standing totals
- ratios
- streaks
- alerts

### Unlock Behavior

When the screen unlocks from a locked posture state:

1. a new active session starts at unlock time
2. the prior posture is restored
3. source is set to `.resumeAfterUnlock`
4. tracking state returns to:
   - `.activeSitting`
   - `.activeStanding`
5. alert state remains clear
6. state is persisted

### macOS Lock Notifications

`AppDelegate` now observes distributed macOS notifications:

```swift
com.apple.screenIsLocked
com.apple.screenIsUnlocked
```

Those notifications call the store lock/unlock APIs.

### Completed Session Splitting

Completed sessions are now appended through a helper that splits sessions crossing midnight.

First segment keeps the original source.

Continuation segments use:

```swift
SessionSource.midnightSplitContinuation
```

This applies when sessions close due to:

- posture switch
- stop tracking
- screen lock

### Day-Overlap Summaries

Daily summaries now calculate duration by overlap with the requested local day rather than only by session start date.

This improves correctness for:

- legacy unsplit sessions
- active sessions crossing midnight
- completed sessions crossing midnight

### History Day Coverage

`historyDays` now collects every day overlapped by completed sessions and active sessions.

This allows history to show both sides of a midnight-spanning session.

## Verified

`swift build` passed after Phase 9 changes.

## Manual Verification Still Needed

Screen lock/unlock behavior should be manually smoke-tested in the running app:

1. start tracking sitting or standing
2. lock the screen
3. wait at least a few seconds
4. unlock
5. confirm tracking resumes in the prior posture
6. confirm locked time does not appear in totals
7. confirm alert state is not restored immediately after unlock

Midnight behavior is implemented but should be tested with controlled dates or a future test target.

## Intentionally Left Incomplete

### Automated Tests

No test target exists yet.

The new date-overlap logic is important enough that Phase 10 should consider adding tests for:

- completed session within one day
- completed session crossing midnight
- active session crossing midnight
- lock closes active session
- unlock resumes prior posture
- locked time exclusion

### Historical Preference Snapshots

As before, goal status for prior days is still evaluated against current preferences.

Phase 9 did not change that behavior.

### UI Lock Indicator

When the screen is locked, the UI is not visible. After unlock, tracking resumes.

If the app is somehow viewed while in a locked state, the current UI may look like no posture is active because `activeSession` is intentionally nil while locked.

This is acceptable for MVP, but a future UI polish pass could display the locked posture state explicitly.

## Notes For Phase 10

Phase 10 should focus on:

- README updates
- stale mockup path cleanup
- manual smoke test checklist
- possible test target for store logic
- accessibility and UI fit checks after longer second-aware duration strings

