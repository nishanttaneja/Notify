//
//  String+Extension.swift
//  Notify
//
//  Created by Nishant Taneja on 30/08/23.
//

import UIKit

extension String {
    func getEstimatedHeight(inTargetWidth targetWidth: CGFloat, havingInsets insets: UIEdgeInsets, font: UIFont = .systemFont(ofSize: 17)) -> CGFloat {
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
