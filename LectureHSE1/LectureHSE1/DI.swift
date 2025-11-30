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

        let homeVC = HomeView()
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
            title: "Список",
            image: UIImage(systemName: "list.bullet"),
            tag: 1
        )

        tabBar.viewControllers = [navForHome, navForReminder]

        return tabBar
    }
}
