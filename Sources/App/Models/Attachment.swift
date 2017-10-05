//
//  Attachment.swift
//  App
//
//  Created by Daniel Santos on 10/2/17.
//

import Vapor
import FluentProvider
import HTTP

final class Attachment: Model {
  let storage = Storage()
  
  let name: String
  let data: Blob
  let fileExtension: String
  let addedOn: Date
  let userID: Identifier?
  
  static let nameKey = "name"
  static let dataKey = "data"
  static let fileExtensionKey = "fileExtension"
  static let addedOnKey = "addedOn"
  static let userIDKey = "userID"
  
  init(name: String,
       data: Blob,
       fileExtension: String,
       addedOn: Date,
       user: User
    ) {
    self.name = name
    self.data = data
    self.fileExtension = fileExtension
    self.addedOn = addedOn
    self.userID = user.id
  }
  
  required init(row: Row) throws {
    self.name = try row.get(Attachment.nameKey)
    self.data = try row.get(Attachment.dataKey)
    self.fileExtension = try row.get(Attachment.fileExtensionKey)
    self.addedOn = try row.get(Attachment.addedOnKey)
    self.userID = try row.get(User.foreignIdKey)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(Attachment.nameKey, self.name)
    try row.set(Attachment.dataKey, self.data)
    try row.set(Attachment.fileExtensionKey, self.fileExtension)
    try row.set(Attachment.addedOnKey, self.addedOn)
    try row.set(User.foreignIdKey, self.userID)
    
    return row
  }
}

// MARK: Relation

extension Attachment {
  var owner: Parent<Attachment, User> {
    return parent(id: self.userID)
  }
}

// MARK: JSON

extension Attachment: JSONConvertible {
  convenience init(json: JSON) throws {
    let userID: Identifier = try json.get(Attachment.userIDKey)
    
    guard let user = try User.find(userID) else {
      throw Abort.badRequest
    }
    
    try self.init(
      name: json.get(Attachment.nameKey),
      data: json.get(Attachment.dataKey),
      fileExtension: json.get(Attachment.fileExtensionKey),
      addedOn: json.get(Attachment.addedOnKey),
      user: user
    )
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Attachment.nameKey, self.name)
    try json.set(Attachment.dataKey, self.data)
    try json.set(Attachment.fileExtensionKey, self.fileExtension)
    try json.set(Attachment.addedOnKey, self.addedOn)
    try json.set(Attachment.userIDKey, self.userID)
    
    return json
  }
}

// MARK: HTTP

extension Attachment: ResponseRepresentable { }

extension Attachment: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { builder in
      builder.id()
      builder.string(Attachment.nameKey)
      builder.bytes(Attachment.dataKey)
      builder.string(Attachment.fileExtensionKey)
      builder.date(Attachment.addedOnKey)
      builder.parent(User.self)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}
