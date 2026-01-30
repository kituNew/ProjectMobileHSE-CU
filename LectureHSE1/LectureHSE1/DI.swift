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
        
        let webSocketClient = WebSocketClient()
        let homeVM = HomeViewModel(webSocketClient: webSocketClient)
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

        tabBar.viewControllers = [navForHome, navForReminder, navForNotes]

        return tabBar
    }
}
