//
//  UITextView+Extension.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import UIKit

extension UITextView {
    func addDoneToolbarButton() {
        let toolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.barStyle = .default
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneItem = UIBarButtonItem(title: "Done", primaryAction: UIAction(handler: { _ in
            self.resignFirstResponder()
        }))
        let items = [flexSpace, doneItem]
        toolbar.items = items
        toolbar.sizeToFit()
        inputAccessoryView = toolbar
    }
}
