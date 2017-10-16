//
//  User.swift
//  App
//
//  Created by Daniel Santos on 10/2/17.
//

import Vapor
import FluentProvider
import HTTP

final class Section: Model {
  let storage = Storage()
  
  var title: String
  var portfolioID: Identifier?
  
  static let titleKey = "title"
  static let portfolioIDKey = "portfolio_id"
  
  init(title: String, portfolio: Portfolio) {
    self.title = title
    self.portfolioID = portfolio.id
  }
  
  required init(row: Row) throws {
    self.title = try row.get(Section.titleKey)
    self.portfolioID = try row.get(Portfolio.foreignIdKey)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Section.titleKey, self.title)
    try row.set(Portfolio.foreignIdKey, self.portfolioID)
    
    return row
  }
  
  func update(with json: JSON) throws {
    let section = try Section(json: json)
    
    self.title = section.title
    
    try self.save()
  }
}

// MARK: Relation

extension Section {
  var owner: Parent<Section, Portfolio> {
    return parent(id: self.portfolioID)
  }
  
  var sectionItems: Children<Section, SectionItem> {
    return children()
  }
}

// MARK: JSON

extension Section: JSONRepresentable {

  convenience init(json: JSON) throws {
    let portfolioID: Identifier = try json.get(Section.portfolioIDKey)
    
    guard let portfolio = try Portfolio.find(portfolioID) else {
      throw Abort.badRequest
    }
    
    try self.init(
      title: json.get(Section.titleKey),
      portfolio: portfolio
    )
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Section.idKey, self.id)
    try json.set(Section.titleKey, self.title)
    try json.set(Section.portfolioIDKey, self.portfolioID)
    
    return json
  }
}

// MARK: HTTP

extension Section: ResponseRepresentable { }

// MARK: Preparation

extension Section: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { builder in
      builder.id()
      builder.string(Section.titleKey)
      builder.parent(Portfolio.self)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}
