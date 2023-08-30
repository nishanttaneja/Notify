//
//  NFGroupsViewController.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import UIKit

class NFGroupsViewController: UITableViewController {
    // MARK: - Properties
    private var groups: [NFGroup] = []
    private let cellReuseIdentifier = "default-cell"
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NFCoreDataService.shared.fetchGroups { result in
            switch result {
            case .success(let groups):
                DispatchQueue.main.async {
                    self.groups = groups
                    self.tableView.reloadSections(.init(integer: .zero), with: .automatic)
                }
            case .failure(let failure):
                debugPrint(#function, failure)
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NFNotificationManager.shared.requestNotificationAuthorisation()
    }
    
    
    // MARK: - Configurations
    private func configViews() {
        configNavigationBar()
        configGroupsListView()
    }
    private func configNavigationBar() {
        title = "Groups"
        navigationItem.setRightBarButton(UIBarButtonItem(systemItem: .add, primaryAction: UIAction(handler: { _ in
            let newGroupVC = NFGroupDetailViewController()
            newGroupVC.delegate = self
            self.navigationController?.pushViewController(newGroupVC, animated: true)
        })), animated: true)
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
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete, groups.count > indexPath.row else { return }
        groups.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard groups.count > indexPath.row else { return }
        let detailsVC = NFGroupDetailViewController(groupId: groups[indexPath.row].id)
        detailsVC.delegate = self
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
}


// MARK: - DetailsView
extension NFGroupsViewController: NFGroupDetailViewControllerDelegate {
    func groupDetailViewController(_ viewController: NFGroupDetailViewController, didUpdateDetailsOf group: NFGroup) {
//        if let index = groups.firstIndex(where: { $0.id == group.id }) {
//            groups.remove(at: index)
//            groups.insert(group, at: index)
//        } else {
//            groups.insert(group, at: .zero)
//        }
//        tableView.reloadSections(.init(integer: .zero), with: .automatic)
    }
}
