//
//  User.swift
//  App
//
//  Created by Daniel Santos on 10/2/17.
//

import Vapor
import FluentProvider
import HTTP

final class Link: Model {
  let storage = Storage()
  
  var url: String
  let portfolioID: Identifier?
  
  static let urlKey = "url"
  static let portfolioIDKey = "portfolio_id"
  
  init(url: String, portfolio: Portfolio) {
    self.url = url
    self.portfolioID = portfolio.id
  }
  
  init(row: Row) throws {
    self.url = try row.get(Link.urlKey)
    self.portfolioID = try row.get(Portfolio.foreignIdKey)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Link.urlKey, self.url)
    try row.set(Portfolio.foreignIdKey, self.portfolioID)
    
    return row
  }
  
  func update(with json: JSON) throws {
    let link = try Link(json: json)
    
    self.url = link.url
    
    try self.save()
  }
}

// MARK: Relation

extension Link {
  var owner: Parent<Link, Portfolio> {
    return parent(id: self.portfolioID)
  }
}

// MARK: JSON

extension Link: JSONRepresentable {
  convenience init(json: JSON) throws {
    let portfolioID: Identifier = try json.get(Link.portfolioIDKey)
    
    guard let portfolio = try Portfolio.find(portfolioID) else {
      throw Abort.badRequest
    }
    
    try self.init(url: json.get(Link.urlKey), portfolio: portfolio)
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Link.idKey, self.id)
    try json.set(Link.urlKey, self.url)
    try json.set(Link.portfolioIDKey, self.portfolioID)
    
    return json
  }
}

// MARK: HTTP

extension Link: ResponseRepresentable { }

extension Link: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { builder in
      builder.id()
      builder.string(Link.urlKey)
      builder.parent(Portfolio.self)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}
