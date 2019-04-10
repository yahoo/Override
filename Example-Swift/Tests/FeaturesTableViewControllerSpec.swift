// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Quick
import Nimble
import Nimble_Snapshots
@testable import YMOverride

class FeaturesTableViewViewControllerSpec: QuickSpec {

    override func spec() {

        describe("Features View Controller") {

            it("properly initializes") {
                let registry = FeatureRegistry(withFeatureStore: nil)
                let vc = FeaturesTableViewController(features: registry.features)

                expect(vc.presenter).toNot(beNil())
                expect(vc.presenter.features).to(be(registry.features))
                expect(vc.presenter.output).to(equal(vc))

                expect(vc.interactor).toNot(beNil())
                expect(vc.interactor.presenter).to(be(vc.presenter))
            }

            it("initializes using registry") {
                let registry = FeatureRegistry(withFeatureStore: nil)
                let vc = FeaturesTableViewController(featureRegistry: registry)

                expect(vc.presenter).toNot(beNil())
                expect(vc.presenter.features).to(be(registry.features))
                expect(vc.presenter.output).to(equal(vc))

                expect(vc.interactor).toNot(beNil())
                expect(vc.interactor.presenter).to(be(vc.presenter))
            }

            it("does not coder init") {
                expect(expression: { () -> Void in
                    _ = FeaturesTableViewController(coder: NSCoder())
                }).to(throwAssertion())
            }

            it("works with empty features") {
                let vc = FeaturesTableViewController(features: [])
                expect(vc.presenter.features).to(haveCount(0))

            }
        }
    }
}
