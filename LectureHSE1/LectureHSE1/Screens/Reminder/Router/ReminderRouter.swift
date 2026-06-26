import UIKit

protocol ReminderRouting {
    func showReminderEditor(onSave: @escaping (Reminder) -> Void)
}

final class ReminderRouter: ReminderRouting {
    weak var viewController: UIViewController?

    func showReminderEditor(onSave: @escaping (Reminder) -> Void) {
        let detailsView = ReminderDetails(addNewReminder: onSave)
        viewController?.present(detailsView, animated: true)
    }
}
