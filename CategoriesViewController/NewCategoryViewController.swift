//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Владислав Усачев on 06.09.2024.
//

import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func newCategoryScreen(_ screen: NewCategoryViewController, didAddCategoryWithTitle title: String)
}

final class NewCategoryViewController: UIViewController {
    
    weak var delegate: NewCategoryViewControllerDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая категория"
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor(named: "TextFieldColor")
        textField.textColor = .black
        textField.placeholder = "Введите название категории"
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.rightView = paddingView
        textField.rightViewMode = .always
        textField.layer.cornerRadius = 16
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    private func setUpUI() {
        view.backgroundColor = .white
        setupCategoryView()
        setUpButton()
    }
    
    private func setupCategoryView() {
        //navigationItem.hidesBackButton = true
        view.addSubview(textField)
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38)
        ])
    }
    
    private func setUpButton() {
        view.addSubview(addButton)
        addButton.addTarget(self, action: #selector(addNewCategory), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func addNewCategory() {
        guard let categoryTitle = textField.text, !categoryTitle.isEmpty else {
            // Показываем ошибку или сообщение пользователю
            return
        }
        delegate?.newCategoryScreen(self, didAddCategoryWithTitle: categoryTitle)
        navigationController?.popViewController(animated: true)
    }
}
