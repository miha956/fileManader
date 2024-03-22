//
//  MainTabBarViewController.swift
//  FileManager
//
//  Created by Миша Вашкевич on 22.03.2024.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.tintColor = .black
        setTabBar()
    }
    
    private func setTabBar() {
        let fileManagerService = FileManagerService()
        let userDefaults = UserDefaultsManager()
        let vc = ViewController(fileManagerService: fileManagerService, userDefaults: userDefaults)
        vc.title = "Documents"
        let navigationController = UINavigationController(rootViewController: vc)
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor = .white
        navigationController.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController.navigationBar.standardAppearance = navBarAppearance
        navigationController.navigationBar.compactAppearance = navBarAppearance
        navigationController.navigationBar.compactScrollEdgeAppearance = navBarAppearance
        navigationController.navigationBar.prefersLargeTitles = true
        
        let settingsVC = SettingViewController(userDefaultsManager: userDefaults)
    
        self.viewControllers = [
            setVC(
                viewController: navigationController,
                title: "Documents",
                image: UIImage(systemName: "doc")),
            setVC(
                viewController: settingsVC,
                title: "Settings",
                image: UIImage(systemName: "gear.circle"))
        ]
    }
    
    private func setVC(viewController: UIViewController, title: String, image: UIImage?) -> UIViewController {
            viewController.tabBarItem.title = title
            viewController.tabBarItem.image = image
            return viewController
        }
}
