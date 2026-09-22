<img src="https://user-images.githubusercontent.com/40375449/182772693-77dd1386-8bf5-48d9-a877-7ab4a8fb8639.png" alt="Metrics icon" width="100"/>

### Metrics for Product Zone

A tracking system for metrics commonly used in the Product Zone of Apple Retail stores!

- Track your AppleCare+, business leads, connectivity, trade-in, and accessory attach progress throughout the day!
- Quickly log transactions on iPhone, iPad, and Apple Watch!
- Sync your data via iCloud and view historical trends on any device!
- Share your progress with others securely over iCloud!

## Quick Start
The app is designed for iOS and watchOS! To start up the app, you can either download and run the Xcode project or get it right from the [App Store](https://apps.apple.com/us/app/metrics-for-product-zone/id1581284514)!

Metrics 2.0 is built with SwiftUI, Swift Charts, Core Data with CloudKit, and WidgetKit. It requires iOS 26, iPadOS 26, and watchOS 26 or later, and builds with Xcode 26 or later.

## Building and Testing
- Open `Metrics.xcodeproj` and run the **Metrics** scheme for iPhone and iPad, or the **WatchMetrics** scheme for Apple Watch.
- The **MetricsTests** target covers the metric calculations, CloudKit record decoding, and Core Data round trips. Run it with ⌘U.
- To fill an empty store with three weeks of sample transactions in a Debug build, add `-seedSampleData` to the scheme's launch arguments.
- To test accepting a share in the simulator, which never hands share links to apps, launch a Debug build with `-acceptShareURL <link>` on a simulator signed into a different Apple Account than the owner.
- App Store screenshots come from the `ScreenshotTests` UI tests. Run them on the simulators App Store Connect wants (for example `xcodebuild test -scheme Metrics -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' -only-testing:MetricsUITests/ScreenshotTests -resultBundlePath Shots.xcresult`, with `TEST_RUNNER_HIDE_SHARING=1` in the environment to hide the Sharing section), export the captures with `xcrun xcresulttool export attachments --path Shots.xcresult --output-path Shots`, then frame each one with `Scripts/compose_screenshot.py <capture> <output> <width> <height> <headline>`.
- After changing the Core Data model, run a Debug build once with the `-initializeCloudKitSchema` launch argument to update the CloudKit development schema, then deploy the schema to Production in CloudKit Console before shipping.

## Support & Feedback

To view options for getting app support and leaving feedback, visit the [Support Center wiki page](https://github.com/BaBingoBango/Metrics-for-Product-Zone/wiki/Support-Center).

## Privacy Policy

To view the privacy policy for the app, visit the [Privacy Policy wiki page](https://github.com/BaBingoBango/Metrics-for-Product-Zone/wiki/Privacy-Policy).

## Licensing and Credit
Please see the information below about the third-party software used in the app:

- [Zephyr](https://github.com/ArtSabintsev/Zephyr) via the [MIT License](https://github.com/ArtSabintsev/Zephyr/blob/master/LICENSE)
