//
//  User.swift
//  App
//
//  Created by Daniel Santos on 10/2/17.
//

import Vapor
import FluentProvider
import HTTP
import BCrypt


final class User: Model {
  let storage = Storage()
  
  var firstName: String
  var lastName: String
  var username: String
  var password: String
  var email: String
  var dateOfBirth: Date
  var summary: String
  var location: String
  
  static let firstNameKey = "firstName"
  static let lastNameKey = "lastName"
  static let usernameKey = "username"
  static let passwordKey = "password"
  static let emailKey = "email"
  static let dateOfBirthKey = "dateOfBirth"
  static let summaryKey = "summary"
  static let locationKey = "location"
  
  required init(firstName: String,
       lastName: String,
       username: String,
       password: String,
       email: String,
       dateOfBirth: Date,
       summary: String,
       location: String
    ) throws {
    self.firstName = firstName
    self.lastName = lastName
    self.username = username
    
    let hash = try BCrypt.Hash.make(message: password)
    guard let hashedPassword = String(bytes: hash, encoding: .utf8) else {
      throw Abort.badRequest
    }
    self.password = hashedPassword
    
    self.email = email
    self.dateOfBirth = dateOfBirth
    self.summary = summary
    self.location = location
  }
  
  required init(row: Row) throws {
    self.firstName = try row.get(User.firstNameKey)
    self.lastName = try row.get(User.lastNameKey)
    self.username = try row.get(User.usernameKey)
    self.password = try row.get(User.passwordKey)
    self.email = try row.get(User.emailKey)
    self.dateOfBirth = try row.get(User.dateOfBirthKey)
    self.summary = try row.get(User.summaryKey)
    self.location = try row.get(User.locationKey)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(User.firstNameKey, self.firstName)
    try row.set(User.lastNameKey, self.lastName)
    try row.set(User.usernameKey, self.username)
    try row.set(User.passwordKey, self.password)
    try row.set(User.emailKey, self.email)
    try row.set(User.dateOfBirthKey, self.dateOfBirth)
    try row.set(User.summaryKey, self.summary)
    try row.set(User.locationKey, self.location)
    
    return row
  }
  
  func fullUser() throws -> JSON {
    var userData = try self.makeJSON()
    
    try userData.set("skills", self.skills.all())
    try userData.set("attachments", self.attachments.all())
    try userData.set("educations", self.educations.all())
    try userData.set("languages", self.languages.all())
    
    return userData
  }
}

// MARK: Relation

extension User {
  var skills: Children<User, Skill> {
    return children()
  }
  
  var languages: Children<User, Language> {
    return children()
  }
  
  var educations: Children<User, Education> {
    return children()
  }
  
  var attachments: Children<User, Attachment> {
    return children()
  }
  
  var portfolio: Children<User, Portfolio> {
    return children()
  }
}

// MARK: JSON

extension User: JSONConvertible {
  
  convenience init(json: JSON) throws {
    try self.init(
      firstName: json.get(User.firstNameKey),
      lastName: json.get(User.lastNameKey),
      username: json.get(User.usernameKey),
      password: json.get(User.passwordKey),
      email: json.get(User.emailKey),
      dateOfBirth: json.get(User.dateOfBirthKey),
      summary: json.get(User.summaryKey),
      location: json.get(User.locationKey))
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(User.idKey, self.id)
    try json.set(User.firstNameKey, self.firstName)
    try json.set(User.lastNameKey, self.lastName)
    try json.set(User.usernameKey, self.username)
    try json.set(User.emailKey, self.email)
    try json.set(User.dateOfBirthKey, self.dateOfBirth)
    try json.set(User.summaryKey, self.summary)
    try json.set(User.locationKey, self.location)
    
    return json
  }
}

// MARK: HTTP

extension User: ResponseRepresentable { }

// MARK: Fluent Preparation

extension User: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { builder in
      builder.id()
      builder.string(User.firstNameKey)
      builder.string(User.lastNameKey)
      builder.string(User.usernameKey, unique: true)
      builder.string(User.passwordKey)
      builder.string(User.emailKey, unique: true)
      builder.date(User.dateOfBirthKey)
      builder.string(User.summaryKey)
      builder.string(User.locationKey)
    }
  }
  
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}
