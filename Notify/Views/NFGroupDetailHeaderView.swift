//
//  NFGroupDetailHeaderView.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import UIKit

enum NFGroupDetailHeaderProperty {
    case title(value: String)
    case date(value: Date)
    case alerts(value: Bool)
}

protocol NFGroupDetailHeaderViewDelegate: NSObjectProtocol {
    func groupDetailHeaderView(_ headerView: NFGroupDetailHeaderView, didUpdate property: NFGroupDetailHeaderProperty)
}

final class NFGroupDetailHeaderView: UITableViewHeaderFooterView {
    // MARK: - Properties
    weak var delegate: NFGroupDetailHeaderViewDelegate?
    
    
    // MARK: - Views
    let titleTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = .boldSystemFont(ofSize: 28)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.addDoneToolbarButton()
        return textView
    }()
    private let datePicker = UIDatePicker()
    private let notificationLabel: UILabel = {
        let label = UILabel()
        label.text = "Alerts"
        return label
    }()
    private let notificationSwitch = UISwitch()
    private lazy var notificationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [notificationLabel, notificationSwitch])
        stackView.spacing = 8
        return stackView
    }()
    private lazy var contentStackView: UIStackView = {
        let dateStackView = UIStackView(arrangedSubviews: [datePicker, .init(), .init(), notificationStackView])
        dateStackView.distribution = .equalCentering
        let stackView = UIStackView(arrangedSubviews: [titleTextView, dateStackView])
        titleTextView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        stackView.axis = .vertical
        return stackView
    }()
    
    
    // MARK: - Configurations
    func updateGroup(title: String?, date: Date?, alerts: Bool) {
        titleTextView.text = title
        datePicker.date = date ?? .now
        notificationSwitch.setOn(alerts, animated: true)
    }
    private func configViews() {
        titleTextView.isScrollEnabled = false
        titleTextView.delegate = self
        datePicker.datePickerMode = .time
        datePicker.addAction(UIAction(handler: { _ in
            self.delegate?.groupDetailHeaderView(self, didUpdate: .date(value: self.datePicker.date))
        }), for: .valueChanged)
        notificationSwitch.addAction(UIAction(handler: { _ in
            self.delegate?.groupDetailHeaderView(self, didUpdate: .alerts(value: self.notificationSwitch.isOn))
        }), for: .valueChanged)
        contentView.addSubview(contentStackView, withInsets: .init(top: .zero, left: .zero, bottom: 16, right: .zero))
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

extension NFGroupDetailHeaderView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.isScrollEnabled = true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.isScrollEnabled = false
        guard let title = textView.text,
              title.replacingOccurrences(of: " ", with: "").isEmpty == false else { return }
        delegate?.groupDetailHeaderView(self, didUpdate: .title(value: title))
    }
}
