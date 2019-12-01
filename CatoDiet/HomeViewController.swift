//
//  HomeViewController.swift
//  CatoDiet
//
//  Created by Roland Tolnay on 30/11/2019.
//  Copyright © 2019 Roland Tolnay. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

  @IBOutlet private weak var foodTextField: UITextField!
  @IBOutlet private weak var feedButton: RoundButton!
  @IBOutlet private weak var tableView: UITableView!
  @IBOutlet private weak var amountTextField: UITextField!
  @IBOutlet private weak var amountBarControl: GradientBarControl!
  @IBOutlet private weak var remainderLabel: UILabel!

  private lazy var loadingScreen = LoadingScreen(in: view)
  private var user: User?
  private var meals = [Meal]() {
    didSet {
      DispatchQueue.main.async {
        self.remainderLabel.text = "Remaining for today: \(max((self.target ?? 0) - self.consumed, 0)) g"
      }
    }
  }
  private var target: Int? {
    didSet {
      DispatchQueue.main.async {
        self.remainderLabel.text = self.target.map { "Remaining for today: \(max($0 - self.consumed, 0)) g" } ?? ""
        UIView.animate(withDuration: 0.3) {
          self.remainderLabel.alpha = self.target == nil ? 0 : 1
        }
        self.amountBarControl.maxValue = Double(self.target ?? 0)
        self.amountBarControl.setNeedsDisplay()
      }
    }
  }
  private var consumed: Int {
    meals.reduce(into: 0) {
      if Calendar.current.isDateInToday($1.date) {
        $0 += $1.amount
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    FirebaseService.shared.delegate = self
    setupTableView()
    setupInputs()
    hideKeyboardWhenTappedAround()
    updateFeedEnabled()
    remainderLabel.alpha = 0

    remainderLabel.isUserInteractionEnabled = true
    let tapGR = UITapGestureRecognizer(target: self, action: #selector(onRemainderTapped))
    remainderLabel.addGestureRecognizer(tapGR)
  }

  @objc private func onRemainderTapped() {

    let stripped = remainderLabel.text?.replacingOccurrences(of: "Remaining for today: ", with: "")
    let double = stripped?.replacingOccurrences(of: " g", with: "")
    amountBarControl.value = Double(double ?? "") ?? 0
    amountTextField.text = "\(Int(amountBarControl.value))"
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    loadingScreen.toggle(isLoading: true)
    FirebaseService.shared.authenticate { user in

      guard user != nil else {
        DispatchQueue.main.async {
          self.loadingScreen.toggle(isLoading: false)
          self.showAlert(withMessage: "Unable to fetch your user.")
        }
        return
      }
      self.user = user
      FirebaseService.shared.targetFoodIntake {
        self.target = $0
        self.reloadMeals()
      }
    }
  }

  private func setupTableView() {

    tableView.dataSource = self
    tableView.delegate = self
    tableView.tableFooterView = UIView()
    tableView.separatorColor = .appMain

    let refreshControl = UIRefreshControl()
    refreshControl.tintColor = .appMain
    tableView.refreshControl = refreshControl
    tableView.refreshControl?.addTarget(self,
                                        action: #selector(reloadMeals),
                                        for: .valueChanged)
  }

  private func setupInputs() {

    amountBarControl.value = 15
    amountBarControl.onValueChanged = { [weak self] amount in
      self?.amountTextField.text = "\(Int(amount))"
      self?.updateFeedEnabled()
    }

    foodTextField.addTarget(self,
                            action: #selector(updateFeedEnabled),
                            for: .editingChanged)
    foodTextField.addBottomBorder()
    foodTextField.tintColor = .appMain
    foodTextField.textColor = .appMain

    amountTextField.text = "\(Int(amountBarControl.value))"
    amountTextField.tintColor = .appMain
    amountTextField.textColor = .appMain
    amountTextField.addTarget(self,
                              action: #selector(onAmountEditingEnded),
                              for: .editingDidEnd)
  }

  @IBAction func onFeedTapped(_ sender: Any) {

    let meal = Meal(food: foodTextField.text ?? "",
                    amount: Int(amountBarControl.value),
                    date: Date(),
                    addedBy: user!)
    loadingScreen.toggle(isLoading: true)
    FirebaseService.shared.addMeal(meal) { errorDescription in

      DispatchQueue.main.async {
        self.loadingScreen.toggle(isLoading: false)
        errorDescription.map { self.showAlert(withMessage: $0) }
        if errorDescription == nil {
          self.meals.insert(meal, at: 0)
          self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
          self.foodTextField.text = ""
          self.updateFeedEnabled()
        }
      }
    }
  }

  @IBAction func onSettingsTapped(_ sender: Any) {

    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let settingsVC = storyboard.instantiateViewController(withIdentifier: "\(SettingsViewController.self)") as? SettingsViewController {

      settingsVC.onTargetChanged = { [weak self] target in
        self?.target = target
      }
      present(settingsVC, animated: true, completion: nil)
    }
  }

  @objc private func updateFeedEnabled() {
    feedButton.isEnabled = user != nil
      && !(foodTextField.text ?? "").isEmpty
      && amountBarControl.value > 0
  }

  @objc private func reloadMeals() {

    FirebaseService.shared.meals { meals in

      self.meals = meals.sorted { $0.date > $1.date }
      DispatchQueue.main.async {
        self.loadingScreen.toggle(isLoading: false)
        self.tableView.refreshControl?.endRefreshing()
        self.tableView.reloadData()
      }
    }
  }

  @objc private func onAmountEditingEnded() {

    if let amount = Int(amountTextField.text ?? "") {
      amountTextField.text = "\(amount.clamped(to: 0...(target ?? 0)))"
      amountBarControl.value = Double(Int(amountTextField.text ?? "")!)
    }
  }
}

extension HomeViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

    return meals.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    guard let cell = tableView.dequeueReusableCell(withIdentifier: "MealCell", for: indexPath) as? MealCell else { return UITableViewCell() }

    cell.setup(meal: meals[indexPath.row])
    return cell
  }
}

extension HomeViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    tableView.deselectRow(at: indexPath, animated: true)
    foodTextField.text = meals[indexPath.row].food
    amountBarControl.value = Double(meals[indexPath.row].amount)
    amountTextField.text = "\(Int(amountBarControl.value))"
    updateFeedEnabled()
  }

  func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    return meals[indexPath.row].addedBy == user
  }

  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

    if (editingStyle == .delete) {

      loadingScreen.toggle(isLoading: true)
      let meal = meals[indexPath.row]
      FirebaseService.shared.deleteMeal(meal) { errorDescription in

        DispatchQueue.main.async {
          self.loadingScreen.toggle(isLoading: false)
          errorDescription.map { self.showAlert(withMessage: $0) }
          if errorDescription == nil,
            let index = self.meals.firstIndex(of: meal) {

            self.meals.remove(at: index)
            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)],
                                      with: .automatic)
          }
        }
      }
    }
  }
}

extension HomeViewController: AuthenticationDelegate {

  func provideUsername(completion: @escaping (String) -> Void) {

    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let registrationVC = storyboard.instantiateViewController(withIdentifier: "\(RegisterViewController.self)") as? RegisterViewController {

      registrationVC.onUsernameProvided = { [weak self] username in

        self?.dismiss(animated: true, completion: nil)
        completion(username)
      }
      present(registrationVC, animated: true, completion: nil)
    }
  }
}

