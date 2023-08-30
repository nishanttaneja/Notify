//
//  NFGroupsViewController.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import UIKit

class NFGroupsViewController: UITableViewController {
    // MARK: - Properties
    private var groups: [NFGroup] = NFGroup.mockData //[]
    private let cellReuseIdentifier = "default-cell"
    
    
    // MARK: - Views
    
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
    }
    
    
    // MARK: - Configurations
    private func configViews() {
        configNavigationBar()
        configGroupsListView()
    }
    private func configNavigationBar() {
        title = "Groups"
    }
    
    
    // MARK: - Constructors
    required init() {
        super.init(style: .insetGrouped)
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

// MARK: - TableView
extension NFGroupsViewController {
    private func configGroupsListView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    // MARK: DataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        groups.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.numberOfLines = .zero
        if groups.count > indexPath.row {
            cell.textLabel?.text = groups[indexPath.row].title
        }
        return cell
    }
    
    // MARK: Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard groups.count > indexPath.row else { return }
        let detailsVC = NFGroupDetailViewController(group: groups[indexPath.row])
        navigationController?.pushViewController(detailsVC, animated: true)
    }
}
