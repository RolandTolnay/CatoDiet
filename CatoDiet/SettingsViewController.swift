//
//  SettingsViewController.swift
//  CatoDiet
//
//  Created by Roland Tolnay on 01/12/2019.
//  Copyright © 2019 Roland Tolnay. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

  @IBOutlet private weak var targetTextField: UITextField!
  private lazy var loadingScreen = LoadingScreen(in: view)

  var onTargetChanged: ((Int) -> Void)?

  override func viewDidLoad() {
    super.viewDidLoad()

    targetTextField.textColor = .appMain
    targetTextField.tintColor = .appMain
    targetTextField.addTarget(self,
                              action: #selector(didEndEditing),
                              for: .editingDidEnd)
    hideKeyboardWhenTappedAround()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    loadingScreen.toggle(isLoading: true)
    FirebaseService.shared.targetFoodIntake { (target) in

      DispatchQueue.main.async {
        self.loadingScreen.toggle(isLoading: false)
        guard let target = target else {
          self.showAlert(withMessage: "Failed connecting to server.") { _ in
            self.dismiss(animated: true, completion: nil)
          }
          return
        }
        self.targetTextField.text = "\(target)"
      }
    }
  }

  @objc private func didEndEditing() {

    guard var target = Int(targetTextField.text ?? "") else { return }
    targetTextField.text = "\(target.clamped(to: 0...999))"
    target = Int(targetTextField.text ?? "")!

    onTargetChanged?(target)
    loadingScreen.toggle(isLoading: true)
    FirebaseService.shared.setTargetFoodIntake(target) { (error) in

      DispatchQueue.main.async {
        self.loadingScreen.toggle(isLoading: false)
        error.map { _ in self.showAlert(withMessage: "Failed updating target food intake.") }
      }
    }
  }
}
