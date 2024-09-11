//
//  EditCategoryViewController.swift
//  Tracker
//
//  Created by Владислав Усачев on 10.09.2024.
//

import UIKit

protocol EditCategoryViewControllerDelegate: AnyObject {
    func editCategoryScreen(_ screen: EditCategoryViewController, didEditCategory category: TrackerCategory, with newTitle: String)
}

final class EditCategoryViewController: UIViewController {
    
    weak var delegate: EditCategoryViewControllerDelegate?
    var category: TrackerCategory?
        
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Редактирование категории"
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
    
    private let saveButton: UIButton = {
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
        
        if let category = category {
            textField.text = category.title
        }
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
        view.addSubview(saveButton)
        saveButton.addTarget(self, action: #selector(saveCategory), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 60),
            saveButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    @objc private func saveCategory() {
        guard let newTitle = textField.text, !newTitle.isEmpty, let category = category else {
            // Показываем ошибку или сообщение пользователю, если данные невалидные
            print("Error: категория или название отсутствуют")
            return
        }
        
        // Передаем обновленное название через делегат
        delegate?.editCategoryScreen(self, didEditCategory: category, with: newTitle)
        dismiss(animated: true)
    }
}

