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
}

protocol NFGroupDetailHeaderViewDelegate: NSObjectProtocol {
    func groupDetailHeaderView(_ headerView: NFGroupDetailHeaderView, didUpdate property: NFGroupDetailHeaderProperty)
    func heightForTitle(_ text: String, inGroupDetailHeader headerView: NFGroupDetailHeaderView) -> CGFloat
}

final class NFGroupDetailHeaderView: UITableViewHeaderFooterView {
    // MARK: - Properties
    weak var delegate: NFGroupDetailHeaderViewDelegate?
    let defaultTitleHeight: CGFloat = 44
    private var titleHeightAnchorConstraint: NSLayoutConstraint!
    
    
    // MARK: - Views
    private let titleTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = .boldSystemFont(ofSize: 28)
        textView.translatesAutoresizingMaskIntoConstraints = false
        return textView
    }()
    private let datePicker = UIDatePicker()
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleTextView, datePicker])
        titleTextView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
        stackView.axis = .vertical
        stackView.alignment = .leading
        return stackView
    }()
    
    
    // MARK: - Configurations
    func updateGroup(title: String, date: Date) {
        titleTextView.text = title
        datePicker.date = date
        if let preferredTitleHeight = delegate?.heightForTitle(title, inGroupDetailHeader: self) {
            titleHeightAnchorConstraint.constant = preferredTitleHeight
        }
    }
    private func configViews() {
        titleHeightAnchorConstraint = titleTextView.heightAnchor.constraint(equalToConstant: defaultTitleHeight)
        titleHeightAnchorConstraint.isActive = true
        titleTextView.delegate = self
        datePicker.datePickerMode = .time
        datePicker.addAction(UIAction(handler: { _ in
            self.delegate?.groupDetailHeaderView(self, didUpdate: .date(value: self.datePicker.date))
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
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let title = textView.text,
              title.replacingOccurrences(of: " ", with: "").isEmpty == false else { return }
        delegate?.groupDetailHeaderView(self, didUpdate: .title(value: title))
    }
}
