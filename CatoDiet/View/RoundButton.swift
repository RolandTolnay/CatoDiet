//
//  RoundButton.swift
//  Batelco
//
//  Created by Edward Nagy on 20/09/2019.
//  Copyright © 2019 iQuest Technologies. All rights reserved.
//

import UIKit


@IBDesignable
class RoundButton: UIButton {

  var enabledBackgroundColor: UIColor = .appMain
  var disabledBackgroundColor: UIColor = .white
  var enabledBorderColor: UIColor = .appMain
  var disabledBorderColor: UIColor = .appLightGray
  var enabledFontColor: UIColor = .white
  var disabledFontColor: UIColor = .appMediumGray

  override var isEnabled: Bool {
    didSet {
      if isEnabled {
        backgroundColor = enabledBackgroundColor
        borderColor = enabledBorderColor
        setTitleColor(enabledFontColor, for: .normal)
      } else {
        backgroundColor = disabledBackgroundColor
        borderColor = disabledBorderColor
        setTitleColor(disabledFontColor, for: .disabled)
      }
    }
  }

  @IBInspectable
  var cornerRadius: CGFloat {
    get { layer.cornerRadius }
    set { layer.cornerRadius = newValue }
  }

  @IBInspectable
  var borderColor: UIColor? {
    get { layer.borderColor.map { UIColor(cgColor: $0) } }
    set { layer.borderColor = newValue?.cgColor }
  }

  @IBInspectable
  var borderWidth: CGFloat {
    get { layer.borderWidth }
    set { layer.borderWidth = newValue }
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    customInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    customInit()
  }

  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    customInit()
  }

  private func customInit() {
    cornerRadius = 10
    borderWidth = 1
    borderColor = enabledBorderColor
  }
}
