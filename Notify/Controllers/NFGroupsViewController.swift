//
//  NFGroupsViewController.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import UIKit
import WhatsNew
import UserNotifications
import Intents

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
        displayWhatsNew()
        
        INPreferences.requestSiriAuthorization { status in
            switch status {
            case .authorized:
                debugPrint("Siri Usage Request Authorised!")
            default:
                debugPrint("Siri Usage Request Rejected.")
            }
        }
        
        let intent = RandomQuoteIntent()
        intent.suggestedInvocationPhrase = "Get random quote."
        intent.group = "group"
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            guard let error else { return }
            debugPrint(error)
        }
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
        let groupToDelete = groups.remove(at: indexPath.row)
        NFCoreDataService.shared.deleteGroup(groupToDelete) { result in
            switch result {
            case .success: break
            case .failure(let failure):
                debugPrint(#function, failure)
            }
        }
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
    // MARK: Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard groups.count > indexPath.row else { return }
        let detailsVC = NFGroupDetailViewController(groupId: groups[indexPath.row].id)
        navigationController?.pushViewController(detailsVC, animated: true)
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .delete
    }
}


// MARK: - WhatsNew
extension NFGroupsViewController {
    private func displayWhatsNew() {
        let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let controller = WNViewController(items: [
            WNItem(image: .init(systemName: "rectangle.portrait.topthird.inset.filled")!, title: "Display Random Item", description: "Preview random items."),
            WNItem(image: .init(systemName: "newspaper")!, title: "What's New", description: "Discover new features. When new features are added, they will be displayed here.")
        ], appVersion: appVersion)
        guard controller.shouldDisplayWhatsNew() else { return }
        NFCoreDataService.shared.saveAtomicHabits { result in
            switch result {
            case .success(let group):
                DispatchQueue.main.async {
                    self.groups.insert(group, at: .zero)
                    self.tableView.reloadSections(.init(integer: .zero), with: .automatic)
                }
            case .failure(let failure):
                debugPrint(#function, failure)
            }
        }
        present(controller, animated: true)
    }
}
