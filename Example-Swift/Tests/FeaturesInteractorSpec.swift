// Copyright 2019, Oath Inc.
// Licensed under the terms of the MIT license. See LICENSE file in https://github.com/yahoo/Override for terms.

import Foundation
import Quick
import Nimble
@testable import YMOverride

fileprivate class TestFeatureGroup: FeatureGroup {
    let groupFeature1 = Feature()
    let groupFeature2 = Feature()
}

fileprivate class TestRegistry: FeatureRegistry {
    let feature1 = Feature(requiresRestart: false, defaultState: true)
    let feature2 = Feature(requiresRestart: false, defaultState: false)
    let group = TestFeatureGroup()
}

/// Table view which captures certain values for test validation
fileprivate class TestTableView : UITableView {
    private(set) var presentedIndexPath: IndexPath? = nil

    override func deselectRow(at indexPath: IndexPath, animated: Bool) {
        presentedIndexPath = indexPath
    }
}

/// View controller that synchonrizes certain UIKit functionality for easier testing
fileprivate class SyncPresentingViewController: UIViewController {
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        completion?()
    }
}

class FeatureInteractorSpec: QuickSpec {
    override func spec() {
        describe("Feature Registry") {

            it("Initializes properly") {
                let presenter = FeaturesPresenter(withFeatures: [],
                                                  colorProvider: DefaultFeatureStateColorProvider())
                let interactor = FeaturesInteractor(withPresenter: presenter)

                expect(interactor).to(be(interactor))
            }

            context("tablview delegate") {
                let registry = TestRegistry(withFeatureStore: nil)

                context("shouldHighlightRowAt") {
                    let presenter = FeaturesPresenter(withFeatures:  registry.featureItems,
                                                      colorProvider: DefaultFeatureStateColorProvider())
                    let interactor = FeaturesInteractor(withPresenter: presenter)

                    it("false for cells") {
                        let res = interactor.tableView(UITableView(frame: .zero), shouldHighlightRowAt: IndexPath(item: 0, section: 0))
                        expect(res).to(beFalse())
                    }

                    it("true for cells") {
                        let res = interactor.tableView(UITableView(frame: .zero), shouldHighlightRowAt: IndexPath(item: 2, section: 0))
                        expect(res).to(beTrue())
                    }
                }

                //func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
                context("didSelectRowAt") {
                    var presenter: FeaturesPresenter!
                    var interactor: FeaturesInteractor!
                    var testTableView: TestTableView!
                    var output: UIViewController!

                    beforeEach {
                        presenter = FeaturesPresenter(withFeatures:  registry.featureItems,
                                                      colorProvider: DefaultFeatureStateColorProvider())
                        interactor = FeaturesInteractor(withPresenter: presenter)
                        testTableView = TestTableView(frame: .zero, style: .plain)
                    }

                    context("with navigation controller") {
                        let navController = UINavigationController(nibName: nil, bundle: nil)

                        beforeEach {
                            output = SyncPresentingViewController(nibName: nil, bundle: nil)
                            navController.viewControllers = [ output ]
                            presenter.output = output
                        }

                        it("notifies for group features") {
                            expect(testTableView.presentedIndexPath).to(beNil())
                            let indexPath = IndexPath(item: 2, section: 0)
                            interactor.tableView(testTableView, didSelectRowAt: indexPath)
                            expect(testTableView.presentedIndexPath).to(equal(indexPath))
                        }

                        it("does not notify for non-groups features") {
                            expect(testTableView.presentedIndexPath).to(beNil())
                            let indexPath = IndexPath(item: 0, section: 0)
                            interactor.tableView(testTableView, didSelectRowAt: indexPath)
                            expect(testTableView.presentedIndexPath).to(beNil())
                        }
                    }

                    context("without navigation controller") {
                        beforeEach {
                            output = SyncPresentingViewController(nibName: nil, bundle: nil)
                            presenter.output = output
                        }

                        it("notifies for group features") {
                            expect(testTableView.presentedIndexPath).to(beNil())
                            let indexPath = IndexPath(item: 2, section: 0)
                            interactor.tableView(testTableView, didSelectRowAt: indexPath)
                            expect(testTableView.presentedIndexPath).to(equal(indexPath))
                        }

                        it("does not notify for non-groups features") {
                            expect(testTableView.presentedIndexPath).to(beNil())
                            let indexPath = IndexPath(item: 0, section: 0)
                            interactor.tableView(testTableView, didSelectRowAt: indexPath)
                            expect(testTableView.presentedIndexPath).to(beNil())
                        }
                    }
                }
            }
        }
    }
}

#if os(iOS)
class FeatureInteractorIosSpec: QuickSpec {
    struct CustomFeature: LabeledFeatureItemLike {
        let label: String = "Test"
        let feature: AnyFeature = Feature()
    }

