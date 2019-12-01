//
//  Extensions.swift
//  CatoDiet
//
//  Created by Roland Tolnay on 30/11/2019.
//  Copyright © 2019 Roland Tolnay. All rights reserved.
//

import UIKit

extension UIViewController {

  func showAlert(withMessage message: String, handler: ((UIAlertAction) -> Void)? = nil) {

    let alertController = UIAlertController(title: "We are sorry",
                                            message: message,
                                            preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "Close",
                                            style: .destructive,
                                            handler: handler))
    present(alertController, animated: true)
  }

  func hideKeyboardWhenTappedAround() {

    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                             action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }

  @objc private func dismissKeyboard() {

    view.endEditing(true)
  }
}

private class Border: UIView {}

extension UITextField {

  func addBottomBorder(color: UIColor = .appMain) {

    let bottomBorder = Border()
    bottomBorder.backgroundColor = color
    borderStyle = .none
    addSubview(bottomBorder)
    bottomBorder.translatesAutoresizingMaskIntoConstraints = false
    bottomBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true
    bottomBorder.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
    bottomBorder.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    bottomBorder.topAnchor.constraint(equalTo: bottomAnchor).isActive = true
  }

  func clearBottomBorder() {

    subviews.forEach { view in
      if view is Border {
        view.removeFromSuperview()
      }
    }
  }

  func setBottomBorderColor(_ color: UIColor) {

    subviews.forEach { view in
      if view is Border {
        view.backgroundColor = color
      }
    }
  }
}

extension UIColor {
  /// 113 134 64
  class var appDarkGreen: UIColor { #colorLiteral(red: 0.4431372549, green: 0.5254901961, blue: 0.2509803922, alpha: 1) }

  class var appLightYellow: UIColor { #colorLiteral(red: 0.8235294118, green: 0.8117647059, blue: 0.537254902, alpha: 1) }

  class var appTeal: UIColor { #colorLiteral(red: 0.368627451, green: 0.7254901961, blue: 0.6823529412, alpha: 1) }

  class var appMain: UIColor { .appTeal }

  /// 189 189 189 100%
  open class var appLightGray: UIColor { #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1) }
  /// 120 122 122 100%
  open class var appMediumGray: UIColor { #colorLiteral(red: 0.4705882353, green: 0.4784313725, blue: 0.4784313725, alpha: 1) }

  open class var appDarkGray: UIColor { #colorLiteral(red: 0.3333333333, green: 0.337254902, blue: 0.3529411765, alpha: 1) }

  class var gradientStart: UIColor { #colorLiteral(red: 0.4039215686, green: 0.6980392157, blue: 0.4352941176, alpha: 1) }

  class var gradientEnd: UIColor { #colorLiteral(red: 0.2980392157, green: 0.6352941176, blue: 0.8039215686, alpha: 1) }
}

extension Double {

  /// Returns rounded to specified number of decimals.
  func rounded(decimals: Int = 3) -> Double {
    let poweredBy = pow(Double(10), Double(decimals))
    return Double(Int(self * poweredBy)) / poweredBy
  }

  /// A textual representation of this instance with added trailing precision in decimals.
  func description(decimals: Int = 3) -> String {
    return String(format: "%.\(decimals)f", self)
  }
}
