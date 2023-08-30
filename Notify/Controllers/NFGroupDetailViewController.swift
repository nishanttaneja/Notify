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
    private var groupHasChanges: Bool = false {
        willSet {
            saveItem.isEnabled = newValue
        }
    }
    private var updatedGroup: NFGroup?
    
    
    // MARK: - Views
    private let toolbar = UIToolbar()
    private var saveItem: UIBarButtonItem!
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
    }
    
    
    // MARK: - Configurations
    private func configViews() {
        configNavigationBar()
        configItemsListView()
        configToolbar()
    }
    private func configNavigationBar() {
        saveItem = UIBarButtonItem(title: "Save", primaryAction: UIAction(handler: { _ in
            debugPrint("Saving group...")
        }))
        saveItem.isEnabled = false
        navigationItem.setRightBarButton(saveItem, animated: true)
    }
    private func configToolbar() {
        toolbarItems = [
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(title: "Add Item", primaryAction: UIAction(handler: { _ in
                debugPrint("start typing...")
            })),
            UIBarButtonItem(systemItem: .flexibleSpace),
        ]
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    
    // MARK: - Constructors
    required init(group: NFGroup) {
        self.group = group
        super.init(style: .insetGrouped)
    }
    required init?(coder: NSCoder) {
        group = .init(id: "", title: "", date: .init(), items: [])
        super.init(coder: coder)
    }
}

// MARK: - ItemsListView
extension NFGroupDetailViewController {
    private func configItemsListView() {
        tableView.keyboardDismissMode = .onDrag
        tableView.register(NFGroupDetailHeaderView.self, forHeaderFooterViewReuseIdentifier: headerReuseIdentifier)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    // MARK: DataSource
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier)
        guard let detailHeaderView = headerView as? NFGroupDetailHeaderView else { return headerView }
        detailHeaderView.delegate = self
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


// MARK: -
extension NFGroupDetailViewController: NFGroupDetailHeaderViewDelegate {
    func heightForTitle(_ text: String, inGroupDetailHeader headerView: NFGroupDetailHeaderView) -> CGFloat {
        headerView.defaultTitleHeight
    }
    func groupDetailHeaderView(_ headerView: NFGroupDetailHeaderView, didUpdate property: NFGroupDetailHeaderProperty) {
        var newGroup = updatedGroup ?? group
        switch property {
        case .title(let value):
            newGroup.title = value
        case .date(let value):
            newGroup.date = value
        }
        updatedGroup = newGroup
        groupHasChanges = group.title != updatedGroup?.title || group.date != updatedGroup?.date
    }
}
