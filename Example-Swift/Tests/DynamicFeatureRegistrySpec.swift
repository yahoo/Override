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
                try! registry.add(feature: Feature(key: "TEST_1"))
                let featureItem = registry.features.first
                expect(featureItem?.label).to(equal("TEST_1"))
            }

            it("Retrieves a dynamic feature") {
                class TestRegistry: DynamicFeatureRegistry { }
                let registry = TestRegistry(withFeatureStore: nil)
                expect(registry.features).to(beEmpty())
                try! registry.add(feature: Feature(key: "TEST_1"))
                let featureItem = registry.dynamicFeature(with: "TEST_1")
                expect(featureItem?.key).to(equal("TEST_1"))
            }

            it("Sets dynamic feature override state from the store") {
                let store = EphemeralFeatureStore()
                               store["TEST_1"] = OverrideState.enabled
                               store["TEST_2"] = OverrideState.disabled
                class TestRegistry: DynamicFeatureRegistry { }
                let registry = TestRegistry(withFeatureStore: store)
                expect(registry.features).to(beEmpty())

                try! registry.add(feature: Feature(key: "TEST_1"))
                try! registry.add(feature: Feature(key: "TEST_2"))
                try! registry.add(feature: Feature(key: "TEST_3"))

                let feature1 = registry.dynamicFeature(with: "TEST_1")
                let feature2 = registry.dynamicFeature(with: "TEST_2")
                let feature3 = registry.dynamicFeature(with: "TEST_3")

                expect(feature1!.override).to(equal(OverrideState.enabled))
                expect(feature2!.override).to(equal(OverrideState.disabled))
                expect(feature3!.override).to(equal(OverrideState.featureDefault))
            }

            it("Properly combines static and dynamic feature") {
                class TestRegistry: DynamicFeatureRegistry {
                    public let feature1 = Feature()
                    public let feature2 = Feature()
                    public let feature3 = Feature()
                }
                let registry = TestRegistry(withFeatureStore: nil)
                expect(registry.features.count).to(equal(3))

                try! registry.add(feature: Feature(key: "TEST_1"))
                try! registry.add(feature: Feature(key: "TEST_2"))
                expect(registry.features.count).to(equal(5))
            }

            it("Throws error when attempting to replace a static feature") {
                class TestRegistry: DynamicFeatureRegistry {
                    public let feature1 = Feature()
                }

                let registry = TestRegistry(withFeatureStore: nil)
                expect(registry.features.count).to(equal(1))

                let duplicateFeature = Feature(key: "feature1")

                do {
                    /// Tests that the method throws. We can't really rely on only the catch because that would just test
                    /// "did the correct error throw" and not "did this actaully throw".
                    expect (try registry.add(feature: duplicateFeature) ).to(throwError(DynamicFeatureRegistryError.staticFeatureAlreadyExists) )
                    /// Throw again to clear a warning that the `catch` is never triggered (because the above line handles it).
                    try registry.add(feature: duplicateFeature)
                } catch {
                    let error = error as? DynamicFeatureRegistryError
                    expect(error).to(equal(.staticFeatureAlreadyExists))
                }

                expect(registry.features.count).to(equal(1))
            }

            it("Does not replace dynamic feature") {
                class TestRegistry: DynamicFeatureRegistry { }
                let registry = TestRegistry(withFeatureStore: nil)
                expect(registry.features).to(beEmpty())
                let feature1 = Feature(key: "TEST_1", requiresRestart: false, defaultState: false)
                let feature2 = Feature(key: "TEST_1", requiresRestart: true, defaultState: true)

                try! registry.add(feature: feature1)
                expect(registry.features.count).to(equal(1))

                try! registry.add(feature: feature2)
                expect(registry.features.count).to(equal(1))

                let storedFeature = registry.dynamicFeature(with: "TEST_1")!
                expect(storedFeature.defaultState).to(equal(feature1.defaultState))
                expect(storedFeature.requiresRestart).to(equal(feature1.requiresRestart))
            }

            it("Does replace dynamic feature") {
                class TestRegistry: DynamicFeatureRegistry { }
                let registry = TestRegistry(withFeatureStore: nil)
                expect(registry.features).to(beEmpty())
                let feature1 = Feature(key: "TEST_1", requiresRestart: false, defaultState: false)
                let feature2 = Feature(key: "TEST_1", requiresRestart: true, defaultState: true)

                try! registry.add(feature: feature1)
                expect(registry.features.count).to(equal(1))

                try! registry.add(feature: feature2, forced: true)
                expect(registry.features.count).to(equal(1))

                let storedFeature = registry.dynamicFeature(with: "TEST_1")!
                expect(storedFeature.defaultState).to(equal(feature2.defaultState))
                expect(storedFeature.requiresRestart).to(equal(feature2.requiresRestart))
            }
        }

    }
}
