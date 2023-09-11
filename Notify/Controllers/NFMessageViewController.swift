//
//  NFMessageViewController.swift
//  Notify
//
//  Created by Nishant Taneja on 11/09/23.
//

import UIKit

final class NFMessageViewController: UIViewController {
    // MARK: - Properties
    private let contentInsets = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    
    // MARK: - Views
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 17)
        label.numberOfLines = 2
        return label
    }()
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = .zero
        return label
    }()
    private let closeButton: UIButton = {
        let button = UIButton()
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [textStackView, closeButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    private lazy var contentContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.addSubview(contentStackView, withInsets: contentInsets)
        view.layer.cornerRadius = contentInsets.top
        return view
    }()
    
    private func configCloseButton() {
        closeButton.addAction(UIAction(handler: { _ in
            self.dismiss(animated: true)
        }), for: .touchUpInside)
    }
    private func set(title: String, message: String) {
        titleLabel.text = title
        messageLabel.text = message
    }
    
    
    // MARK: - Configurations
    private func configViews() {
        modalTransitionStyle = .crossDissolve
        isModalInPresentation = true
        configCloseButton()
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentContainerView)
        NSLayoutConstraint.activate([
            contentContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentContainerView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: contentInsets.left),
            contentContainerView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -contentInsets.right),
        ])
    }
    
    
    // MARK: - Constructors
    required init(title: String, message: String) {
        super.init(nibName: nil, bundle: nil)
        set(title: title, message: message)
        configViews()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
