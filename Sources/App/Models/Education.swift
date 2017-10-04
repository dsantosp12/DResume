//
//  Education.swift
//  App
//
//  Created by Daniel Santos on 10/2/17.
//

import Vapor
import FluentProvider
import HTTP

final class Education: Model {
  let storage = Storage()
  
  let institution: String
  let degree: String
  let from: Date
  let to: Date
  let userID: Identifier?
  
  static let institutionKey = "institution"
  static let degreeKey = "degree"
  static let fromKey = "from"
  static let toKey = "to"
  static let userIDKey = "userID"
  
  init(
    institution: String,
    degree: String,
    from: Date,
    to: Date,
    user: User
    ) {
    self.institution = institution
    self.degree = degree
    self.from = from
    self.to = to
    self.userID = user.id
  }
  
  required init(row: Row) throws {
    self.institution = try row.get(Education.institutionKey)
    self.degree = try row.get(Education.degreeKey)
    self.from = try row.get(Education.fromKey)
    self.to = try row.get(Education.toKey)
    self.userID = try row.get(User.foreignIdKey)
  }

  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Education.institutionKey, self.institution)
    try row.set(Education.degreeKey, self.degree)
    try row.set(Education.fromKey, self.from)
    try row.set(Education.toKey, self.to)
    try row.set(User.foreignIdKey, self.userID)
    
    return row
  }
  
}

// MARK: Relationship

extension Education {
  var owner: Parent<Education, User> {
    return parent(id: self.userID)
  }
}

// MARK: JSON

extension Education: JSONConvertible {
  convenience init(json: JSON) throws {
    let userID: Identifier = try json.get(Education.userIDKey)
    
    guard let user = try User.find(userID) else {
      throw Abort.badRequest
    }
    
    try self.init(
      institution: json.get(Education.institutionKey),
      degree: json.get(Education.degreeKey),
      from: json.get(Education.fromKey),
      to: json.get(Education.toKey),
      user: user
    )
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Education.institutionKey, self.institution)
    try json.set(Education.degreeKey, self.degree)
    try json.set(Education.fromKey, self.from)
    try json.set(Education.toKey, self.to)
    try json.set(Education.userIDKey, self.userID)
    
    return json
  }
}

// MARK: HTTP

extension Education: ResponseRepresentable { }

// MARK: Preparation

extension Education: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { builder in
      builder.id()
      builder.string(Education.institutionKey)
      builder.string(Education.degreeKey)
      builder.date(Education.fromKey)
      builder.date(Education.toKey)
      builder.parent(User.self)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}
