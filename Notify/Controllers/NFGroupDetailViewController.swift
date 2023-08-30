//
//  NFGroupDetailViewController.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import UIKit

protocol NFGroupDetailViewControllerDelegate: NSObjectProtocol {
    func groupDetailViewController(_ viewController: NFGroupDetailViewController, didUpdateDetailsOf group: NFGroup)
}

final class NFGroupDetailViewController: UITableViewController {
    // MARK: - Properties
    private let groupId: String
    private var group: NFCDGroup?
    private let headerReuseIdentifier = "default-header"
    private let cellReuseIdentifier = "default-cell"
    weak var delegate: NFGroupDetailViewControllerDelegate?
    private var shouldEditTitle: Bool
    
    
    // MARK: - Views
    private let toolbar = UIToolbar()
    
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configViews()
        NFCoreDataService.shared.fetchGroup(havingId: groupId) { result in
            switch result {
            case .success(let group):
                DispatchQueue.main.async {
                    self.group = group
                    self.tableView.reloadSections(.init(integer: .zero), with: .automatic)
                }
            case .failure(let failure):
                debugPrint(#function, failure)
            }
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let group, group.alerts, let id = group.groupId, let date = group.date, let message = (group.items?.array.randomElement() as? NFCDGroupItem)?.title {
            NFNotificationManager.shared.setReminder(id: id, date: date, message: message)
        }
        NFCoreDataService.shared.saveData { result in
            switch result {
            case .success: break
            case .failure(let failure):
                debugPrint(#function, failure)
            }
        }
    }
    
    
    // MARK: - Configurations
    private func configViews() {
        configItemsListView()
        configToolbar()
    }
    private func addNewItem() {
        let newItem = NFCoreDataService.shared.createNewGroupItem()
        group?.insertIntoItems(newItem, at: .zero)
        let firstIndexPath = IndexPath(row: .zero, section: .zero)
        tableView.insertRows(at: [firstIndexPath], with: .automatic)
        guard let textCell = tableView.cellForRow(at: firstIndexPath) as? NFTextTableViewCell else { return }
        textCell.textView.becomeFirstResponder()
    }
    private func configToolbar() {
        toolbarItems = [
            UIBarButtonItem(systemItem: .flexibleSpace),
            UIBarButtonItem(title: "Add Item", primaryAction: UIAction(handler: { _ in
                self.addNewItem()
            })),
            UIBarButtonItem(systemItem: .flexibleSpace),
        ]
        navigationController?.setToolbarHidden(false, animated: true)
    }
    
    
    // MARK: - Constructors
    required init(groupId: String) {
        self.groupId = groupId
        shouldEditTitle = false
        super.init(style: .insetGrouped)
    }
    required init() {
        let newGroup = NFCoreDataService.shared.createNewGroup()
        self.groupId = newGroup.groupId ?? ""
        shouldEditTitle = true
        super.init(style: .insetGrouped)
    }
    required init?(coder: NSCoder) {
        let newGroup = NFCoreDataService.shared.createNewGroup()
        self.groupId = newGroup.groupId ?? ""
        shouldEditTitle = true
        super.init(coder: coder)
    }
}

// MARK: - ItemsListView
extension NFGroupDetailViewController {
    private func configItemsListView() {
        tableView.keyboardDismissMode = .onDrag
        tableView.register(NFGroupDetailHeaderView.self, forHeaderFooterViewReuseIdentifier: headerReuseIdentifier)
        tableView.register(NFTextTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    }
    
    // MARK: DataSource
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerReuseIdentifier)
        guard let group, let detailHeaderView = headerView as? NFGroupDetailHeaderView else { return headerView }
        detailHeaderView.delegate = self
        if shouldEditTitle {
            detailHeaderView.titleTextView.text = nil
            detailHeaderView.titleTextView.setMarkedText(group.title, selectedRange: .init(location: group.title?.count ?? .zero, length: 0))
            detailHeaderView.titleTextView.becomeFirstResponder()
            shouldEditTitle = false
        } else {
            detailHeaderView.updateGroup(title: group.title, date: group.date, alerts: group.alerts)
        }
        return detailHeaderView
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        group?.items?.count ?? .zero
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        guard let textCell = cell as? NFTextTableViewCell, let items = group?.items?.array as? [NFCDGroupItem], items.count > indexPath.row else { return cell }
        textCell.delegate = self
        textCell.updateText(items[indexPath.row].title)
        return textCell
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete,
              let group, let items = group.items?.array as? [NFCDGroupItem], items.count > indexPath.row else { return }
        let item = items[indexPath.row]
        NFCoreDataService.shared.viewContext.delete(item)
        group.removeFromItems(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let group, let items = group.items?.array as? [NFCDGroupItem],
              indexPath.row < items.count, let title = items[indexPath.row].title else { return UITableView.automaticDimension }
        return title.getEstimatedHeight(inTargetWidth: tableView.frame.width-40, havingInsets: .init(top: 4, left: 16, bottom: 4, right: 16))+16
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        (group?.title ?? "").getEstimatedHeight(inTargetWidth: tableView.frame.width-40, havingInsets: .init(top: 4, left: 16, bottom: 4, right: 16), font: .boldSystemFont(ofSize: 28))+62
    }
}


// MARK: -
extension NFGroupDetailViewController: NFGroupDetailHeaderViewDelegate {
    func groupDetailHeaderView(_ headerView: NFGroupDetailHeaderView, didUpdate property: NFGroupDetailHeaderProperty) {
        switch property {
        case .title(let value):
            group?.title = value
        case .date(let value):
            group?.date = value
        case .alerts(let value):
            group?.alerts = value
        }
        tableView.reloadSections(.init(integer: .zero), with: .automatic)
    }
}


// MARK: -
extension NFGroupDetailViewController: NFTextTableViewCellDelegate {
    func textTableViewCell(_ cell: NFTextTableViewCell, didUpdate property: NFTextTableViewCellProperty) {
        guard let index = tableView.indexPath(for: cell)?.row else { return }
        switch property {
        case .title(let value):
            guard value.replacingOccurrences(of: " ", with: "").isEmpty == false else {
                group?.removeFromItems(at: .zero)
                tableView.deleteRows(at: [.init(row: .zero, section: .zero)], with: .automatic)
                return
            }
            if let items = group?.items?.array as? [NFCDGroupItem], items.count > index {
                items[index].title = value
            } else {
                let newItem = NFCoreDataService.shared.createNewGroupItem()
                group?.insertIntoItems(newItem, at: .zero)
            }
        }
        tableView.reloadSections(.init(integer: .zero), with: .automatic)
    }
}
