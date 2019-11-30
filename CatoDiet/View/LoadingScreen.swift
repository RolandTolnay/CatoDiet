//
//  LoadingScreen.swift
//  Batelco
//
//  Created by Edward Nagy on 25/09/2019.
//  Copyright © 2019 iQuest Technologies. All rights reserved.
//

import UIKit


class LoadingScreen: DesignableView {

  init(in view: UIView) {
    super.init(frame: view.bounds)
    
    view.addSubview(self)
    toggle(isLoading: false)
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
  
  override func didMoveToSuperview() {
    super.didMoveToSuperview()

    guard let superview = superview else { return }

    topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
    bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
    leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
    rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
    
    backgroundColor = .black
    alpha = 0.3
    translatesAutoresizingMaskIntoConstraints = false
  }

  func toggle(isLoading: Bool) {

    isHidden = !isLoading
    if isLoading {
      activityIndicator.startAnimating()
    } else {
      activityIndicator.stopAnimating()
    }
  }
  
  func changeActivityIndicatorColor(to color: UIColor) {
    
    activityIndicator.color = color
  }
}
