//
//  NFGroupDetailHeaderView.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import UIKit

protocol NFGroupDetailHeaderViewDelegate: NSObjectProtocol {
    
}

final class NFGroupDetailHeaderView: UITableViewHeaderFooterView {
    // MARK: - Properties
    
    
    // MARK: - Views
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        label.font = .boldSystemFont(ofSize: 28)
        return label
    }()
    private let datePicker = UIDatePicker()
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, datePicker])
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    
    // MARK: - Configurations
    func updateGroup(title: String, date: Date) {
        titleLabel.text = title
        datePicker.date = date
    }
    private func configViews() {
        datePicker.datePickerMode = .time
        contentView.addSubview(contentStackView, withInsets: .init(top: .zero, left: 16, bottom: 8, right: 16))
    }
    
    
    // MARK: - Constructors
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configViews()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
