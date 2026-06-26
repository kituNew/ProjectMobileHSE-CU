import XCTest
@testable import LectureHSE1

final class ReminderPresenterTests: XCTestCase {

    func testViewDidLoadShowsFetchedReminders() {
        let reminders = [makeTestReminder(text: "Loaded")]
        let view = FakeReminderView()
        let presenter = ReminderPresenter(
            fetchRemindersUseCase: FakeFetchRemindersUseCase(reminders: reminders),
            saveReminderUseCase: FakeSaveReminderUseCase(),
            deleteReminderUseCase: FakeDeleteReminderUseCase(),
            router: FakeReminderRouter()
        )
        presenter.view = view

        presenter.viewDidLoad()

        XCTAssertEqual(view.reminders.map(\.id), reminders.map(\.id))
    }

    func testViewDidLoadShowsErrorWhenFetchFails() {
        let view = FakeReminderView()
        let presenter = ReminderPresenter(
            fetchRemindersUseCase: FakeFetchRemindersUseCase(error: TestError.expected),
            saveReminderUseCase: FakeSaveReminderUseCase(),
            deleteReminderUseCase: FakeDeleteReminderUseCase(),
            router: FakeReminderRouter()
        )
        presenter.view = view

        presenter.viewDidLoad()

        XCTAssertEqual(view.errorMessage, TestError.expected.localizedDescription)
    }

    func testAddReminderTappedOpensEditorAndSavesReturnedReminder() {
        let reminder = makeTestReminder(text: "From editor")
        let view = FakeReminderView()
        let router = FakeReminderRouter(reminderToReturnFromEditor: reminder)
        let presenter = ReminderPresenter(
            fetchRemindersUseCase: FakeFetchRemindersUseCase(),
            saveReminderUseCase: FakeSaveReminderUseCase(reminders: [reminder]),
            deleteReminderUseCase: FakeDeleteReminderUseCase(),
            router: router
        )
        presenter.view = view

        presenter.addReminderTapped()

        XCTAssertTrue(router.didOpenEditor)
        XCTAssertEqual(view.reminders.map(\.id), [reminder.id])
    }

    func testUpdateReminderSavesReminderAndShowsUpdatedList() {
        let reminder = makeTestReminder(text: "Updated")
        let view = FakeReminderView()
        let presenter = ReminderPresenter(
            fetchRemindersUseCase: FakeFetchRemindersUseCase(),
            saveReminderUseCase: FakeSaveReminderUseCase(reminders: [reminder]),
            deleteReminderUseCase: FakeDeleteReminderUseCase(),
            router: FakeReminderRouter()
        )
        presenter.view = view

        presenter.updateReminder(reminder)

        XCTAssertEqual(view.reminders.map(\.id), [reminder.id])
    }

    func testDeleteReminderShowsRemainingReminders() {
        let remaining = makeTestReminder(id: "remaining")
        let view = FakeReminderView()
        let presenter = ReminderPresenter(
            fetchRemindersUseCase: FakeFetchRemindersUseCase(),
            saveReminderUseCase: FakeSaveReminderUseCase(),
            deleteReminderUseCase: FakeDeleteReminderUseCase(reminders: [remaining]),
            router: FakeReminderRouter()
        )
        presenter.view = view

        presenter.deleteReminder(id: "deleted")

        XCTAssertEqual(view.reminders.map(\.id), [remaining.id])
    }

    func testSaveReminderShowsErrorWhenSaveFails() {
        let view = FakeReminderView()
        let presenter = ReminderPresenter(
            fetchRemindersUseCase: FakeFetchRemindersUseCase(),
            saveReminderUseCase: FakeSaveReminderUseCase(error: TestError.expected),
            deleteReminderUseCase: FakeDeleteReminderUseCase(),
            router: FakeReminderRouter()
        )
        presenter.view = view

        presenter.saveReminder(makeTestReminder())

        XCTAssertEqual(view.errorMessage, TestError.expected.localizedDescription)
    }
}

private final class FakeReminderView: ReminderViewProtocol {
    private(set) var reminders: [Reminder] = []
    private(set) var errorMessage: String?

    func showReminders(_ reminders: [Reminder]) {
        self.reminders = reminders
    }

    func showError(_ message: String) {
        errorMessage = message
    }
}

private final class FakeFetchRemindersUseCase: FetchRemindersUseCaseProtocol {
    let reminders: [Reminder]
    let error: Error?

    init(reminders: [Reminder] = [], error: Error? = nil) {
        self.reminders = reminders
        self.error = error
    }

    func execute() throws -> [Reminder] {
        if let error {
            throw error
        }
        return reminders
    }
}

private final class FakeSaveReminderUseCase: SaveReminderUseCaseProtocol {
    let reminders: [Reminder]
    let error: Error?

    init(reminders: [Reminder] = [], error: Error? = nil) {
        self.reminders = reminders
        self.error = error
    }

    func execute(reminder: Reminder) throws -> [Reminder] {
        if let error {
            throw error
        }
        return reminders
    }
}

private final class FakeDeleteReminderUseCase: DeleteReminderUseCaseProtocol {
    let reminders: [Reminder]
    let error: Error?

    init(reminders: [Reminder] = [], error: Error? = nil) {
        self.reminders = reminders
        self.error = error
    }

    func execute(id: String) throws -> [Reminder] {
        if let error {
            throw error
        }
        return reminders
    }
}

private final class FakeReminderRouter: ReminderRouting {
    let reminderToReturnFromEditor: Reminder?
    private(set) var didOpenEditor = false

    init(reminderToReturnFromEditor: Reminder? = nil) {
        self.reminderToReturnFromEditor = reminderToReturnFromEditor
    }

    func showReminderEditor(onSave: @escaping (Reminder) -> Void) {
        didOpenEditor = true
        if let reminderToReturnFromEditor {
            onSave(reminderToReturnFromEditor)
        }
    }
}