    override func spec() {
        describe("Feature Registry (iOS)") {
            let registry = TestRegistry(withFeatureStore: nil)
            var features = registry.featureItems
            features.append(CustomFeature())
            let presenter = FeaturesPresenter(withFeatures: features,
                                              colorProvider: DefaultFeatureStateColorProvider())
            let interactor = FeaturesInteractor(withPresenter: presenter)

            it("does not configure swipe for groups") {
                let indexPath = IndexPath(item: 2, section: 0)

                let leadingActions = interactor.tableView(UITableView(frame: .zero), leadingSwipeActionsConfigurationForRowAt: indexPath)
                expect(leadingActions?.actions).to(beEmpty())

                let trailingActions = interactor.tableView(UITableView(frame: .zero), trailingSwipeActionsConfigurationForRowAt: indexPath)
                expect(trailingActions?.actions).to(beEmpty())
            }

            it("does not exceed bounds") {
                let indexPath = IndexPath(item: 9999, section: 0)

                let leadingActions = interactor.tableView(UITableView(frame: .zero), leadingSwipeActionsConfigurationForRowAt: indexPath)
                expect(leadingActions?.actions).to(beEmpty())

                let trailingActions = interactor.tableView(UITableView(frame: .zero), trailingSwipeActionsConfigurationForRowAt: indexPath)
                expect(trailingActions?.actions).to(beEmpty())
            }

            context("configures leading swipe") {
                it("enabled feature") {
                    let indexPath = IndexPath(item: 0, section: 0)

                    let enabledActions = interactor.tableView(UITableView(frame: .zero), leadingSwipeActionsConfigurationForRowAt: indexPath)
                    expect(enabledActions).toNot(beNil())
                    expect(enabledActions!.actions).to(haveCount(1))
                    expect(enabledActions!.actions[0].handler).toNot(beNil())
                    expect(enabledActions!.actions[0].style).to(equal(.normal))
                    expect(enabledActions!.actions[0].title).to(equal("Default"))
                    expect(enabledActions!.actions[0].backgroundColor).to(equal(UIColor.mulah))
                }

                it("disabled feature") {
                    let indexPath = IndexPath(item: 1, section: 0)

                    let disabledActions = interactor.tableView(UITableView(frame: .zero), leadingSwipeActionsConfigurationForRowAt: indexPath)
                    expect(disabledActions).toNot(beNil())
                    expect(disabledActions!.actions).to(haveCount(1))
                    expect(disabledActions!.actions[0].handler).toNot(beNil())
                    expect(disabledActions!.actions[0].style).to(equal(.normal))
                    expect(disabledActions!.actions[0].title).to(equal("Default"))
                    expect(disabledActions!.actions[0].backgroundColor).to(equal(UIColor.swedishFish))
                }

                it("for custom feature type") { // using LabeledFeatureLike protocol
                    let indexPath = IndexPath(item: 3, section: 0)

                    let disabledActions = interactor.tableView(UITableView(frame: .zero), leadingSwipeActionsConfigurationForRowAt: indexPath)
                    expect(disabledActions).toNot(beNil())
                    expect(disabledActions!.actions).to(haveCount(1))
                    expect(disabledActions!.actions.first?.handler).toNot(beNil())
                    expect(disabledActions!.actions.first?.style).to(equal(.normal))
                    expect(disabledActions!.actions.first?.title).to(equal("Default"))
                    expect(disabledActions!.actions.first?.backgroundColor).to(equal(UIColor.swedishFish))
                }
            }

            context("configures trailing swipe") {
                it("defaulted feature") {
                    let indexPath = IndexPath(item: 0, section: 0)

                    let actions = interactor.tableView(UITableView(frame: .zero), trailingSwipeActionsConfigurationForRowAt: indexPath)
                    expect(actions).toNot(beNil())
                    expect(actions!.actions).to(haveCount(2))

                    expect(actions!.actions[0].handler).toNot(beNil())
                    expect(actions!.actions[0].style).to(equal(.normal))
                    expect(actions!.actions[0].title).to(equal("On"))
                    expect(actions!.actions[0].backgroundColor).to(equal(UIColor.mulah))

                    expect(actions!.actions[1].handler).toNot(beNil())
                    expect(actions!.actions[1].style).to(equal(.normal))
                    expect(actions!.actions[1].title).to(equal("Off"))
                    expect(actions!.actions[1].backgroundColor).to(equal(UIColor.swedishFish))
                }

                it("override disabled feature") {
                    let indexPath = IndexPath(item: 0, section: 0)
                    registry.feature1.override = .disabled

                    let actions = interactor.tableView(UITableView(frame: .zero), trailingSwipeActionsConfigurationForRowAt: indexPath)
                    expect(actions).toNot(beNil())
                    expect(actions!.actions).to(haveCount(1))

                    expect(actions!.actions[0].handler).toNot(beNil())
                    expect(actions!.actions[0].style).to(equal(.normal))
                    expect(actions!.actions[0].title).to(equal("On"))
                    expect(actions!.actions[0].backgroundColor).to(equal(UIColor.mulah))
                }

                it("override enabled feature") {
                    let indexPath = IndexPath(item: 1, section: 0)
                    registry.feature2.override = .enabled

                    let actions = interactor.tableView(UITableView(frame: .zero), trailingSwipeActionsConfigurationForRowAt: indexPath)
                    expect(actions).toNot(beNil())
                    expect(actions!.actions).to(haveCount(1))
                    
                    expect(actions!.actions[0].handler).toNot(beNil())
                    expect(actions!.actions[0].style).to(equal(.normal))
                    expect(actions!.actions[0].title).to(equal("Off"))
                    expect(actions!.actions[0].backgroundColor).to(equal(UIColor.swedishFish))
                }
            }
            
//            func swipeHandler(forFeature feature: AnyFeature, override: OverrideState, tableView: UITableView, indexPath: IndexPath, completion: (Bool) -> Void) {
        }
    }
}
#elseif os(tvOS)
class FeatureInteractorTvosSpec: QuickSpec {
    override func spec() {
        describe("Feature Registry (tvOS)") {

        }
    }
}
#endif
