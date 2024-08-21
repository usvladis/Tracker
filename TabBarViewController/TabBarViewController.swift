//
//  TabBarViewController.swift
//  Tracker
//
//  Created by Владислав Усачев on 21.08.2024.
//

import UIKit


class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTabBar()
        tabBarBorder()
    }
    
    private func configureTabBar() {
        let trackerViewController = TrackerViewController()
        let statisticsViewController = StatsViewController()
        
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "circle.circle.fill"),
            selectedImage: nil
        )
        
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )

        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        statisticsNavigationController.navigationBar.prefersLargeTitles = true
        
        setViewControllers([trackerViewController, statisticsNavigationController], animated: true)
    }
    
    private func tabBarBorder() {
        let border = UIView()
        border.backgroundColor = .lightGray
        border.translatesAutoresizingMaskIntoConstraints = false
        tabBar.addSubview(border)
        
        border.topAnchor.constraint(equalTo: tabBar.topAnchor).isActive = true
        border.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor).isActive = true
        border.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
}
