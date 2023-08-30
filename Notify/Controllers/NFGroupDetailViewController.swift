//
//  NFGroupDetailViewController.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import UIKit

final class NFGroupDetailViewController: UITableViewController {
    // MARK: - Properties
    private let group: NFGroup
    private let headerReuseIdentifier = "default-header"
    private let cellReuseIdentifier = "default-cell"
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
    }
    
    
    // MARK: - Configurations
    private func configViews() {
        view.backgroundColor = .systemBackground
        configNavigationBar()
        configItemsListView()
    }
    private func configNavigationBar() {
        
    }
    
    
    // MARK: - Constructors
    required init(group: NFGroup) {
        self.group = group
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        group = .init(id: "", title: "", date: .init(), items: [])
        super.init(coder: coder)
    }
}

// MARK: - TableView
extension NFGroupDetailViewController {
    private func configItemsListView() {
        tableView.register(NFGroupDetailHeaderView.self, forHeaderFooterViewReuseIdentifier: headerReuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    // MARK: DataSource
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier)
        guard let detailHeaderView = headerView as? NFGroupDetailHeaderView else { return headerView }
        detailHeaderView.updateGroup(title: group.title, date: group.date)
        return detailHeaderView
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        group.items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        cell.textLabel?.numberOfLines = .zero
        if group.items.count > indexPath.row {
            cell.textLabel?.text = group.items[indexPath.row]
        }
        return cell
    }
    
    // MARK: Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
