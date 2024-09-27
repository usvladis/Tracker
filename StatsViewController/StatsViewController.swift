//
//  StatsViewController.swift
//  Tracker
//
//  Created by Владислав Усачев on 27.06.2024.
//

import UIKit

final class StatsViewController: UIViewController {
    
    private let trackerRecordStore = TrackerRecordStore()
    private var trackers: [Tracker] = []
    var completedTrackers: [TrackerRecord] = []
    
    private let label = TrackerTextLabel(text: "Анализировать пока нечего", fontSize: 12, fontWeight: .medium)
    private let statView = CustomStatisticView(title: "0", subtitle: localizedString(key:"doneTrackersCount"))
    
    private var statsLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "YP Black")
        label.text = localizedString(key: "statisticTitle")
        label.font = UIFont(name: "YSDisplay-Bold", size: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var image: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "emojiMock")
        return image
    }()
    
    private lazy var emptyHolderStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [image,label])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStat()
        mainScreenContent()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        setupAppearance()
    }
    
    private func mainScreenContent() {
        statView.configValue(value: calcStatData())
        emptyHolderStackView.isHidden = completedTrackers.count != 0
        statView.isHidden = completedTrackers.count == 0
    }
    
    private func updateStat() {
        completedTrackers = trackerRecordStore.fetchAllRecords()
        statView.configValue(value: calcStatData())
    }
    
    private func setupAppearance() {
        view.backgroundColor = UIColor(named: "YP White")
        view.addSubview(emptyHolderStackView)
        view.addSubview(statView)
        view.addSubview(statsLabel)
        statView.frame = CGRect(x: 16, y: self.view.frame.midY - 45, width: self.view.frame.width - 32, height: 90)
        statView.setupView()
        
        NSLayoutConstraint.activate([
            statsLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -50),
            statsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyHolderStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyHolderStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            image.heightAnchor.constraint(equalToConstant: 80),
            image.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func calcStatData() -> Int {
        completedTrackers.count
    }
    
}

final class TrackerTextLabel: UILabel {
    init(text: String,fontSize: CGFloat, fontWeight: UIFont.Weight) {
        super.init(frame: .zero)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.text = text
        self.numberOfLines = 0
        self.textAlignment = .center
        self.font = .systemFont(ofSize: fontSize, weight: fontWeight)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


final class CustomStatisticView: UIView {
    
    init(title: String, subtitle: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        subLabel.text = subtitle
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "YP White")
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 34, weight: .bold)
        title.textColor = UIColor(named: "YP Black")
        return title
    }()
    
    private lazy var subLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .systemFont(ofSize: 12, weight: .bold)
        title.textColor = UIColor(named: "YP Black")
        return title
    }()
    
    func configValue(value: Int) {
        titleLabel.text = String(value)
    }
    
    
    func setupView() {
        layer.cornerRadius = 15
        addGradienBorder(colors: [.red, .green, .blue])
        containerView.addSubview(titleLabel)
        containerView.addSubview(subLabel)
        clipsToBounds = true
        addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 1),
            containerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -1),
            containerView.topAnchor.constraint(equalTo: topAnchor, constant: 1),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12),
            
            subLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            subLabel.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 12),
        ])
    }
}

extension UIView {
    func addGradienBorder(colors: [UIColor], width: CGFloat = 2) {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1, y: 0.5)
        
        let shape = CAShapeLayer()
        shape.lineWidth = width
        shape.path = UIBezierPath(roundedRect: bounds, cornerRadius: 16).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape
        
        layer.addSublayer(gradient)
    }
}
