//
//  StatsNavBarController.swift
//  Tracker
//
//  Created by Владислав Усачев on 10.09.2024.
//

import UIKit

class StatsNavBarController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Создаем и устанавливаем FirstViewController в качестве корневого контроллера
        let statsViewController = StatsViewController()
        self.viewControllers = [statsViewController]
    }
}

