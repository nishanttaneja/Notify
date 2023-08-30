//
//  UIView+Extension.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import UIKit

extension UIView {
    func addSubview(_ subview: UIView, withInsets insets: UIEdgeInsets) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: insets.top),
            subview.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: insets.left),
            subview.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor, constant: -insets.right),
            subview.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom)
        ])
    }
}
