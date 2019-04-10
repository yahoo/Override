# Override

## Table of Contents

- [Background](#background)
- [Installation](#installation)
- [Usage](#Usage)
- [Feature Management UI](#feature-management-ui)
- [Test Support](#unit-test-support)
- [Running The Examples](#running-the-examples)
- [Contribute](#contribute)
- [Maintainers](#maintainers)
- [License](#license)

## Background

Override is a super easy to use feature flag management system for iOS, tvOS, watchOS and macOS. Override helps minimize the boilerplate involved with adding and maintaining large sets of feature flags. Typically app developers employ feature flags to manage access to feature which are still in development, experimental, or behind an A/B test. Having a streamlined feature flag management process helps promote innovation by removing roadblocks to new experiments.

Feature flags typically have 3 states: on, off, or defaulted. The default state of a feature may be a preset mode or defined by a remote configuration or A/B testing system. Override supports these use cases, and more!

## Installation

### CocoaPods

CocoaPods is a dependency manager for Cocoa projects. For usage and installation instructions, [visit their website](https://cocoapods.org). To integrate Override into your Xcode project using CocoaPods, specify it in your Podfile:

`pod 'YMOverride', '~> 1.0'`

## Usage

To use Override, you need a subclass of FeatureRegistry. Override will examine your registry class for instance properties that are a kind of the `AnyFeature`.

### Basic Features

Let's create a basic feature called "blueText" which turns all text blue when enabled. To do this, add a property called `blueText` to your feature registry:

```swift
import YMOverride

@objc class Features : FeatureRegistry {

    @objc let blueText = Feature()
}
```

There is a heck of a lot provided by this simple class, but we'll get into that later. Let's see how to use this feature to detect if the `blueText` feature is enabled. Here's some code you can imagine in your app:

```swift
class ViewController : UIViewController {

    let myFeatures = Features()

    let label = UILabel()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.addSubview(label)
        label.frame = view.frame
        label.text = "Hello World!"

        // Update text color based on feature flag
        label.textColor = myFeatures.blueText ? .blue : .green
    }
}
```

### Controlling Feature Flags

Continuing with our example, the next thing you probably want to know is how to control the `.enabled` property of your features. Well, you can't! Not directly, at least. This is because `.enabled` is boolean, meaning it has just two states (true and false). Feature flags, on the other hand, have _four distinct states_: On, Off, Overridden-On and Overridden-Off.

For the most part, your app code will only care about two the basic states `on` and `off` (which is why `.enabled` is boolean). It just makes your if-statements simpler. However when you manually enable or disable a feature flag, that needs to be tracked so that the original state can be restored later on. This will become **very important** later on when we discuss Dyanmic Features.

Lets see how to manually turn on `blueText` at runtime.
```swift
    @objc func toggleBlueTextButtonTapped() {
        // Turn blueText ON
        myFeatures.blueText.override = .enabled
    }
```

After the code above is executed, the feature `blueText` is enabled. That is to say, the text will be blue the next time out example viewWillAppear executes `label.textColor = myFeatures.blueText ? .blue : .green`. Cool!

Similarly to turn blueText OFF regardless of it's default state, we could change the value to `.disabled` like this
```swift
    @objc func toggleBlueTextButtonTapped() {
        // Turn blueText ON
        myFeatures.blueText.override = .disabled
    }
```

And to if we wanted to remove any customization and return the feature flag to it's default state:
```swift
    @objc func toggleBlueTextButtonTapped() {
        // Turn blueText OFF
        myFeatures.blueText.override = .featureDefault
    }
```

### Default Feature State

Ok, so far we know how to test the value of a feature flag, and how to override a feature flag's state. The next bit we need to understand is how to define what the initial state of a feature flag should be. By default, feature flags are turned off, and you can turn them on when needed.

Let's create a feature that is normally off, and turned on only for debugging:
```swift
@objc class Features : FeatureRegistry {

    @objc let blueText = Feature()

    @obj let debugLogging = Feature(defaultState: false)
}
```

### Features Requiring Restart

It would be fantastic if all of our feature flags took effect immediately. In reality, many features are so fundamental that they cannot be enabled or disabled without a restart of the app. While Override will _never_ restart your app on your behalf, it does provide a method to model this requirement. Let's add a feature that requires a restart...

```swift
@objc class Features : FeatureRegistry {

    @objc let blueText = Feature()

    @obj let debugLogging = Feature(defaultState: false)

    @objc let useTabBarNav = Feature(requiresRestart: true) 
}
```

Now when you change `useTabBarNav`, you can check the boolean property `useTabBarNav.requiresRestart` to determine if a restart is need, and handle this appropriately in your app code.

### [Advanced] Derived and Dynamic Features

Sometimes, there is a need for a feature which defaults to on or off depending on aspects of the runtime environment. Let's say you want to turn a feature on by default, but only on Tuesdays! We can accomplish this by using the `DynamicFeature` type.

```swift
@objc class Features : FeatureRegistry {

    @objc let blueText = Feature()

    @obj let debugLogging = Feature(defaultState: false)

    @objc let useTabBarNav = Feature(requiresRestart: true) 

    @objc let tuesdayExperiment = DynamicFeature() { _ in
        let components = Calendar.current.dateComponents(Set([.weekday]), from: Date())
        return components.weekday == 3
    }
}
```

The block provided to `DynamicFeature` is evaluated every time the default state is needed, so the value can change if you'd like, or you can cache it for performance!

### [Advanced] Remote Controlled Features

Up until now we have discussed local features which only exist in the context of a single app. Many apps use remotely controlled feature flag services and experimentation platforms. Luckily, Override can easily support this using `DynamicFeatures`.

As an exercise, let's see what it would look like to create an Override wrapper for [Flurry's FConfig](https://developer.yahoo.com/flurry/docs/config/configmanagement/) remote config functionality ([Souce Code](https://github.com/flurry/flurry-ios-sdk/blob/master/FlurryConfig/FConfig.h)):

```swift
@objc class FConfigFeature : DynamicFeature {

    init(key: String? = nil, requiresRestart: Bool = false, configDefault: Bool = false) {

        // Delegate to FConfig, using the provided default parameter as FConfig default.
        super.init(key: key, requiresRestart: requiresRestart) { (feature: AnyFeature) -> Bool in
            return FConfig.sharedInstance.getBool(forKey: feature.key, withDefault: configDefault)
        }
    }
}
```

Now using `FConfigFeature` in our feature registry is just more of the same:

```swift
@objc class Features : FeatureRegistry {

    @objc let blueText = Feature()

    @obj let debugLogging = Feature(defaultState: false)

    @objc let useTabBarNav = Feature(requiresRestart: true) 

    @objc let tuesdayExperiment = DynamicFeature() { _ in
        let components = Calendar.current.dateComponents(Set([.weekday]), from: Date())
        return components.weekday == 3
    }

    // FConfig backed feature
    @objc let redButtons = FConfigFeature()
}
```

### Feature Management UI

Override ships with a simple table view controller – `FeaturesViewController` – that provides a generic user interface for managing feature flags. The view controller shows a list of available features from a given `FeatureRegistry`. Each feature state is depicted visually, and swipe gestures are installed that allow for convienant feature control.

Feature state is conveyed visually:
- Overridden *enabled* features are in green
- Overridden *disabled* features are shown in red
- Underlined features – which are either green or red – are overriding the defaults

Feature state is controlled by gesture:
- Slide left to reveal the "on" and "off" force overrides
- Slide right to restore the default state of the feature

#### Support "Restart Required" Features

Sometimes enabling or disabling a feature is unsafe or impractical to do after the app has finished loading.
To support these cases, the `FeaturesViewController` is aware of the `restartRequired` parameter in all of its displayed features.

Prior to dismissing `FeaturesViewController`, it is the responsability of the calling app to handle any restart requirements. There are two ways to do this:
1. _Automatic Handling_: Invoke the `presentRestartAlert(from:completion:)` method prior to dismissing the `FeaturesViewController`, and only actually dismiss the view controller in the completion handler.
2. _Manual Handling_: Check the value of the `featuresRequiringRestart` property, and manually trigger a restart if the list is not-empty.  

## Test Support

Rich unit test support is an absolute must for any feature control system. Developers generally want to test features in both the on and off states. Override enables this with the `FeatureTestSupport` class.

### Test Setup

Tests support is provided in a separate CocoaPod framework. To include Override test support,
add the pod `OverrideTestSupport` to your test target as shown below:

```ruby
OverridePodVersion = '1.0.0'

target 'MyApp' do
    pod 'Override', OverridePodVersion

    target 'MyAppTests' do
        pod 'OverrideTestSupport', OverridePodVersion
    end
end
```

### Using Unit Test Helpers

Override simplifies the task of testing your feature matrix. Instead of mocking or manually overriding features, Override provides a utility which selectively enables or disables features for a specific test.

```swift
describe("sans serif font experiment") {
    it("respects the enabled flag") {
        withFeature(features.useSansSerifFont).enabled {
            // test or snapshot test for enabled state
        }
    }

    it("respects the enabled flag") {
        withFeature(features.useSansSerifFont).disabled {
            // test or snapshot test for disabled state
        }
    }
}
```

Additionally, Override makes it easy to enable or disable many features at once using `withFeatures()` like this:

```swift
it("works with all experiments disabled") {
    withFeatures([features.useSansSerifFont, features.betaOnboarding]).enabled {
        // test with all listed features enabled
    }
}
```

The testing support works with Objective-C as well, using a similar syntax as shown below:

```objc
// (Just adds @ on the array literal, and `^()` after .enabled)
it(@"works with all experiments disabled"), {
    withFeature(features.useSansSerifFont).enabled(^{
        // ...
    });
});
```

## Running The Examples

To run the example projects, clone the repo, and run `pod install` from the Example-Swift of Example-ObjC directory first.

## Contribute

Please refer to [the contributing.md file](Contributing.md) for information about how to get involved. We welcome issues, questions, and pull requests. Pull Requests are welcome.

## Maintainers

- [Adam Kaplan](https://github.com/adamkaplan), Twitter: [@adkap](https://twitter.com/adkap)
- [David Grandinetti](https://github.com/dbgrandi), Twitter: [@dbgrandi](https://twitter.com/dbgrandi)

## License

This project is licensed under the terms of the [MIT](LICENSE-MIT) open source license. Please refer to [LICENSE](LICENSE) for the full terms.
