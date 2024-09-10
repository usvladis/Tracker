//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Владислав Усачев on 27.06.2024.
//

import UIKit

final class TrackerViewController: UIViewController{
    
    private var trackerLabel = UILabel()
    private var descriptionLabel = UILabel()
    private var imageMock = UIImageView()
    private var searchBar = UISearchBar()
    private var datePicker = UIDatePicker()
    private var collectionView: UICollectionView!
    private var filterButton = UIButton()
    
    private var viewModel: TrackerViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = TrackerViewModel()
        NotificationCenter.default.addObserver(self, selector: #selector(handleCategoryDeleted(_:)), name: NSNotification.Name("CategoryDeleted"), object: nil)
        
        setUpView()
        setupBindings()
        viewModel.filterTrackersForCurrentDay()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupBindings() {
        viewModel.onVisibleTrackersChanged = { [weak self] visibleTrackers in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                if visibleTrackers.isEmpty {
                    self?.showPlaceholder()
                } else {
                    self?.hidePlaceholder()
                }
            }
        }
        
        viewModel.onCompletedTrackersChanged = { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        viewModel.onCategoriesChanged = { [weak self] categories in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
                if categories.isEmpty {
                    self?.showPlaceholder()
                } else {
                    self?.hidePlaceholder()
                }
            }
        }
        
        viewModel.onSelectedDateChanged = { [weak self] _ in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        viewModel.selectedDate = sender.date
    }
    
    private func showPlaceholder() {
        descriptionLabel.isHidden = false
        imageMock.isHidden = false
    }
    
    private func hidePlaceholder() {
        descriptionLabel.isHidden = true
        imageMock.isHidden = true
    }
    
    @objc private func addButtonTapped() {
        let newVC = CreateTrackerViewController()
        newVC.delegate = self
        newVC.modalPresentationStyle = .popover
        present(newVC, animated: true, completion: nil)
    }
    
    @objc private func filterButtonTapped() {
        let filterCategoryVC = FilterCategoryViewController()
        filterCategoryVC.modalPresentationStyle = .popover
        present(filterCategoryVC, animated: true, completion: nil)
    }
    
    @objc private func handleCategoryDeleted(_ notification: Notification) {
        if let deletedCategory = notification.object as? TrackerCategory {
            viewModel.deleteCategory(deletedCategory)
        }
    }
    //MARK: - SetUpUIView
    private func setUpView() {
        view.backgroundColor = .white
        setUpNavigationBar()
        setupImageView()
        setUpLabels()
        setUpSearchBar()
        setUpCollectionView()
        setUpFilterButton()
    }
    
    private func setUpNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = addButton
        
        datePicker.clipsToBounds = true
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar.firstWeekday = 2
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action:  #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            datePicker.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupImageView() {
        imageMock.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageMock)
        
        // Установим изображение
        imageMock.image = UIImage(named: "starMock")
        imageMock.contentMode = .scaleAspectFill
        
        // Устанавливаем ограничения для ImageView
        NSLayoutConstraint.activate([
            imageMock.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageMock.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageMock.widthAnchor.constraint(equalToConstant: 80),
            imageMock.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func setUpLabels() {
        trackerLabel.textColor = .black
        trackerLabel.text = "Трекеры"
        trackerLabel.font = UIFont(name: "YSDisplay-Bold", size: 34)
        trackerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(trackerLabel)
        
        descriptionLabel.textColor = .black
        descriptionLabel.text = "Что будем отслеживать?"
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont(name: "YSDisplay-Medium", size: 12)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: imageMock.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            trackerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            trackerLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16)
            
        ])
    }
    
    private func setUpSearchBar() {
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBar)
        
        if let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as? UITextField {
            if let backgroundView = textFieldInsideSearchBar.superview?.subviews.first {
                backgroundView.layer.cornerRadius = 10
                backgroundView.clipsToBounds = true
            }
        }
        
        // Устанавливаем фоновый цвет, чтобы скрыть подчеркивания
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        searchBar.barTintColor = .clear
        
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: trackerLabel.bottomAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
    
    private func setUpCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 9
        layout.headerReferenceSize = .init(width: view.frame.size.width, height: 40)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: "TrackerCollectionViewCell")
        collectionView.register(TrackersHeaderReusableView.self,forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "TrackersHeaderReusableView")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    private func setUpFilterButton() {
        filterButton.backgroundColor = .systemBlue
        filterButton.setTitle("Фильтры", for: .normal)
        filterButton.titleLabel?.textColor = .white
        filterButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 17)
        filterButton.layer.cornerRadius = 16
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(filterButton)
        
        filterButton.addTarget(self, action: #selector (filterButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 130),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -130),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

//MARK: - DataSource & DelegateFlowLayout

extension TrackerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModel.visibleTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.visibleTrackers[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCollectionViewCell", for: indexPath) as? TrackerCollectionViewCell else {
            fatalError("Unable to dequeue TrackerCollectionViewCell")
        }
        let tracker = viewModel.visibleTrackers[indexPath.section].trackers[indexPath.item]
        let completedDays = viewModel.completedTrackers.filter { $0.trackerId == tracker.id }.count
        let isCompleted = viewModel.completedTrackers.contains { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: viewModel.selectedDate) }
        
        cell.configure(with: tracker, completedDays: completedDays, isCompleted: isCompleted)
        cell.buttonAction = { [weak self] in
            self?.viewModel.toggleTrackerCompletion(for: tracker)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 9
        let availableWidth = collectionView.frame.width - padding
        let width = availableWidth / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind{
        case UICollectionView.elementKindSectionHeader:
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TrackersHeaderReusableView", for: indexPath) as? TrackersHeaderReusableView else {
                return UICollectionReusableView()
            }
            view.titleLabel.text = viewModel.visibleTrackers[indexPath.section].title
            return view
        default: return UICollectionReusableView()
        }
    }
}

extension TrackerViewController: CreateTrackerDelegate {
    func didCreateNewTracker(_ tracker: Tracker, _ category: String) {
        viewModel.createNewTracker(tracker, category )
    }
}
