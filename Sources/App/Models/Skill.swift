//
//  Skill.swift
//  App
//
//  Created by Daniel Santos on 10/2/17.
//

import Vapor
import FluentProvider
import HTTP


final class Skill: Model {
  
  public enum Level: Int {
    case none         = 0
    case beginner     = 1
    case average      = 2
    case intermidate  = 3
    case advance      = 4
    case expert       = 5
    case invalid      = 0xff
    
    init(level: Int) {
      switch level {
      case 0:
        self = .none
      case 1:
        self = .beginner
      case 2:
        self = .average
      case 3:
        self = .intermidate
      case 4:
        self = .advance
      case 5:
        self = .expert
      default:
        self  = .invalid
      }
    }
  }
  
  let storage = Storage()
  
  var name: String
  
  private var mLevel: Int
  var level: Level {
    get {
      return Level(level: self.mLevel)
    } set {
      self.mLevel = newValue.rawValue
    }
  }
  
  var userID: Identifier?
  
  static let nameKey = "name"
  static let levelKey = "level"
  static let userIDKey = "user_id"
  
  init(name: String, level: Int, user: User) {
    self.name = name
    self.mLevel = level
    self.userID = user.id
    self.level = Level(level: level)
  }
  
  required init(row: Row) throws {
    self.name = try row.get(Skill.nameKey)
    self.mLevel = try row.get(Skill.levelKey)
    self.level = Level(level: self.mLevel)
    self.userID = try row.get(User.foreignIdKey)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Skill.nameKey, self.name)
    try row.set(Skill.levelKey, self.mLevel)
    try row.set(User.foreignIdKey, self.userID)
    
    return row
  }
  
  func update(with json: JSON) throws {
    self.name = try json.get(Skill.nameKey)
    self.level = Level(level: try json.get(Skill.levelKey))
    
    try self.save()
  }
}

// MARK: Relation

extension Skill {
  var owner: Parent<Skill, User> {
    return parent(id: self.userID)
  }
}

// MARK: JSON

extension Skill: JSONConvertible {
  convenience init(json: JSON) throws {
    let userID: Identifier = try json.get(Skill.userIDKey)
    
    guard let user = try User.find(userID) else {
      throw Abort.badRequest
    }
    
    try self.init(
      name: json.get(Skill.nameKey),
      level: json.get(Skill.levelKey),
      user: user
    )
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    
    try json.set(Skill.idKey, self.id)
    try json.set(Skill.nameKey, self.name)
    try json.set(Skill.levelKey, self.level.rawValue)
    try json.set(Skill.userIDKey, self.userID)
    
    return json
  }
}

// MARK: HTTP

extension Skill: ResponseRepresentable { }

// MARK: Preparation

extension Skill: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { builder in
      builder.id()
      builder.string(Skill.nameKey)
      builder.int(Skill.levelKey)
      builder.parent(User.self)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}
