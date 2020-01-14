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

            it("Initializes properly with nested feature groups") {
                class TestRegistry: FeatureRegistry {
                    class Group: FeatureGroup {
                        class Group: FeatureGroup {
                            public let feature1_1_1 = Feature()
                        }

                        public let feature1_1 = Feature(key: "KEY_TEST")
                        public let group1_1 = Group()
                    }

                    public let group1 = Group()
                }

                let registry = TestRegistry(withFeatureStore: nil)
                let featureNames = registry.features.map { return $0.label }

                expect(featureNames).to(equal([ "group1" ]))

                expect(registry.group1.feature1_1.enabled).to(beFalse())
                expect(registry.group1.feature1_1.key).to(equal("KEY_TEST"))
                expect(registry.group1.feature1_1.override).to(equal(OverrideState.featureDefault))

                expect(registry.group1.group1_1.feature1_1_1.enabled).to(beFalse())
                expect(registry.group1.group1_1.feature1_1_1.key).to(equal("feature1_1_1"))
                expect(registry.group1.group1_1.feature1_1_1.override).to(equal(OverrideState.featureDefault))
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

            it("Extracts features, groups") {
                class TestRegistry: FeatureRegistry {
                    public let feature1 = Feature()
                    public let group1 = FeatureGroup()
                }

                let registry = TestRegistry(withFeatureStore: nil)
                let featureNames = registry.features.map { return $0.label }
                expect(featureNames).to(equal([ "feature1",
                                                "group1" ]))
            }

            it("Extracts features, nested groups") {
                func reduce(items: [LabeledItem]) -> [String] {
                    return items.flatMap { item -> [String] in
                        switch (item) {
                        case let feature as LabeledFeatureItem:
                            return [feature.label]

                        case let group as LabeledGroupItem:
                            let groupItemNames = reduce(items: Array(group)).map { "\(item.label):\($0)" }
                            return [group.label] + groupItemNames

                        default:
                            return ["ERRORTYPE:\(type(of: item))"]
                        }
                    }
                }

                class TestRegistry: FeatureRegistry {

                    class TestGroup: FeatureGroup {

                        class NestedGroup: FeatureGroup {
                            public let feature1_1_1 = Feature()
                        }

                        public let feature1_1 = Feature()
                        public let group1_1 = NestedGroup()
                    }

                    public let feature1 = Feature()
                    public let group1 = TestGroup()
                }

                let registry = TestRegistry(withFeatureStore: nil)
                let featureNames = reduce(items: registry.features) //registry.features.map { return $0.label }
                expect(featureNames).to(equal([ "feature1",
                                                "group1",
                                                "group1:feature1_1",
                                                "group1:group1_1",
                                                "group1:group1_1:feature1_1_1"
                ]))
            }
        }

        it("Returns enabled feature titles") {
            class TestRegistry: FeatureRegistry {
                class TestFeatureGroup: FeatureGroup {
                    class TestNestedFeatureGroup: FeatureGroup {
                        public let nestedGroupFeature1 = Feature()
                        public let nestedGroupFeature2 = Feature(requiresRestart: false, defaultState: true)
                        public let nestedGroupFeature3 = Feature()
                    }

                    public let groupFeature1 = Feature()
                    public let groupFeature2 = Feature(requiresRestart: false, defaultState: true)
                    public let groupFeature3 = Feature()
                    public let nestedGroup = TestNestedFeatureGroup()
                }

                public let feature1 = Feature(requiresRestart: false, defaultState: true)
                public let feature2 = Feature()
                public let feature3 = Feature()
                public let feature4 = Feature()
                public let groupFeature = TestFeatureGroup()
            }

            let registry = TestRegistry(withFeatureStore: nil)
            registry.feature3.override = .enabled
            let enabledFeatureNames = TestRegistry.enabledFeatures(in: registry)
            expect(enabledFeatureNames).to(equal([ "Feature1",
                                                   "Feature3",
                                                   "Group Feature → Group Feature2",
                                                   "Group Feature → Nested Group → Nested Group Feature2" ]))
        }

    }

}
