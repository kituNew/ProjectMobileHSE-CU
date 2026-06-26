import UIKit
import XCTest
@testable import LectureHSE1

final class ReminderRouterTests: XCTestCase {

    func testShowReminderEditorPresentsDetailsAndPassesSaveCallback() {
        let viewController = PresentingViewControllerSpy()
        let router = ReminderRouter()
        router.viewController = viewController
        let reminder = makeTestReminder(text: "Created")
        var savedReminder: Reminder?

        router.showReminderEditor { reminder in
            savedReminder = reminder
        }

        let detailsView = viewController.presentedViewControllerSpy as? ReminderDetails
        detailsView?.addNewReminder(reminder)

        XCTAssertNotNil(detailsView)
        XCTAssertEqual(savedReminder?.id, reminder.id)
    }
}

private final class PresentingViewControllerSpy: UIViewController {
    private(set) var presentedViewControllerSpy: UIViewController?

    override func present(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        presentedViewControllerSpy = viewControllerToPresent
        completion?()
    }
}
