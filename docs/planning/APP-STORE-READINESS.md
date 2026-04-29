# App Store Readiness

## Current State

SitStandTracker is currently a Swift Package executable. It runs with:

```bash
swift run SitStandTracker
```

That is good for development, but the Mac App Store expects a signed, sandboxed macOS app bundle produced from an app target/archive workflow.

## App Icon

The app icon should be added to an Xcode asset catalog as an `AppIcon` set.

Apple's App Store Connect help says app icons can be created with Icon Composer or added to an asset catalog in Xcode, then included in an uploaded build.

Source image needed:

- Save the provided icon image as a local PNG, preferably `1024 x 1024`.
- Suggested repo path: `Assets/AppIconSource.png`
- After the app target exists, generate an `AppIcon.appiconset` from that source and assign it as the target's app icon.

The image shared in chat is not yet present as a repo file, so it has not been committed as an app icon.

## Required App Target Work

Before App Store submission, create a proper macOS app target in Xcode.

Recommended target settings:

- Product name: `SitStandTracker`
- Bundle identifier: your reverse-DNS identifier, for example `com.example.SitStandTracker`
- Minimum macOS version: currently `14.0`
- App icon: `AppIcon`
- Signing team: your Apple Developer team
- Version: marketing version such as `1.0`
- Build: incrementing build number such as `1`

The existing Swift files can remain the app implementation. The packaging layer needs to become an Xcode app target.

## Sandbox And Entitlements

Mac App Store apps must enable App Sandbox.

For the current local-only tracker, start with the minimum sandbox entitlement:

- `com.apple.security.app-sandbox = true`

Avoid temporary exception entitlements unless absolutely necessary.

Areas to verify under sandbox:

- `UserDefaults` persistence
- menu bar extra behavior
- screen-lock notifications
- app activation and close-to-menu-bar behavior

## Privacy

App Store Connect requires privacy details for app submissions.

Current expected privacy posture:

- no account
- no network sync
- no third-party SDKs
- posture/session data stored locally
- no tracking

Verify this before submission and answer App Privacy questions accordingly.

If a future version adds analytics, crash reporting, cloud sync, or telemetry, update privacy answers and add any required privacy manifest details.

## Screenshots And Metadata

Mac app screenshots are required. App Store Connect currently accepts Mac screenshots with a 16:10 aspect ratio at these sizes:

- `1280 x 800`
- `1440 x 900`
- `2560 x 1600`
- `2880 x 1800`

Prepare:

- app name
- subtitle if desired
- description
- keywords
- support URL
- privacy policy URL if needed
- category
- age rating
- copyright
- screenshots

## Archive And Upload

Once the app target exists:

1. Select the app scheme in Xcode.
2. Choose a release signing team.
3. Confirm App Sandbox is enabled.
4. Confirm the app icon appears in the built app.
5. Product > Archive.
6. Validate the archive.
7. Upload to App Store Connect.
8. Complete metadata and submit for review.

## Useful Apple References

- App icon: https://developer.apple.com/help/app-store-connect/manage-app-information/add-an-app-icon/
- App Sandbox: https://developer.apple.com/documentation/security/app-sandbox
- Configuring macOS App Sandbox: https://developer.apple.com/documentation/xcode/configuring-the-macos-app-sandbox
- App privacy details: https://developer.apple.com/app-store/app-privacy-details/
- Privacy manifests: https://developer.apple.com/documentation/bundleresources/adding-a-privacy-manifest-to-your-app-or-third-party-sdk
- Screenshot specifications: https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications

