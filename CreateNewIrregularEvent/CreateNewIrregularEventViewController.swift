//
//  CreateNewIrregularEventViewController.swift
//  Tracker
//
//  Created by Владислав Усачев on 04.07.2024.
//

import UIKit

class CreateNewIrregularEventViewController: UIViewController {
    
    weak var delegate: NewHabitViewControllerDelegate?
    var trackerVC = TrackerViewController()
    
    private var selectedCategory: TrackerCategory?
    private var selectedEmoji: String = ""
    private var selectedColor: UIColor = .clear
    
    private var habit: [(name: String, pickedSettings: String)] = [
        (name: "Категория", pickedSettings: ""),
        (name: "Расписание", pickedSettings: "")
    ]

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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Новое нерегулярное событие"
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "    Введите название трекера"
        textField.font = UIFont(name: "YSDisplay-Medium", size: 17)
        textField.backgroundColor = UIColor(named: "TextFieldColor")
        textField.layer.cornerRadius = 10
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var clearTextFieldButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "error_clear"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 17, height: 17)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(clearTextFieldButtonClicked), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let tableView: UITableView = {
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
        nameTextField.delegate = self
        // Добавляем жест для скрытия клавиатуры при нажатии на свободное пространство
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        setUpView()
    }
    
    // Данные для коллекций
    let emojiData = ["😊", "😍", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🤖", "🤔", "🙏", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😴"]
    let colorData = [UIColor.cSelection1, UIColor.cSelection2, UIColor.cSelection3, UIColor.cSelection4, UIColor.cSelection5, UIColor.cSelection6, UIColor.cSelection7, UIColor.cSelection8, UIColor.cSelection9, UIColor.cSelection10, UIColor.cSelection11, UIColor.cSelection12, UIColor.cSelection13, UIColor.cSelection14, UIColor.cSelection15, UIColor.cSelection16, UIColor.cSelection17, UIColor.cSelection18]


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
        
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
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
            backgroundView.heightAnchor.constraint(equalToConstant: 815),

            
            
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
            tableView.heightAnchor.constraint(equalToConstant: 75),
            
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
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonTapped() {
        print("Create button tapped")
        guard let trackerTitle = nameTextField.text else {return}
        let newTracker = Tracker(id: UUID(), 
                                 title: trackerTitle, 
                                 color: selectedColor,
                                 emoji: selectedEmoji,
                                 schedule: DayOfWeek.allCases)
        //trackerVC.createNewTracker(tracker: newTracker)
        delegate?.didCreateNewHabit(newTracker, selectedCategory?.title ?? "")
        dismiss(animated: true)
    }
    
    private func navigateToCategory() {
        let categoriesViewController = CategoriesViewController()
        categoriesViewController.delegate = self
        categoriesViewController.modalPresentationStyle = .popover
        present(categoriesViewController, animated: true, completion: nil)
    }
    
    @objc private func textFieldChanged(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            clearTextFieldButton.isHidden = false
        } else {
            clearTextFieldButton.isHidden = true
        }
        checkIfCorrect()
    }
    
    @objc private func clearTextFieldButtonClicked() {
        nameTextField.text = ""
        clearTextFieldButton.isHidden = true
    }
    
    private func checkIfCorrect() {
        if let text = nameTextField.text, !text.isEmpty && selectedEmoji != "" && selectedColor != UIColor.clear && selectedCategory != nil {
            createButton.isEnabled = true
            createButton.backgroundColor = .black
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .gray
        }
    }
}

extension CreateNewIrregularEventViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        if indexPath.row == 0 {
            cell.textLabel?.text = "Категория"
            cell.textLabel?.font = UIFont(name: "YSDisplay-Medium", size: 17)
            cell.textLabel?.textColor = .black
            
            // Устанавливаем текст категории в detailTextLabel
            cell.detailTextLabel?.text = selectedCategory?.title
            cell.detailTextLabel?.textColor = .gray
            cell.detailTextLabel?.font = UIFont(name: "YSDisplay-Medium", size: 17)
            
            cell.backgroundColor = .clear
            cell.accessoryType = .disclosureIndicator
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 {
            navigateToCategory()
        }
    }
}

extension CreateNewIrregularEventViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
            cell.colorView.backgroundColor = colorData[indexPath.item]
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell {
                cell.setSelectedBackground(isSelected: true)
            }
            selectedEmoji = emojiData[indexPath.item]
        } else if collectionView == colorCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCell {
                cell.setSelectedBorder(isSelected: true, color: colorData[indexPath.item])
            }
            selectedColor = colorData[indexPath.item]
        }
        checkIfCorrect()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == emojiCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? EmojiCell {
                cell.setSelectedBackground(isSelected: false)
            }
        } else if collectionView == colorCollectionView {
            if let cell = collectionView.cellForItem(at: indexPath) as? ColorCell {
                cell.setSelectedBorder(isSelected: false, color: .clear)
            }
        }
        checkIfCorrect()
    }
}

extension CreateNewIrregularEventViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension CreateNewIrregularEventViewController: CategoryViewControllerDelegate {
    func categoryScreen(_ screen: CategoriesViewController, didSelectedCategory category: TrackerCategory) {
        selectedCategory = category
        tableView.reloadData()
        checkIfCorrect()
    }
}
