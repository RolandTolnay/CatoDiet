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
  @IBOutlet weak var amountTextField: UITextField!
  @IBOutlet weak var amountBarControl: GradientBarControl!

  private lazy var loadingScreen = LoadingScreen(in: view)
  private var user: User?
  private var meals = [Meal]()

  override func viewDidLoad() {
    super.viewDidLoad()

    FirebaseService.shared.delegate = self
    setupTableView()
    setupTextFields()
    hideKeyboardWhenTappedAround()
    updateFeedEnabled()
    loadingScreen.changeActivityIndicatorColor(to: .appMain)

    amountBarControl.value = 15
    amountBarControl.onValueChanged = { [weak self] amount in
      self?.amountTextField.text = "\(Int(amount))"
      self?.updateFeedEnabled()
    }
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
      self.reloadMeals()
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

  private func setupTextFields() {

    foodTextField.addTarget(self,
                            action: #selector(updateFeedEnabled),
                            for: .editingChanged)
    foodTextField.addBottomBorder()
    foodTextField.tintColor = .appMain
    foodTextField.textColor = .appMain

    amountTextField.text = "\(Int(amountBarControl.value))"
    amountTextField.tintColor = .appMain
    amountTextField.textColor = .appMain
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

