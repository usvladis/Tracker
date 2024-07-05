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
    
    var trackers = [Tracker]()
    var filteredTrackers: [TrackerCategory] = []
    
    var categories: [TrackerCategory] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var completedTrackers: [TrackerRecord] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        loadMockData()
        filterTrackersForCurrentDay()
    }
    
    private func loadMockData() {
        let tracker1 = Tracker(id: UUID(), title: "Кошка заслонила камеру на созвоне", color: .orange, emoji: "😻", schedule: [DayOfWeek.wednesday])
        let tracker2 = Tracker(id: UUID(), title: "Бабушка прислала открытку в ватсапе", color: .red, emoji: "🌸", schedule: [DayOfWeek.thursday])
        let tracker3 = Tracker(id: UUID(), title: "Cвидание в апреле", color: .purple, emoji: "❤️", schedule: [DayOfWeek.wednesday])
        let tracker4 = Tracker(id: UUID(), title: "Поливать растения", color: .systemGreen
                               , emoji: "❤️", schedule: [DayOfWeek.wednesday])
        let category1 = TrackerCategory(title: "Домашний уют", trackers: [tracker4])
        let category2 = TrackerCategory(title: "Радостные мелочи", trackers: [tracker1, tracker2, tracker3])
        categories.append(category1)
        categories.append(category2)
        
    }
    
    private func filterTrackers(for day: DayOfWeek) {
        filteredTrackers = categories.map { category in
            let filteredTrackers = category.trackers.filter { $0.schedule.contains(day) }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }.filter { !$0.trackers.isEmpty }
        collectionView.reloadData()
    }
    
    private func filterTrackersForCurrentDay() {
        let calendar = Calendar.current
        let currentDate = Date()
        let dayOfWeek = calendar.component(.weekday, from: currentDate)
        
        // Преобразуем dayOfWeek для соответствия enum DayOfWeek
        let dayOfWeekIndex = (dayOfWeek + 5) % 7
        let currentDay = DayOfWeek.allCases[dayOfWeekIndex]
        
        filterTrackers(for: currentDay)
        updatePlaceholderVisibility()
    }
    
    @objc private func addButtonTapped() {
        let newVC = CreateTrackerViewController()
        newVC.modalPresentationStyle = .popover
        present(newVC, animated: true, completion: nil)
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let selectedDate = dateFormatter.string(from: sender.date)
        
        // Определяем день недели
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: sender.date)
        
        // Поскольку в Calendar.current Sunday (воскресенье) - это 1, Monday (понедельник) - это 2 и так далее, нам нужно корректировать индекс для сопоставления с enum DayOfWeek
        let dayOfWeekIndex = (dayOfWeek + 5) % 7 // Преобразование для соответствия DayOfWeek
        
        let selectedDay = DayOfWeek.allCases[dayOfWeekIndex]
        
        // Фильтруем трекеры по выбранному дню недели
        filterTrackers(for: selectedDay)
        updatePlaceholderVisibility()
    }
    
    private func updatePlaceholderVisibility() {
        if filteredTrackers.isEmpty {
            setupImageView() // Отображаем плейсхолдер-картинку
            descriptionLabel.isHidden = false
            imageMock.isHidden = false
        } else {
            descriptionLabel.isHidden = true
            imageMock.isHidden = true
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
    }
    
    private func setUpNavigationBar() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .black
        self.navigationItem.leftBarButtonItem = addButton
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        datePicker.addTarget(self, action:  #selector(datePickerValueChanged(_:)), for: .valueChanged)
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
        searchBar.placeholder = "Храни Господь Практикум"
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
        layout.headerReferenceSize = .init(width: view.frame.size.width, height: 60)
        
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
}

//MARK: - DataSource & DelegateFlowLayout

extension TrackerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTrackers[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCollectionViewCell", for: indexPath) as? TrackerCollectionViewCell else {
            fatalError("Unable to dequeue TrackerCollectionViewCell")
        }
        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.item]
        cell.configure(with: tracker, completedDays: 5) // Placeholder value for completed days
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
            view.titleLabel.text = filteredTrackers[indexPath.section].title
            return view
        default: return UICollectionReusableView()
        }
    }
}
