//
//  NFTextTableViewCell.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import UIKit

enum NFTextTableViewCellProperty {
    case title(value: String)
}

protocol NFTextTableViewCellDelegate: NSObjectProtocol {
    func textTableViewCell(_ cell: NFTextTableViewCell, didUpdate property: NFTextTableViewCellProperty)
}

final class NFTextTableViewCell: UITableViewCell {
    // MARK: - Properties
    weak var delegate: NFTextTableViewCellDelegate?
    
    
    // MARK: - Views
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.font = .systemFont(ofSize: 17)
        return textView
    }()
    
    
    // MARK: - Configurations
    func updateText(_ text: String) {
        textView.text = text
    }
    private func configViews() {
        textView.delegate = self
        contentView.addSubview(textView, withInsets: .init(top: 4, left: 16, bottom: 4, right: 16))
    }
    
    
    // MARK: - Constructors
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configViews()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension NFTextTableViewCell: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.isScrollEnabled = true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.isScrollEnabled = false
        guard let text = textView.text,
              text.replacingOccurrences(of: " ", with: "").isEmpty == false else { return }
        delegate?.textTableViewCell(self, didUpdate: .title(value: text))
    }
}
