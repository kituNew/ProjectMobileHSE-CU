import Foundation

protocol FetchRemindersUseCaseProtocol {
    func execute() throws -> [Reminder]
}

final class FetchRemindersUseCase: FetchRemindersUseCaseProtocol {
    private let repository: ReminderRepositoryProtocol

    init(repository: ReminderRepositoryProtocol) {
        self.repository = repository
    }

    func execute() throws -> [Reminder] {
        try repository.fetchReminders()
    }
}

protocol SaveReminderUseCaseProtocol {
    func execute(reminder: Reminder) throws -> [Reminder]
}

final class SaveReminderUseCase: SaveReminderUseCaseProtocol {
    private let repository: ReminderRepositoryProtocol

    init(repository: ReminderRepositoryProtocol) {
        self.repository = repository
    }

    func execute(reminder: Reminder) throws -> [Reminder] {
        try repository.saveReminder(reminder)
    }
}

protocol DeleteReminderUseCaseProtocol {
    func execute(id: String) throws -> [Reminder]
}

final class DeleteReminderUseCase: DeleteReminderUseCaseProtocol {
    private let repository: ReminderRepositoryProtocol

    init(repository: ReminderRepositoryProtocol) {
        self.repository = repository
    }

    func execute(id: String) throws -> [Reminder] {
        try repository.deleteReminder(id: id)
    }
}
