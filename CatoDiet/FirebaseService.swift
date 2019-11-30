//
//  FirebaseService.swift
//  CatoDiet
//
//  Created by Roland Tolnay on 30/11/2019.
//  Copyright © 2019 Roland Tolnay. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class FirebaseService {

  weak var delegate: AuthenticationDelegate?

  static let shared = FirebaseService()
  private init() {}

  private lazy var db = Firestore.firestore()
  private lazy var users = db.collection("users")
  private lazy var meals = db.collection("meals")

  func authenticate(completion: @escaping (User?) -> Void) {

    Auth.auth().signInAnonymously { (result, error) in

      error.map { print("Failed auth: \($0.localizedDescription)") }
      guard let result = result else { return completion(nil) }
      self.users.getDocuments { (snapshot, error) in

        error.map { print("Failed getting users: \($0.localizedDescription)") }
        guard let snapshot = snapshot else { return completion(nil) }

        if !snapshot.documents.map({ $0.documentID }).contains(result.user.uid) {

          self.delegate?.provideUsername { username in

            self.users.document(result.user.uid).setData([
              "name": username
            ]) { error in

              error.map { print("Failed saving user: \($0.localizedDescription)") }
              completion(User(uid: result.user.uid, name: username))
            }
          }
        } else {

          let user = snapshot.documents
            .first { $0.documentID == result.user.uid }
            .map { User(uid: result.user.uid, name: $0.data()["name"] as! String) }
          completion(user)
        }
      }
    }
  }

  func meals(completion: @escaping ([Meal]) -> Void) {

    meals.getDocuments { (snapshot, error) in

      error.map { print("Failed getting meals: \($0.localizedDescription)") }
      completion(snapshot?.documents.map { Meal(dictionary: $0.data()) } ?? [])
    }
  }

  func addMeal(_ meal: Meal, completion: @escaping (String?) -> Void) {

    meals.addDocument(data: meal.dictionary) { error in

      error.map { print("Failed adding meal: \($0.localizedDescription)") }
      completion(error?.localizedDescription)
    }
  }

  func deleteMeal(_ meal: Meal, completion: @escaping (String?) -> Void) {

    meals.getDocuments(source: .cache) { (snapshot, error) in

      guard let document = snapshot?.documents.first(where: { Meal(dictionary: $0.data()) == meal })
      else { return completion("Failed deleting meal.") }

      self.meals.document(document.documentID).delete { error in

        error.map { print("Failed deleting meal: \($0.localizedDescription)") }
        completion(error?.localizedDescription)
      }
    }
  }
}

protocol AuthenticationDelegate: class {

  func provideUsername(completion: @escaping (String) -> Void)
}
