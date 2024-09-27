//
//  FilterCategoryViewController.swift
//  Tracker
//
//  Created by Владислав Усачев on 10.09.2024.
//

import UIKit

enum FilterCase: Int, CaseIterable {
  case all
  case today
  case complete
  case uncomplete
  
  var title: String {
    switch self {
    case .all:
      return localizedString(key: "allTrackers")
    case .today:
      return localizedString(key: "todayTrackers")
    case .complete:
      return localizedString(key: "doneTrackers")
    case .uncomplete:
      return localizedString(key: "unDoneTrackers")
    }
  }
}

protocol FilterDelegate: AnyObject {
  func setFilter(_ filterState: FilterCase)
}

final class FilterCategoryViewController: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = localizedString(key: "filterTitle")
        label.textColor = UIColor(named: "YP Black")
        label.font = UIFont(name: "YSDisplay-Medium", size: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        tableView.tableHeaderView = nil
        tableView.sectionHeaderHeight = 0
        tableView.backgroundColor = UIColor(named: "YP Background")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    weak var filterDelegate: FilterDelegate?
    
    var filterState: FilterCase = .all
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    private func setUpView() {
        view.backgroundColor = UIColor(named: "YP White")
        tableView.delegate = self
        tableView.dataSource = self
        
        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 27),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
}

extension FilterCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilterCase.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.backgroundColor = .clear
        let item = FilterCase(rawValue: indexPath.row)!
        cell.textLabel?.text = item.title
        cell.textLabel?.textColor = UIColor(named: "YP Black")
        cell.textLabel?.font = UIFont(name: "YSDisplay-Medium", size: 17)
        cell.accessoryType = item == filterState ? .checkmark : .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView(frame: .zero)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      guard let selectedFilter = FilterCase(rawValue: indexPath.row) else { return }
      
      filterState = selectedFilter
      filterDelegate?.setFilter(selectedFilter)      
      self.dismiss(animated: true)
    }
}
