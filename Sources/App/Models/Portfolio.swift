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
  
  static let userIDKey = "user_id"
  
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
  
  func fullPortfolio() throws -> JSON {
    var data = try self.makeJSON()
    data.removeKey(User.idKey)
    
    // Sections
    let sections = try self.getSections()
    try data.set("sections", sections)
    
    guard let user = try self.owner.get() else {
      throw Abort.badRequest
    }
    
    try data.set("user", user.fullUser())
    try data.set("links", self.links.all())
    
    return data
  }
  
  private func getSections() throws -> [JSON] {
    var sections = Array<JSON>()
    
    for section in try self.sections.all() {
      var sectionItems = Array<JSON>()
      
      for item in try section.sectionItems.all() {
        sectionItems.append(try item.makeJSON())
      }
      
      var sectionJSON = try section.makeJSON()
      try sectionJSON.set("items", sectionItems)
      sections.append(sectionJSON)
    }
     return sections
  }
}

// MARK: Relation

extension Portfolio {
  var owner: Parent<Portfolio, User> {
    return parent(id: self.userID)
  }
  
  var sections: Children<Portfolio, Section> {
    return children()
  }
  
  var links: Children<Portfolio, Link> {
    return children()
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
