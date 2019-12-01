//
//  RegisterViewController.swift
//  CatoDiet
//
//  Created by Roland Tolnay on 30/11/2019.
//  Copyright © 2019 Roland Tolnay. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

  var onUsernameProvided: ((String) -> Void)?

  @IBOutlet private weak var usernameTextField: UITextField!
  @IBOutlet private weak var nextButton: RoundButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    usernameTextField.addBottomBorder()
    usernameTextField.addTarget(self,
                                action: #selector(onUsernameChanged),
                                for: .editingChanged)
    usernameTextField.tintColor = .appMain
    usernameTextField.textColor = .appMain
    nextButton.isEnabled = false
    hideKeyboardWhenTappedAround()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    usernameTextField.becomeFirstResponder()
  }

  @IBAction private func onNextTapped(_ sender: Any) {

    onUsernameProvided?(usernameTextField.text ?? "")
  }

  @objc private func onUsernameChanged() {

    nextButton.isEnabled = !(usernameTextField.text ?? "").isEmpty
  }
}
