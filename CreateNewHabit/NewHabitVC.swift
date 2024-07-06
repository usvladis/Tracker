//
//  NewHabitVC.swift
//  Tracker
//
//  Created by Владислав Усачев on 05.07.2024.
//

import UIKit

class NewHabitVC: UIViewController {

    // MARK: - UI Elements
    private var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var backgroundView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новая привычка"
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "    Введите название трекера"
        textField.font = UIFont(name: "YSDisplay-Medium", size: 17)
        textField.backgroundColor = UIColor(named: "TextFieldColor")
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.layer.cornerRadius = 10
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        tableView.tableHeaderView = nil
        tableView.sectionHeaderHeight = 0
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "Emoji"
        label.font = UIFont(name: "YSDisplay-Bold", size: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "emojiCell")
        return collectionView
    }()
    
    private var colorLabel: UILabel = {
        let label = UILabel()
        label.text = "Цвет"
        label.font = UIFont(name: "YSDisplay-Bold", size: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "colorCell")
        return collectionView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .gray
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        emojiCollectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseIdentifier)
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        colorCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseIdentifier)
        setUpView()
    }
    
    // Данные для коллекций
    let emojiData = ["😊", "😍", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🤖", "🤔", "🙏", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😴"]
    let colorData = [UIColor.red, UIColor.orange, UIColor.blue, UIColor.green, UIColor.purple, UIColor.systemPink, UIColor.gray, UIColor.brown, UIColor.yellow, UIColor.magenta, UIColor.cyan, UIColor.darkGray, UIColor.lightGray, UIColor.systemBlue, UIColor.systemTeal, UIColor.systemIndigo, UIColor.systemGreen, UIColor.systemYellow]


    // MARK: - Setup UI
    private func setUpView() {
        view.backgroundColor = .white
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(backgroundView)
        backgroundView.addSubview(titleLabel)
        backgroundView.addSubview(nameTextField)
        backgroundView.addSubview(cancelButton)
        backgroundView.addSubview(createButton)
        backgroundView.addSubview(tableView)
        backgroundView.addSubview(emojiLabel)
        backgroundView.addSubview(colorLabel)
        backgroundView.addSubview(emojiCollectionView)
        backgroundView.addSubview(colorCollectionView)
        
        let width = (view.frame.width - 48) / 2
        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalToConstant: view.frame.width),
            
            backgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            backgroundView.heightAnchor.constraint(equalToConstant: 890),

            
            
            titleLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            
            nameTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            nameTextField.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            
            tableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 150),
            
            emojiLabel.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 28),
            emojiLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 12),
            emojiCollectionView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 192),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 24),
            colorLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 28),
            colorLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor, constant: 12),
            colorCollectionView.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 192),
            
            cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 20),
            cancelButton.widthAnchor.constraint(equalToConstant: width),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            createButton.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -20),
            createButton.widthAnchor.constraint(equalToConstant: width),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true) {
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    private func navigateToCategory() {
        // Ваша логика перехода к экрану "Категория"
    }
    
    private func navigateToSchedule() {
        // Ваша логика перехода к экрану "Расписание"
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.modalPresentationStyle = .popover
        present(scheduleViewController, animated: true, completion: nil)
    }
}

extension NewHabitVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
        } else if indexPath.row == 1 {
            cell.textLabel?.text = "Расписание"
        }
        cell.textLabel?.font = UIFont(name: "YSDisplay-Medium", size: 17)
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .clear
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
}

extension NewHabitVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == emojiCollectionView {
            return emojiData.count
        } else if collectionView == colorCollectionView {
            return colorData.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseIdentifier, for: indexPath) as! EmojiCell
            cell.emojiLabel.text = emojiData[indexPath.item]
            return cell
        } else if collectionView == colorCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseIdentifier, for: indexPath) as! ColorCell
            cell.contentView.backgroundColor = colorData[indexPath.item]
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == emojiCollectionView {
            let side = (collectionView.frame.width - 5 * 10) / 6
            return CGSize(width: side, height: side)
        } else if collectionView == colorCollectionView {
            let side = (collectionView.frame.width - 6 * 10) / 6
            return CGSize(width: side, height: side)
        }
        return CGSize(width: 40, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            navigateToCategory()
        } else if indexPath.row == 1 {
            navigateToSchedule()
        }
    }
}

