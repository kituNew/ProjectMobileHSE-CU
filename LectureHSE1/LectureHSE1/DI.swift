//
//  DI.swift
//  LectureHSE1
//
//  Created by Zaitsev Vladislav on 30.11.2025.
//

import UIKit

class DI {
    func makeTabBarController() -> UITabBarController {
        let tabBar = UITabBarController()
        NetworkMonitor.shared.start()
        
        let networkService = NetworkService()
        let homeVM = HomeViewModel(networkService: networkService)
        let homeVC = HomeView(viewModel: homeVM)
        let navForHome = UINavigationController(rootViewController: homeVC)
        navForHome.tabBarItem = UITabBarItem(
            title: "Главная",
            image: UIImage(systemName: "house"),
            tag: 0
        )

        let reminderVM = ReminderViewModel()
        let reminderVC = ReminderView(viewModel: reminderVM)
        let navForReminder = UINavigationController(rootViewController: reminderVC)
        navForReminder.tabBarItem = UITabBarItem(
            title: "Задачи",
            image: UIImage(systemName: "checkmark.circle.fill"),
            tag: 1
        )
        
        let noteVC = NoteView()
        let navForNotes = UINavigationController(rootViewController: noteVC)
        navForNotes.tabBarItem = UITabBarItem(
            title: "Записи",
            image: UIImage(systemName: "list.bullet"),
            tag: 2
        )
        
        let webVC = WebViewController(url: "https://ya.ru/")
        let navForWeb = UINavigationController(rootViewController: webVC)
        navForWeb.tabBarItem = UITabBarItem(
            title: "Страница",
            image: UIImage(systemName: "graduationcap.fill"),
            tag: 2
        )

        tabBar.viewControllers = [navForHome, navForReminder, navForNotes, navForWeb]

        return tabBar
    }
}
