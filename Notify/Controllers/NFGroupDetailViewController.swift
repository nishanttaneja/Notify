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
    private var group: NFGroup
    private let headerReuseIdentifier = "default-header"
    private let cellReuseIdentifier = "default-cell"
    private var groupHasChanges: Bool = false {
        willSet {
            saveItem.isEnabled = newValue
        }
    }
    private var updatedGroup: NFGroup
    weak var delegate: NFGroupDetailViewControllerDelegate?
    private var shouldEditTitle: Bool
    
    
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
    private func updateSaveItemIfNeeded() {
        groupHasChanges = group.title != updatedGroup.title || group.date != updatedGroup.date || group.items != updatedGroup.items || updatedGroup.alerts != group.alerts
    }
    private func performSaveAction() {
        guard groupHasChanges else { return }
        group = updatedGroup
        groupHasChanges = false
        delegate?.groupDetailViewController(self, didUpdateDetailsOf: group)
        tableView.reloadSections(.init(integer: .zero), with: .automatic)
        navigationController?.popViewController(animated: true)
    }
    private func configNavigationBar() {
        saveItem = UIBarButtonItem(title: "Save", primaryAction: UIAction(handler: { _ in
            self.performSaveAction()
        }))
        saveItem.isEnabled = false
        navigationItem.setRightBarButton(saveItem, animated: true)
    }
    private func addNewItem() {
        updatedGroup.items.insert("", at: .zero)
        let firstIndexPath = IndexPath(row: .zero, section: .zero)
        tableView.insertRows(at: [firstIndexPath], with: .automatic)
        updateSaveItemIfNeeded()
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
    required init(group: NFGroup) {
        self.group = group
        self.updatedGroup = group
        shouldEditTitle = false
        super.init(style: .insetGrouped)
    }
    required init() {
        self.group = NFGroup(id: UUID().uuidString, title: "Untitled Group", date: .now, items: [])
        self.updatedGroup = group
        shouldEditTitle = true
        super.init(style: .insetGrouped)
    }
    required init?(coder: NSCoder) {
        group = .init(id: UUID().uuidString, title: "Untitled Group", date: .now, items: [])
        updatedGroup = group
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
        guard let detailHeaderView = headerView as? NFGroupDetailHeaderView else { return headerView }
        detailHeaderView.delegate = self
        if shouldEditTitle {
            detailHeaderView.titleTextView.text = nil
            detailHeaderView.titleTextView.setMarkedText(group.title, selectedRange: .init(location: group.title.count, length: 0))
            detailHeaderView.titleTextView.becomeFirstResponder()
            shouldEditTitle = false
        } else {
            detailHeaderView.updateGroup(title: updatedGroup.title, date: updatedGroup.date, alerts: updatedGroup.alerts)
        }
        return detailHeaderView
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        updatedGroup.items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath)
        guard let textCell = cell as? NFTextTableViewCell, updatedGroup.items.count > indexPath.row else { return cell }
        textCell.delegate = self
        textCell.updateText(updatedGroup.items[indexPath.row])
        return textCell
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard updatedGroup.items.count > indexPath.row else { return }
        updatedGroup.items.remove(at: indexPath.row)
        updateSaveItemIfNeeded()
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
        guard indexPath.row < updatedGroup.items.count else { return UITableView.automaticDimension }
        return updatedGroup.items[indexPath.row].getEstimatedHeight(inTargetWidth: tableView.frame.width-40, havingInsets: .init(top: 4, left: 16, bottom: 4, right: 16))+16
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        updatedGroup.title.getEstimatedHeight(inTargetWidth: tableView.frame.width-40, havingInsets: .init(top: 4, left: 16, bottom: 4, right: 16), font: .boldSystemFont(ofSize: 28))+62
    }
}


// MARK: -
extension NFGroupDetailViewController: NFGroupDetailHeaderViewDelegate {
    func groupDetailHeaderView(_ headerView: NFGroupDetailHeaderView, didUpdate property: NFGroupDetailHeaderProperty) {
        switch property {
        case .title(let value):
            updatedGroup.title = value
        case .date(let value):
            updatedGroup.date = value
        case .alerts(let value):
            updatedGroup.alerts = value
        }
        updateSaveItemIfNeeded()
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
                updatedGroup.items.remove(at: .zero)
                tableView.deleteRows(at: [.init(row: .zero, section: .zero)], with: .automatic)
                return
            }
            if updatedGroup.items.count > index {
                updatedGroup.items[index] = value
            } else {
                updatedGroup.items.insert(value, at: .zero)
            }
        }
        updateSaveItemIfNeeded()
        tableView.reloadSections(.init(integer: .zero), with: .automatic)
    }
}

extension String {
    func getEstimatedHeight(inTargetWidth targetWidth: CGFloat, havingInsets insets: UIEdgeInsets, font: UIFont = .systemFont(ofSize: 18)) -> CGFloat {
        var estimatedHeight: CGFloat = .zero
        estimatedHeight += insets.top + insets.bottom
        var estimatedWidth = targetWidth
        estimatedWidth -= insets.right + insets.left
        let estimatedSize = CGSize(width: estimatedWidth, height: UILabel.layoutFittingExpandedSize.height)
        let textBoundingRect: CGRect = NSString(string: self).boundingRect(with: estimatedSize, options: .usesLineFragmentOrigin, attributes: [.font : font], context: nil)
        estimatedHeight += textBoundingRect.height
        return max(insets.top+insets.bottom, estimatedHeight)
    }
}
