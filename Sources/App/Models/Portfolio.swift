//
//  User.swift
//  App
//
//  Created by Daniel Santos on 10/2/17.
//

import Vapor
import FluentProvider
import HTTP

final class Portfolio: Model {
  let storage = Storage()
  
  let userID: Identifier?
  
  static let userIDKey = "userID"
  
  init(user: User) {
    self.userID = user.id
  }
  
  init(row: Row) throws {
    self.userID = try row.get(User.foreignIdKey)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    
    try row.set(User.foreignIdKey, self.userID)
    return row
  }
}

// MARK: Relation

extension Portfolio {
  var owner: Parent<Portfolio, User> {
    return parent(id: self.userID)
  }
}

// MARK: JSON

extension Portfolio: JSONRepresentable {
  convenience init(json: JSON) throws {
    let userID: Identifier = try json.get(Portfolio.userIDKey)
    
    guard let user = try User.find(userID) else {
        throw Abort.badRequest
    }
    
    self.init(user: user)
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Portfolio.idKey, self.id)
    try json.set(Portfolio.userIDKey, self.userID)
    
    return json
  }
}

// MARK: HTTP

extension Portfolio: ResponseRepresentable {}

// MARK: Preparation

extension Portfolio: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { builder in
      builder.id()
      builder.parent(User.self)
    }
  }
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}
