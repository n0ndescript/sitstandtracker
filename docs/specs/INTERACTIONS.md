# SitStandTracker Interaction Notes

## 1. Goal

Define the day-to-day interaction model for the hybrid macOS app so the menu bar behavior, main window behavior, and app lifecycle feel intentional before implementation starts.

## 2. Product Shape

SitStandTracker should behave like a lightweight utility app:

- It has a normal main window for detailed viewing and settings.
- It also has a persistent menu bar item for quick actions.
- Tracking continues while the app remains open, even if the main window is closed.

## 3. Menu Bar Design

### 3.1 Menu Bar Label

The menu bar item should be compact and glanceable.

Recommended MVP behavior:

- Show a posture icon.
- Show a short timer when tracking is active.
- Show a neutral idle indicator when no posture is active.
- When a transition threshold is reached, switch to a distinct alert-state icon treatment.

### 3.2 Display Rules

- Use an SF Symbol that changes by posture.
- Show hours and minutes in the menu bar for compactness.
- Avoid showing full seconds in the menu bar.
- Use different alert styling for sit-to-stand and stand-to-sit so the user can tell which action is being requested without opening the panel.

## 4. Menu Bar Panels

### 4.1 Normal Panel

Clicking the menu bar item in the normal state should open a compact session panel.

It should show:

- current posture
- `ACTIVE SESSION`
- large elapsed timer
- target ratio line such as `Target ratio: 1 stand / 3 sit`
- primary switch action for the opposite posture
- stop-tracking action
- today's total for the current posture
- longest streak

### 4.2 Alert Panel

When the user has stayed in the active posture longer than the configured threshold, the menu bar interaction should present an alert panel.

It should show:

- `Time to Stand` or `Time to Sit`
- large timer
- explanatory sentence
- primary switch action
- snooze button
- dismiss button
- today’s sit and stand totals

## 5. Main Window

The main window is the detailed surface for review and management.

It should answer:

- What am I doing right now?
- How long have I been doing it?
- How balanced has today been?
- What sessions have I logged today?

## 6. Dock And Window Behavior

### 6.1 Recommended MVP Behavior

The app should show a normal Dock icon only while the main window is open.

Reason:

- it keeps the app discoverable when the dashboard is visible
- it lets the app behave like a menu bar utility when the window is closed
- it matches the desired close-to-menu-bar behavior

### 6.2 Window Close Behavior

Closing the main window should:

- Hide the main window
- Keep the app running
- Keep the menu bar item active
- Hide the Dock icon
- Keep posture tracking active

The app should not quit when the main window closes.

### 6.3 Reopening The Window

The user should be able to reopen the main window by:

- Clicking `Open Dashboard` from the menu bar
- Using the app from Spotlight or Launchpad if needed

## 7. Launch Behavior

Recommended MVP launch behavior:

- Launch into the main window on first open
- Always create the menu bar item when the app launches
- If the app is reopened later during the day, restore the prior active session if one exists

## 8. Suggested MVP Decisions

1. Use a compact menu bar label with icon plus `HH:MM`.
2. Use a compact session panel for normal state, but an alert-style panel when a transition threshold is reached.
3. Hide the Dock icon when the window is closed.
4. Keep running after the main window closes.
5. Use `Open Dashboard` and `Quit` as the only secondary menu actions.
6. Distinguish `time to stand` and `time to sit` with different menu bar alert states.
