//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Владислав Усачев on 06.09.2024.
//

import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func categoryScreen(_ screen: CategoriesViewController, didSelectedCategory category: TrackerCategory)
}

final class CategoriesViewController: UIViewController, NewCategoryViewControllerDelegate {
    
    weak var delegate: CategoryViewControllerDelegate?
    private var viewModel: CategoryViewModel!
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Категории"
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textColor = UIColor(named: "YP Black")
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        tableView.isScrollEnabled = true
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .clear
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: CategoryTableViewCell.reuseIdentifier)
        return tableView
    }()
    
    private let addCategory: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(UIColor(named: "YP White"), for: .normal)
        button.backgroundColor = UIColor(named: "YP Black")
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setupViewModel()
        setupBindings()
        loadCategories()
    }
    
    private func setupViewModel() {
        viewModel = CategoryViewModel(store: TrackerCategoryStore())
    }

    private func setupBindings() {
        viewModel.onCategoriesChanged = { [weak self] categories in
            self?.tableView.reloadData()
            self?.mainScreenContent()
        }

        viewModel.onCategorySelected = { [weak self] category in
            guard let self = self else { return }
            self.delegate?.categoryScreen(self, didSelectedCategory: category)
        }
    }
    
    private func setUpUI() {
        setUpView()
        setupCategoryView()
    }
    
    private func setUpView() {
        view.backgroundColor = UIColor(named: "YP White")
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(addCategory)
        view.addSubview(tableView)
        
        addCategory.addTarget(self, action: #selector(addCategoryTapped), for: .touchUpInside)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            addCategory.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            addCategory.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategory.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategory.heightAnchor.constraint(equalToConstant: 60),
            addCategory.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategory.topAnchor, constant: -16)
        ])
    }
    
    private func setupCategoryView() {
        
        view.addSubview(stackView)

        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "starMock")
        stackView.addArrangedSubview(image)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Привычки и события можно \nобъединить по смыслу"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.textColor = UIColor(named: "YP Black")
        label.textAlignment = .center
        stackView.addArrangedSubview(label)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.heightAnchor.constraint(equalToConstant: 80),
            image.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    @objc
    private func addCategoryTapped() {
        let newCategoryViewController = NewCategoryViewController()
        newCategoryViewController.delegate = self
        newCategoryViewController.modalPresentationStyle = .popover
        present(newCategoryViewController, animated: true)
        
    }
    
    func newCategoryScreen(_ screen: NewCategoryViewController, didAddCategoryWithTitle title: String) {
        viewModel.addCategory(title: title)
    }

    private func loadCategories() {
        viewModel.loadCategories()
    }
    
    private func mainScreenContent() {
        if viewModel.numberOfCategories() == 0 {
            tableView.isHidden = true
            stackView.isHidden = false
        } else {
            tableView.isHidden = false
            stackView.isHidden = true
        }
    }
}

extension CategoriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCategories()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier, for: indexPath) as! CategoryTableViewCell
        let category = viewModel.category(at: indexPath.row)
        cell.configure(with: category)
        
        let interaction = UIContextMenuInteraction(delegate: self)
        cell.addInteraction(interaction)
        
        // Сбросим маску на случай, если ячейка будет переиспользована
        cell.layer.mask = nil
        
        // Создание переменной для хранения нужных углов
        var corners: UIRectCorner = []
        
        // Если это первая ячейка, закругляем верхние углы
        if indexPath.row == 0 {
            corners.formUnion([.topLeft, .topRight])
        }
        
        // Если это последняя ячейка, закругляем нижние углы
        if indexPath.row == viewModel.numberOfCategories() - 1 {
            corners.formUnion([.bottomLeft, .bottomRight])
        }
        
        // Применяем закругления только если углы есть
        if !corners.isEmpty {
            // Обновляем layout после того, как ячейка добавлена
            DispatchQueue.main.async {
                let maskPath = UIBezierPath(roundedRect: cell.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16))
                let maskLayer = CAShapeLayer()
                maskLayer.path = maskPath.cgPath
                cell.layer.mask = maskLayer
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.dismiss(animated: true)
        }
    }
}

extension CategoriesViewController: UIContextMenuInteractionDelegate {
    
    // Создаем меню при долгом нажатии на ячейку
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        // Определяем индекс ячейки, которая была долгим нажатием
        guard let cell = interaction.view as? CategoryTableViewCell,
              let indexPath = tableView.indexPath(for: cell) else { return nil }
        
        let category = viewModel.category(at: indexPath.row)
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Редактировать", image: UIImage(systemName: "pencil")) { _ in
                // Переход на экран редактирования
                self.editCategory(category)
            }
            
            let deleteAction = UIAction(title: "Удалить", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                // Удаление категории
                self.deleteCategory(at: indexPath)
            }
            
            // Возвращаем контекстное меню с опциями
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
    }
    
    private func editCategory(_ category: TrackerCategory) {
        // Переход на экран редактирования категории
        let editVC = EditCategoryViewController()
        editVC.category = category  // Передаем категорию в контроллер редактирования
        editVC.delegate = self // Устанавливаем делегат для обновления
        editVC.modalPresentationStyle = .popover
        present(editVC, animated: true)
    }
    
    private func deleteCategory(at indexPath: IndexPath) {
        _ = viewModel.category(at: indexPath.row)
        
        // Создаем Alert Controller
        let alertController = UIAlertController(title: "Эта категория точно не нужна?",
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        // Добавляем кнопку "Удалить"
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { _ in
            // Удаляем категорию из ViewModel
            self.viewModel.deleteCategory(at: indexPath.row)
        }
        
        // Добавляем кнопку "Отменить"
        let cancelAction = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        
        // Добавляем действия в контроллер
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        // Показываем Alert Controller
        present(alertController, animated: true, completion: nil)
    }
}

extension CategoriesViewController: EditCategoryViewControllerDelegate {
    func editCategoryScreen(_ screen: EditCategoryViewController, didEditCategory category: TrackerCategory, with newTitle: String) {
        viewModel.updateCategory(category, with: newTitle)
    }
}

final class CategoryTableViewCell: UITableViewCell {
    static let reuseIdentifier = "CategoryTableViewCell"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        textLabel?.textColor = UIColor(named: "YP Black")
        backgroundColor = UIColor(named: "YP Background")
        selectionStyle = .none
    }

    func configure(with category: TrackerCategory) {
        textLabel?.text = category.title
    }
}
