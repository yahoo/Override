// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Quick
import Nimble
@testable import YMOverride

class FeatureRegistrySpec: QuickSpec {

    override func spec() {

        describe("Feature Registry") {

            it("initializes properly with default store") {
                let registry = FeatureRegistry(withFeatureStore: nil)
                expect(registry.featureStore).to(beAKindOf(EphemeralFeatureStore.self))
            }

            it("initializes properly with default store using custom params") {
                let store = UserDefaultsFeatureStore(withUserDefaults: UserDefaults.standard, withKeyPrefix:"CustomPrefix_")
                let registry = FeatureRegistry(withFeatureStore: store)
                expect(registry.featureStore).to(be(store))
            }

            it("initializes properly with custom userdefaults store") {
                let store = UserDefaultsFeatureStore()
                let registry = FeatureRegistry(withFeatureStore: store)
                expect(registry.featureStore).to(be(store))
            }
            
            it("works with empty registry") {
                class TestRegistry: FeatureRegistry { }
                let registry = FeatureRegistry(withFeatureStore: nil)
                expect(registry.features).to(beEmpty())
            }

            it("Ignores non-Feature properties") {
                class TestRegistry: FeatureRegistry {
                    public let notAFeature: String = "Not a feature!"
                }
                let registry = TestRegistry(withFeatureStore: nil)
                expect(registry.features).to(beEmpty())
            }

            context("feature keys") {

                let store = EphemeralFeatureStore()
                store["FEATURE_KEY"] = OverrideState.enabled
                store["feature1"] = OverrideState.disabled

                it("Respects feature key") {
                    class TestRegistry: FeatureRegistry {
                        public let feature1 = Feature(key: "FEATURE_KEY")
                        public let FEATURE_KEY = Feature()
                    }
                    let registry = TestRegistry(withFeatureStore: store)
                    let featureNames = registry.features.map { return $0.label }

                    expect(featureNames).to(equal([ "feature1", "FEATURE_KEY" ]))
                    expect(registry.feature1.enabled).to(beTrue())
                    expect(registry.feature1.override).to(equal(OverrideState.enabled))

                    expect(registry.FEATURE_KEY.enabled).to(beTrue())
                    expect(registry.FEATURE_KEY.override).to(equal(OverrideState.enabled))
                }

                it("Auto-generates feature key") {
                    class TestRegistry: FeatureRegistry {
                        public let feature1 = Feature()
                        public let FEATURE_KEY = Feature()
                    }
                    let registry = TestRegistry(withFeatureStore: store)
                    let featureNames = registry.features.map { return $0.label }

                    expect(featureNames).to(equal([ "feature1", "FEATURE_KEY" ]))
                    expect(registry.feature1.enabled).to(beFalse())
                    expect(registry.feature1.override).to(equal(OverrideState.disabled))

                    expect(registry.FEATURE_KEY.enabled).to(beTrue())
                    expect(registry.FEATURE_KEY.override).to(equal(OverrideState.enabled))
                }
            }

            it("Extracts features, preserving order") {
                class TestRegistry: FeatureRegistry {
                    public let feature1 = Feature()
                    public let feature2 = Feature()
                    public let feature3 = Feature()
                    public let feature4 = Feature()
                }

                let registry = TestRegistry(withFeatureStore: nil)
                let featureNames = registry.features.map { return $0.label }
                expect(featureNames).to(equal([ "feature1",
                                                "feature2",
                                                "feature3",
                                                "feature4" ]))
            }

            it("Extracts features, complex class") {
                class TestRegistry: FeatureRegistry {
                    public let feature1 = Feature()
                    public let feature2 = DynamicFeature { _ in return false }
                    public let feature3: String = "Feature3"
                    private let feature4 = Feature(key: "FEATURE_4")
                    internal let feature5 = Feature()
                    private var feature6 = 6
                    fileprivate let feature7 = Feature()
                }

                let registry = TestRegistry(withFeatureStore: nil)
                let featureNames = registry.features.map { return $0.label }
                expect(featureNames).to(equal([ "feature1",
                                                "feature2",
                                                "feature4",
                                                "feature5",
                                                "feature7"]))
            }

            it("Returns enabled feature titles") {
                class TestRegistry: FeatureRegistry {
                    public let feature1 = Feature(requiresRestart: false, defaultState: true)
                    public let feature2 = Feature()
                    public let feature3 = Feature()
                    public let feature4 = Feature()
                }

                let registry = TestRegistry(withFeatureStore: nil)
                registry.feature3.override = .enabled
                let enabledFeatureNames = TestRegistry.enabledFeatures(in: registry)
                expect(enabledFeatureNames).to(equal([ "feature1",
                                                       "feature3"]))
            }
        }

    }

}
