# SitStandTracker Startup UI

## Source Of Truth

The startup experience should follow the supplied reference layout closely. This screen establishes the visual language for the app and should be treated as the default dashboard shown when the app opens.

## Screen Structure

The startup screen is a single desktop dashboard with five primary regions:

1. Left navigation rail
2. Main current-status card
3. Right-side goal card
4. Metrics row
5. Recent activity panel

## 1. Left Navigation Rail

### Content

- App name: `Tracker`
- Session subtitle: `Productive Session`
- Navigation items:
  - `Dashboard`
  - `History`
  - `Analytics`
  - `Settings`

### Behavior

- `Dashboard` is selected on launch.
- The other items are real pages in MVP, not placeholders.

## 2. Current Status Card

This is the primary focal point of the screen.

### Content

- Section title: `Current Status`
- Small status indicator and label such as `Standing`
- Large central elapsed timer
- Small secondary line such as `Target ratio: 1 stand / 3 sit`
- Top-right circular action button

### Primary Actions

- Main CTA: `Switch to Sitting` when currently standing
- Secondary CTA: `Stop Tracking`

### Visual Guidance

- This card should be the largest card on the screen.
- The timer should be the dominant text element.
- The active posture state should use green as the positive accent.

## 3. Goal Card

The goal card sits to the right of the current status card and should feel editable but lightweight.

### Content

- Title: `Daily Goal`
- Goal sentence in a form-like layout
- Example:
  - `Stand for 15 minutes`
  - `after 45 minutes of sitting`
- Derived ratio line:
  - `Target ratio: 1 stand / 3 sit`

### Interaction

- The minute values should appear editable.
- MVP can treat these as simple text inputs or steppers.
- This single pair of values defines both alert directions:
  - after `45` minutes of sitting, prompt standing
  - after `15` minutes of standing, prompt sitting

## 4. Metrics Row

The row below the hero area shows compact daily stats.

### Tiles

- `Avg Sit`
- `Avg Stand`
- `Sit Streak`
- `Stand Streak`

### Notes

- These should be compact summary cards.
- Do not include calorie tracking.
- Do not include a transitions tile in MVP.

## 5. Recent Activity Panel

This panel lists recent posture sessions in reverse chronological order.

### Header

- Title: `Recent Activity`
- Right-aligned link: `View All`

### Row Content

Each row should show:

- posture label
- time range
- duration aligned to the right

Example rows:

- `Sitting` with `10:15 AM - 11:00 AM` and `45m`
- `Standing` with `09:00 AM - 10:15 AM` and `1h 15m`
- `Sitting` with `08:20 AM - 08:45 AM` and `25m`

## 6. Goal Status Treatment

The history and analytics surfaces should visually distinguish day-level status:

- `Met`
- `Exceeded`
- `Not Met`

Recommended MVP rule:

- status is based on actual standing share versus target standing share
- use a `+/- 5 percentage point` tolerance band
- do not rely on color alone; pair status color with text badge

## 7. Launch-State Requirements

When the app starts and there is an active session:

- The dashboard opens directly to this layout.
- `Dashboard` is selected in the sidebar.
- The current posture is shown in the status card.
- The timer is already running.
- The main CTA reflects the opposite posture.
- Recent activity is already populated if session history exists.

When the app starts and there is no active session:

- Keep the same layout.
- Show a neutral status in the main card.
- Replace the main CTA with `Start Sitting` and `Start Standing`, or show one primary start action and one secondary alternative.

## 8. Menu Bar Companion

While the startup dashboard is the primary full-window surface, the app should also present a menu bar companion.

### Normal State

Clicking the menu bar item should open a compact active-session panel with:

- current posture title
- `ACTIVE SESSION` subtitle
- large timer
- target ratio text
- switch-posture button
- stop-tracking button
- today's current-posture total
- longest streak

### Alert State

When a threshold is reached, the menu bar should:

- change the menu bar icon or state
- use different visual treatments for `time to stand` and `time to sit`
- open a compact action panel with switch, snooze, and dismiss controls
- echo today's totals so the alert still feels connected to the dashboard
