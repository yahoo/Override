// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Quick
import Nimble
@testable import YMOverride

class DynamicFeatureRegistrySpec: QuickSpec {

    override func spec() {

        describe("Dynamic Feature Registry") {

            it("Initializes properly with static features") {
                class TestRegistry: DynamicFeatureRegistry {
                    public let feature1 = Feature()
                    public let feature2 = Feature()
                    public let feature3 = Feature()
                }
                let registry = TestRegistry(withFeatureStore: nil)
                expect(registry.features.count).to(equal(3))
            }

            it("Adds dynamic feature") {
                class TestRegistry: DynamicFeatureRegistry { }
                let registry = TestRegistry(withFeatureStore: nil)
                expect(registry.features).to(beEmpty())
                let _ = registry.configureDynamicFeature(feature: Feature(key: "TEST_1"))
                let featureItem = registry.features.first
                expect(featureItem?.label).to(equal("TEST_1"))
            }

            it("Sets dynamic feature override state from the store") {
                let store = EphemeralFeatureStore()
                               store["TEST_1"] = OverrideState.enabled
                               store["TEST_2"] = OverrideState.disabled
                class TestRegistry: DynamicFeatureRegistry { }
                let registry = TestRegistry(withFeatureStore: store)
                expect(registry.features).to(beEmpty())

                let feature1 = registry.configureDynamicFeature(feature: Feature(key: "TEST_1"))
                let feature2 = registry.configureDynamicFeature(feature: Feature(key: "TEST_2"))
                let feature3 = registry.configureDynamicFeature(feature: Feature(key: "TEST_3"))

                expect(feature1.override).to(equal(OverrideState.enabled))
                expect(feature2.override).to(equal(OverrideState.disabled))
                expect(feature3.override).to(equal(OverrideState.featureDefault))
            }

            it("Properly combines static and dynamic feature") {
                class TestRegistry: DynamicFeatureRegistry {
                    public let feature1 = Feature()
                    public let feature2 = Feature()
                    public let feature3 = Feature()
                }
                let registry = TestRegistry(withFeatureStore: nil)
                expect(registry.features.count).to(equal(3))

                let _ = registry.configureDynamicFeature(feature: Feature(key: "TEST_1"))
                let _ = registry.configureDynamicFeature(feature: Feature(key: "TEST_2"))
                expect(registry.features.count).to(equal(5))
            }
        }

    }
}
