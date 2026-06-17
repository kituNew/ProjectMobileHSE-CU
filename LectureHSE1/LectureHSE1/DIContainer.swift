import UIKit

final class DIContainer {
    private let networkService = NetworkService()
    private let coreDataStack = CoreDataStack()

    func makeTabBarController() -> UITabBarController {
        let tabBar = UITabBarController()
        NetworkMonitor.shared.start()

        tabBar.viewControllers = [
            makeHomeNavigationController(),
            makeReminderNavigationController(),
            makeNotesNavigationController()
        ]

        return tabBar
    }

    private func makeHomeNavigationController() -> UINavigationController {
        let remoteDataSource = NewsRemoteDataSource(networkService: networkService)
        let repository = NewsRepository(
            remoteDataSource: remoteDataSource,
            coreDataStack: coreDataStack
        )
        let searchUseCase = SearchNewsUseCase(repository: repository)
        let imageUseCase = LoadNewsImageUseCase(repository: repository)
        let router = HomeRouter()
        let presenter = HomePresenter(
            searchNewsUseCase: searchUseCase,
            loadImageUseCase: imageUseCase,
            router: router
        )
        let homeVC = HomeView(presenter: presenter)
        presenter.view = homeVC
        router.viewController = homeVC

        let navigationController = UINavigationController(rootViewController: homeVC)
        navigationController.tabBarItem = UITabBarItem(
            title: "Главная",
            image: UIImage(systemName: "house"),
            tag: 0
        )
        return navigationController
    }

    private func makeReminderNavigationController() -> UINavigationController {
        let reminderRepository = CoreDataReminderRepository(coreDataStack: coreDataStack)
        let reminderVM = ReminderViewModel(repository: reminderRepository)
        let reminderVC = ReminderView(viewModel: reminderVM)
        let navigationController = UINavigationController(rootViewController: reminderVC)
        navigationController.tabBarItem = UITabBarItem(
            title: "Задачи",
            image: UIImage(systemName: "checkmark.circle.fill"),
            tag: 1
        )
        return navigationController
    }

    private func makeNotesNavigationController() -> UINavigationController {
        let repository = CoreDataNotesRepository(coreDataStack: coreDataStack)
        let router = NotesRouter()
        let presenter = NotesPresenter(
            fetchNotesUseCase: FetchNotesUseCase(repository: repository),
            saveNoteUseCase: SaveNoteUseCase(repository: repository),
            deleteNoteUseCase: DeleteNoteUseCase(repository: repository),
            router: router
        )
        let noteVC = NoteView(presenter: presenter)
        presenter.view = noteVC
        router.viewController = noteVC

        let navigationController = UINavigationController(rootViewController: noteVC)
        navigationController.tabBarItem = UITabBarItem(
            title: "Записи",
            image: UIImage(systemName: "list.bullet"),
            tag: 2
        )
        return navigationController
    }
}
