//  Created by Artur on 07/06/2020.
//  Copyright © 2020 Artur. All rights reserved.
//

import UIKit

class NibView: UIView, NibReplaceable {

    override func awakeAfter(using coder: NSCoder) -> Any? {
        guard subviews.isEmpty,
            let nibView = replacedByNibView()
            else { return self }
        return nibView
    }
    
}

protocol NibReplaceable: UIView {}

extension NibReplaceable {
    
    func replacedByNibView() -> Self? {
        let nibView = type(of: self).nibView()
        nibView?.copyProperties(from: self)
        nibView?.copyConstraints(from: self)
        return nibView
    }
    
    private static func nibView() -> Self? {
        guard let nibViews = Bundle(for: self).loadNibNamed(nibName, owner: nil, options: nil),
            let nibView = nibViews.first(where: { type(of: $0) == self } ) as? Self
            else {
                fatalError("\(#function) Could not find an instance of class \(self) in \(nibName) xib")
        }
        return nibView
    }
    
    private static var nibName: String {
        return String(describing: self)
    }

   private func copyConstraints(from view: UIView) {
        translatesAutoresizingMaskIntoConstraints = view.translatesAutoresizingMaskIntoConstraints
        for constraint in view.constraints {
            if var firstItem = constraint.firstItem as? UIView {
                var secondItem = constraint.secondItem as? UIView
                if firstItem == view {
                    firstItem = self
                }
                if secondItem == view {
                    secondItem = self
                }
                let copiedConstraint = NSLayoutConstraint(
                    item: firstItem,
                    attribute: constraint.firstAttribute,
                    relatedBy: constraint.relation,
                    toItem: secondItem,
                    attribute: constraint.secondAttribute,
                    multiplier: constraint.multiplier,
                    constant: constraint.constant
                )
                addConstraint(copiedConstraint)
            } else {
                debugPrint("copyConstraintsFromView: error: firstItem is not a UIView")
            }
            for axis in [NSLayoutConstraint.Axis.horizontal, NSLayoutConstraint.Axis.vertical] {
                setContentCompressionResistancePriority(view.contentCompressionResistancePriority(for: axis), for: axis)
                setContentHuggingPriority(view.contentHuggingPriority(for: axis), for: axis)
            }
        }
    }
    
   private func copyProperties(from view: UIView) {
        copyAnimatableProperties(from: view)
        frame = view.frame
        tag = view.tag
        isUserInteractionEnabled = view.isUserInteractionEnabled
        isHidden = view.isHidden
        autoresizingMask = view.autoresizingMask
        isOpaque = view.isOpaque
    }
    
    private func copyAnimatableProperties(from view: UIView) {
        alpha = view.alpha
        if view.backgroundColor != nil {
            backgroundColor = view.backgroundColor
        }
        transform = view.transform
    }
}
