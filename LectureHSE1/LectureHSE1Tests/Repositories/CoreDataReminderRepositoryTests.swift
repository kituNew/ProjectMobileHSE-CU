import XCTest
@testable import LectureHSE1

final class CoreDataReminderRepositoryTests: XCTestCase {

    func testSaveReminderCreatesAndFetchesReminder() throws {
        let repository = CoreDataReminderRepository(
            coreDataStack: CoreDataStack(inMemory: true)
        )
        let reminder = makeTestReminder(
            id: "reminder-1",
            text: "Call",
            description: "Call back",
            priority: .high,
            flag: true,
            toDate: Date(timeIntervalSince1970: 42),
            isDone: true
        )

        let reminders = try repository.saveReminder(reminder)

        XCTAssertEqual(reminders.count, 1)
        assertReminder(reminders.first, equals: reminder)
        assertReminder(try repository.fetchReminders().first, equals: reminder)
    }

    func testSaveReminderUpdatesExistingReminderWithoutDuplicate() throws {
        let repository = CoreDataReminderRepository(
            coreDataStack: CoreDataStack(inMemory: true)
        )
        let original = makeTestReminder(id: "same", text: "Original", priority: .low)
        let updated = makeTestReminder(id: "same", text: "Updated", priority: .high)

        _ = try repository.saveReminder(original)
        let reminders = try repository.saveReminder(updated)

        XCTAssertEqual(reminders.count, 1)
        assertReminder(reminders.first, equals: updated)
    }

    func testDeleteReminderRemovesReminderById() throws {
        let repository = CoreDataReminderRepository(
            coreDataStack: CoreDataStack(inMemory: true)
        )
        let reminder = makeTestReminder(id: "delete-me")

        _ = try repository.saveReminder(reminder)
        let reminders = try repository.deleteReminder(id: reminder.id)

        XCTAssertTrue(reminders.isEmpty)
        XCTAssertTrue(try repository.fetchReminders().isEmpty)
    }

    private func assertReminder(
        _ actual: Reminder?,
        equals expected: Reminder,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(actual?.id, expected.id, file: file, line: line)
        XCTAssertEqual(actual?.text, expected.text, file: file, line: line)
        XCTAssertEqual(actual?.description, expected.description, file: file, line: line)
        XCTAssertEqual(actual?.priority, expected.priority, file: file, line: line)
        XCTAssertEqual(actual?.flag, expected.flag, file: file, line: line)
        XCTAssertEqual(actual?.toDate, expected.toDate, file: file, line: line)
        XCTAssertEqual(actual?.isDone, expected.isDone, file: file, line: line)
    }
}
