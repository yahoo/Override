# Release Notes

## 2.5.0
- Add support for Swift Package Manager (SPM)

## 2.4.0
- Added a new convenience init that accepts a FeatureRegistry to FeaturesTableViewController to work around an assertion in UITableViewController

## 2.3.1
- Fixes non-responsive share button issue that arose due to overriding navigationItem in the release of iOS 13.4

## 2.3.0
- Ability to copy a readable string with a list of all displayed features, enabled, disabled or overriden features!
- Share button added to the UI
- Add scope bars to the default UI to filter enabled, disabled, and overridden features
- Search bar supports searching within scopes (see last point) on iOS 13+
- Fixed all linter issues
- Support for Swift 4.2 and 5.0 in the pod spec

## 2.2.0
- Add function for retrieving currently enabled features as an array of String objects

## 2.1.1
  - Bug Fixes
    - Search results do not have swipe actions

## 2.1.0
  - Bug Fixes
    - Fix bug that cuased non-functional "Delete" swipe action to appear on FeatureGroup
  - New Features
    - Add support for nested FeatureGroup
    - Search support
    - Internal refactor/simplifications

## 2.0.0
 - Add support for FeatureGroup - groups of features

## 1.1.2
 - Remove print statement from FeatureRegistry.extractFeatures

## 1.1.1
 - [tvOS] Fix feature changes not saved with provided tv UI

## 1.1.0
 - [tvOS] Add tvOS support

## 1.0.0
 - [iOS] Initial release, Swift feature flag management for iOS
