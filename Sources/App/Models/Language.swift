//
//  Language.swift
//  App
//
//  Created by Daniel Santos on 10/2/17.
//

import Vapor
import FluentProvider
import HTTP

final class Language: Model {
  let storage = Storage()
  
  var name: String
  private var mLevel: Int
  var level: Skill.Level {
    get {
      return Skill.Level(level: self.mLevel)
    } set {
      mLevel = newValue.rawValue
    }
  }

  let userID: Identifier?
  
  static let nameKey = "name"
  static let levelKey = "level"
  static let userIDKey = "userID"
  
  init(
    name: String,
    level: Int,
    user: User
    ) {
    self.name = name
    self.userID = user.id
    self.mLevel = level
    self.level = Skill.Level(level: level)
  }
  
  required init(row: Row) throws {
    self.name = try row.get(Language.nameKey)
    self.mLevel = try row.get(Language.levelKey)
    self.userID = try row.get(User.foreignIdKey)
    self.level = Skill.Level(level: self.mLevel)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Language.nameKey, self.name)
    try row.set(Language.levelKey, self.mLevel)
    try row.set(User.foreignIdKey, self.userID)
    
    return row
  }
}

// MARK: Relationship

extension Language {
  var owner: Parent<Language, User> {
    return parent(id: self.userID)
  }
}

// MARK: JSON

extension Language: JSONConvertible {
  
  convenience init(json: JSON) throws {
    let userID: Identifier = try json.get(Language.userIDKey)
    
    guard let user = try User.find(userID) else {
      throw Abort.badRequest
    }
    
    try self.init(
      name: json.get(Language.nameKey),
      level: json.get(Language.levelKey),
      user: user
    )
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    
    try json.set(Language.nameKey, self.name)
    try json.set(Language.levelKey, self.level.rawValue)
    try json.set(Language.userIDKey, self.userID)
    
    return json
  }
}

// MARK: HTTP

extension Language: ResponseRepresentable { }

extension Language: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { builder in
      builder.id()
      builder.string(Language.nameKey)
      builder.string(Language.levelKey)
      builder.parent(User.self)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}
