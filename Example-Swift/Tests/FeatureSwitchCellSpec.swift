// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

@testable import Override
import Quick
import Nimble
import Nimble_Snapshots

fileprivate struct TestLabeledFeatureItem: LabeledFeatureItem {
    let label: String
    let feature: AnyFeature
}

class FeatureSwitchCellSpec: QuickSpec {
    override func spec() {

        describe("FeatureSwitchCell") {

            it("sets null labeled feature") {
                let cell = FeatureSwitchCell(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
                cell.labeledFeature = nil
                expect(cell.labeledFeature).to(beNil())
            }

            it("inits with decoder") {
                expect(expression: { () -> Void in
                    _ = FeatureSwitchCell(coder: NSKeyedUnarchiver.init(forReadingWith: Data()))
                }).to(throwAssertion())
            }

            context("render") {
                it("default") {
                    let feature = Feature(key: "Key")
                    let cell = FeatureSwitchCell(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
                    cell.labeledFeature = TestLabeledFeatureItem(label: "Default", feature: feature)
                    expect(cell).to(haveValidSnapshot(named: "feature_switch_cell_normal", identifier: nil, usesDrawRect: true))
                }

                it("defaulted on") {
                    let feature = Feature(key: "Key", requiresRestart: false, defaultState: true)
                    let cell = FeatureSwitchCell(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
                    cell.labeledFeature = TestLabeledFeatureItem(label: "Default:ON", feature: feature)
                    expect(cell).to(haveValidSnapshot(named: "feature_switch_cell_enabled_default", identifier: nil, usesDrawRect: true))
                }

                it("defaulted off") {
                    let feature = Feature(key: "Key", requiresRestart: false, defaultState: false)
                    let cell = FeatureSwitchCell(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
                    cell.labeledFeature = TestLabeledFeatureItem(label: "Default:OFF", feature: feature)
                    expect(cell).to(haveValidSnapshot(named: "feature_switch_cell_disabled_default", identifier: nil, usesDrawRect: true))
                }

                it("overridden on") {
                    let feature = Feature(key: "Key", requiresRestart: false, defaultState: false)
                    feature.override = .enabled
                    let cell = FeatureSwitchCell(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
                    cell.labeledFeature = TestLabeledFeatureItem(label: "Override:ON", feature: feature)
                    expect(cell).to(haveValidSnapshot(named: "feature_switch_cell_enabled_override", identifier: nil, usesDrawRect: true))
                }

                it("overridden off") {
                    let feature = Feature(key: "Key", requiresRestart: false, defaultState: true)
                    feature.override = .disabled
                    let cell = FeatureSwitchCell(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
                    cell.labeledFeature = TestLabeledFeatureItem(label: "Override:OFF", feature: feature)
                    expect(cell).to(haveValidSnapshot(named: "feature_switch_cell_disabled_override", identifier: nil, usesDrawRect: true))
                }
            }

        }

    }
}

