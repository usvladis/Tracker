//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Владислав Усачев on 02.07.2024.
//

import UIKit

protocol CreateTrackerDelegate: AnyObject{
    func didCreateNewTracker(_ tracker: Tracker, _ category: String)
}

final class CreateTrackerViewController: UIViewController{
    
    weak var delegate: CreateTrackerDelegate?
    
    let habitButton = UIButton()
    let irregularEventButton = UIButton()
    let titleLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    private func setUpView() {
        view.backgroundColor = UIColor(named: "YP White")
        setUpLabel()
        setUpButtons()
    }
    
    private func setUpLabel() {
        titleLabel.text = localizedString(key: "createTrackerLabel")
        titleLabel.font = UIFont(name: "YSDisplay-Medium", size: 16)
        titleLabel.textColor = UIColor(named: "YP Black")
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            //titleLabel.heightAnchor.constraint(equalToConstant: 100),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    private func setUpButtons() {
        habitButton.setTitle(localizedString(key: "habbitButton"), for: .normal)
        habitButton.setTitleColor(UIColor(named: "YP White"), for: .normal)
        habitButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        habitButton.titleLabel?.textAlignment = .center
        habitButton.backgroundColor = UIColor(named: "YP Black")
        habitButton.layer.cornerRadius = 15
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(habitButton)
        
        irregularEventButton.setTitle(localizedString(key: "irregularEventButton"), for: .normal)
        irregularEventButton.setTitleColor(UIColor(named: "YP White"), for: .normal)
        irregularEventButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        irregularEventButton.titleLabel?.textColor = UIColor(named: "YP White")
        irregularEventButton.titleLabel?.textAlignment = .center
        irregularEventButton.backgroundColor = UIColor(named: "YP Black")
        irregularEventButton.tintColor = UIColor(named: "YP White")
        irregularEventButton.layer.cornerRadius = 15
        irregularEventButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(irregularEventButton)
        
        NSLayoutConstraint.activate([
            habitButton.heightAnchor.constraint(equalToConstant: 60),
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            habitButton.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 8),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16)
            
            
        ])
        
        habitButton.addTarget(self, action: #selector(didTapHabitButton), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(didTapIrregularEventButton), for: .touchUpInside)
        
    }
    
    @objc  func didTapHabitButton() {
        let newVC = NewHabitVC()
        newVC.delegate = self
        newVC.modalPresentationStyle = .popover
        present(newVC, animated: true, completion: nil)
    }
    
    @objc  func didTapIrregularEventButton() {
        let newVC = CreateNewIrregularEventViewController()
        newVC.delegate = self
        newVC.modalPresentationStyle = .popover
        present(newVC, animated: true, completion: nil)
    }
}

extension CreateTrackerViewController: NewHabitViewControllerDelegate{
    func didCreateNewHabit(_ tracker: Tracker, _ category: String) {
        delegate?.didCreateNewTracker(tracker, category)
    }
}
