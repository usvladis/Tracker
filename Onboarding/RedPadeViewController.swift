//
//  RedPadeViewController.swift
//  Tracker
//
//  Created by Владислав Усачев on 20.08.2024.
//

import UIKit

class RedPadeViewController: UIViewController {
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Даже если это не литры воды и йога"
        label.font = UIFont(name: "YSDisplay-Bold", size: 32)
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .black
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 16)
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private var imageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "redOnboardingBackground")
        image.translatesAutoresizingMaskIntoConstraints = false
        
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
    }
    
    private func setUpView() {
        view.addSubview(imageView)
        view.addSubview(button)
        imageView.addSubview(label)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.heightAnchor.constraint(equalToConstant: 60),
            
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -160),
            label.heightAnchor.constraint(equalToConstant: 76)
            
        ])
    }
    
    @objc
    private func buttonTapped() {
        if let onboardingVC = self.parent as? OnboardingViewController {
            onboardingVC.finishOnboarding()
        }
    }
}
