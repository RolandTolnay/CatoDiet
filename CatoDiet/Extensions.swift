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
  /// 204 9 47 100%
  open class var appMain: UIColor { #colorLiteral(red: 0.3764705882, green: 0.7490196078, blue: 0.6980392157, alpha: 1) }
  /// 189 189 189 100%
  open class var appLightGray: UIColor { #colorLiteral(red: 0.7411764706, green: 0.7411764706, blue: 0.7411764706, alpha: 1) }
  /// 120 122 122 100%
  open class var appMediumGray: UIColor { #colorLiteral(red: 0.4705882353, green: 0.4784313725, blue: 0.4784313725, alpha: 1) }
  /// 85 86 90 100%
  open class var appDarkGray: UIColor { #colorLiteral(red: 0.3333333333, green: 0.337254902, blue: 0.3529411765, alpha: 1) }
  /// 255 255 255 50%
  open class var appWhiteHalfAlpha: UIColor { #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5) }
  /// 245 58 58 100%
  open class var appErrorRed: UIColor { #colorLiteral(red: 0.9607843137, green: 0.2274509804, blue: 0.2274509804, alpha: 1) }

  open class var appLightBrown: UIColor { #colorLiteral(red: 0.8549019608, green: 0.8352941176, blue: 0.5490196078, alpha: 1) }
}
