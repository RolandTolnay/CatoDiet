//
//  DesignableView.swift
//  Batelco
//
//  Created by Edward Nagy on 20/09/2019.
//  Copyright © 2019 iQuest Technologies. All rights reserved.
//

import UIKit

@IBDesignable
class DesignableView: UIView {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    customInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    customInit()
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    customInit()
  }
  
  private func customInit() {
    
    let nib = UINib(nibName: String(describing: type(of: self)),
                    bundle: Bundle(for: type(of: self)))
    
    guard let view = nib.instantiate(withOwner: self, options: nil).first as? UIView
      else { fatalError("Could not load nib for \(String(describing: type(of: self)))") }
    
    view.frame = bounds
    view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    addSubview(view)
  }
}
