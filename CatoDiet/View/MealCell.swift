//
//  MealCell.swift
//  CatoDiet
//
//  Created by Roland Tolnay on 30/11/2019.
//  Copyright © 2019 Roland Tolnay. All rights reserved.
//

import UIKit

class MealCell: UITableViewCell {

  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var foodLabel: UILabel!
  @IBOutlet private weak var userLabel: UILabel!

  func setup(meal: Meal) {

    dateLabel.text = meal.date.toString()
    foodLabel.text = "\(meal.food) \(meal.amount) g"
    userLabel.text = "by \(meal.addedBy.name)"
  }
}

extension Date {

  func toString() -> String {

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm - dd.MM"
    return dateFormatter.string(from: self)
  }
}
