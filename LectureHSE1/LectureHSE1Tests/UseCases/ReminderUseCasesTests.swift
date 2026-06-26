import XCTest
@testable import LectureHSE1

final class ReminderUseCasesTests: XCTestCase {

    func testFetchRemindersUseCaseReturnsRepositoryReminders() throws {
        let reminders = [makeTestReminder(text: "Loaded")]
        let repository = FakeReminderRepository(reminders: reminders)
        let useCase = FetchRemindersUseCase(repository: repository)

        let result = try useCase.execute()

        XCTAssertEqual(result.map(\.id), reminders.map(\.id))
        XCTAssertEqual(repository.fetchCalls, 1)
    }

    func testSaveReminderUseCaseDelegatesToRepository() throws {
        let reminder = makeTestReminder(text: "Save")
        let repository = FakeReminderRepository()
        let useCase = SaveReminderUseCase(repository: repository)

        let result = try useCase.execute(reminder: reminder)

        XCTAssertEqual(result.map(\.id), [reminder.id])
        XCTAssertEqual(repository.savedReminder?.id, reminder.id)
    }

    func testDeleteReminderUseCaseDelegatesToRepository() throws {
        let reminder = makeTestReminder(id: "delete")
        let repository = FakeReminderRepository(reminders: [reminder])
        let useCase = DeleteReminderUseCase(repository: repository)

        let result = try useCase.execute(id: reminder.id)

        XCTAssertTrue(result.isEmpty)
        XCTAssertEqual(repository.deletedId, reminder.id)
    }
}

private final class FakeReminderRepository: ReminderRepositoryProtocol {
    private(set) var reminders: [Reminder]
    private(set) var fetchCalls = 0
    private(set) var savedReminder: Reminder?
    private(set) var deletedId: String?

    init(reminders: [Reminder] = []) {
        self.reminders = reminders
    }

    func fetchReminders() throws -> [Reminder] {
        fetchCalls += 1
        return reminders
    }

    func saveReminder(_ reminder: Reminder) throws -> [Reminder] {
        savedReminder = reminder
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
        } else {
            reminders.insert(reminder, at: 0)
        }
        return reminders
    }

    func deleteReminder(id: String) throws -> [Reminder] {
        deletedId = id
        reminders.removeAll { $0.id == id }
        return reminders
    }
}
