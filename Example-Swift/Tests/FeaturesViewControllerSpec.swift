// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Quick
import Nimble
import Nimble_Snapshots
@testable import YMOverride

class FeaturesViewControllerSpec: QuickSpec {

    override func spec() {

        describe("Features View Controller") {

            it("properly initializes") {
                let registry = FeatureRegistry(withFeatureStore: nil)
                let vc = FeaturesViewController()
                vc.featureRegistry = registry

                expect(vc.featureRegistry).to(be(registry))

                let topVC = vc.topViewController
                expect(topVC).toNot(beNil())
                expect(topVC).to(beAKindOf(FeaturesTableViewController.self))

                let featuresVC = topVC as! FeaturesTableViewController
                expect(featuresVC.presenter).toNot(beNil())
                expect(featuresVC.presenter.features).to(be(registry.features))

                expect(featuresVC.interactor).toNot(beNil())
                expect(featuresVC.interactor.presenter).to(be(featuresVC.presenter))
            }

            it("works with empty registry") {
                let registry = FeatureRegistry(withFeatureStore: nil)
                let vc = FeaturesViewController()
                vc.featureRegistry = registry

                expect(vc.topViewController!).to(beAKindOf(FeaturesTableViewController.self))
                let tableViewVC = vc.topViewController! as! FeaturesTableViewController
                // Currently the LabeledItem is not Equatable
                //expect(tableViewVC.presenter.features).to(equal(registry.features))
                expect(tableViewVC.presenter.features.count).to(equal(registry.features.count))
            }

            it("handles nil registry") {
                let vc = FeaturesViewController()
                vc.featureRegistry = nil
                expect(vc.viewControllers).to(beEmpty())
            }
        }
    }
}
