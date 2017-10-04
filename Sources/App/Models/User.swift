//
//  User.swift
//  App
//
//  Created by Daniel Santos on 10/2/17.
//

import Vapor
import FluentProvider
import HTTP


class User: Model {
  let storage = Storage()
  
  let firstName: String
  let lastName: String
  let username: String
  let password: String
  let email: String
  let dateOfBirth: Date
  let summary: String
  let location: String
  
  static let firstNameKey = "firstName"
  static let lastNameKey = "lastName"
  static let usernameKey = "username"
  static let passwordKey = "password"
  static let emailKey = "email"
  static let dateOfBirthKey = "dateOfbirth"
  static let summaryKey = "summary"
  static let locationKey = "location"
  
  required init(row: Row) throws {
    self.firstName = try row.get(User.firstNameKey)
    self.lastName = try row.get(User.lastNameKey)
    self.username = try row.get(User.passwordKey)
    self.password = try row.get(User.passwordKey)
    self.email = try row.get(User.emailKey)
    self.dateOfBirth = try row.get(User.dateOfBirthKey)
    self.summary = try row.get(User.summaryKey)
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
    
    return row
  }

}
