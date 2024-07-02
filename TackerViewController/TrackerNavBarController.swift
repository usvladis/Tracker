//
//  TrackerNavBarController.swift
//  Tracker
//
//  Created by Владислав Усачев on 27.06.2024.
//

import UIKit

class TrackerNavBarController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Создаем и устанавливаем FirstViewController в качестве корневого контроллера
        let trackerViewController = TrackerViewController()
        self.viewControllers = [trackerViewController]
    }
}
