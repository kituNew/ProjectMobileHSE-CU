import Foundation

protocol ReminderViewProtocol: AnyObject {
    func showReminders(_ reminders: [Reminder])
    func showError(_ message: String)
}

protocol ReminderPresenting: AnyObject {
    func viewDidLoad()
    func addReminderTapped()
    func saveReminder(_ reminder: Reminder)
    func updateReminder(_ reminder: Reminder)
    func deleteReminder(id: String)
}

final class ReminderPresenter: ReminderPresenting {
    weak var view: ReminderViewProtocol?

    private let fetchRemindersUseCase: FetchRemindersUseCaseProtocol
    private let saveReminderUseCase: SaveReminderUseCaseProtocol
    private let deleteReminderUseCase: DeleteReminderUseCaseProtocol
    private let router: ReminderRouting

    init(
        fetchRemindersUseCase: FetchRemindersUseCaseProtocol,
        saveReminderUseCase: SaveReminderUseCaseProtocol,
        deleteReminderUseCase: DeleteReminderUseCaseProtocol,
        router: ReminderRouting
    ) {
        self.fetchRemindersUseCase = fetchRemindersUseCase
        self.saveReminderUseCase = saveReminderUseCase
        self.deleteReminderUseCase = deleteReminderUseCase
        self.router = router
    }

    func viewDidLoad() {
        do {
            view?.showReminders(try fetchRemindersUseCase.execute())
        } catch {
            view?.showError(error.localizedDescription)
        }
    }

    func addReminderTapped() {
        router.showReminderEditor { [weak self] reminder in
            self?.saveReminder(reminder)
        }
    }

    func saveReminder(_ reminder: Reminder) {
        do {
            view?.showReminders(try saveReminderUseCase.execute(reminder: reminder))
        } catch {
            view?.showError(error.localizedDescription)
        }
    }

    func updateReminder(_ reminder: Reminder) {
        saveReminder(reminder)
    }

    func deleteReminder(id: String) {
        do {
            view?.showReminders(try deleteReminderUseCase.execute(id: id))
        } catch {
            view?.showError(error.localizedDescription)
        }
    }
}
