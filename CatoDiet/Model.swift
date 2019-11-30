//
//  Model.swift
//  CatoDiet
//
//  Created by Roland Tolnay on 30/11/2019.
//  Copyright © 2019 Roland Tolnay. All rights reserved.
//

import Foundation

struct User: Equatable {

  let uid: String
  let name: String
}

struct Meal: Equatable {

  let food: String
  let amount: Int
  let date: Date
  let addedBy: User
}

extension Meal {

  init(dictionary: [String: Any]) {
    food = dictionary["food"] as! String
    amount = dictionary["amount"] as! Int
    date = Date(timeIntervalSince1970: dictionary["date"] as! TimeInterval)
    let userData = dictionary["user"] as! [String: Any]
    addedBy = User(uid: userData["uid"] as! String,
                   name: userData["name"] as! String)
  }

  var dictionary: [String: Any] {
    return [
      "food": food,
      "amount": amount,
      "date": date.timeIntervalSince1970,
      "user": [
        "uid": addedBy.uid,
        "name": addedBy.name
      ]
    ]
  }
}
