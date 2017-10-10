//
//  User.swift
//  App
//
//  Created by Daniel Santos on 10/2/17.
//

import Vapor
import FluentProvider
import HTTP

final class SectionItem: Model {
  let storage = Storage()
  
  var title: String
  var subTitle: String
  var content: String
  var attachmentURL: String
  var from: Date
  var to: Date
  var sectionID: Identifier?
  
  static let titleKey = "title"
  static let subTitleKey = "sub_title"
  static let contentKey = "content"
  static let attachmentURLKey = "attachment_url"
  static let fromKey = "from"
  static let toKey = "to"
  static let sectionIDKey = "section_id"
  
  init(
    title: String,
    subTitle: String,
    content: String,
    attachmentURL: String,
    from: Date,
    to: Date,
    section: Section
  ) {
    self.title = title
    self.subTitle = subTitle
    self.content = content
    self.attachmentURL = attachmentURL
    self.from = from
    self.to = to
    self.sectionID = section.id
  }
  
  init(row: Row) throws {
    self.title = try row.get(SectionItem.titleKey)
    self.subTitle = try row.get(SectionItem.subTitleKey)
    self.content = try row.get(SectionItem.contentKey)
    self.attachmentURL = try row.get(SectionItem.attachmentURLKey)
    self.from = try row.get(SectionItem.fromKey)
    self.to = try row.get(SectionItem.toKey)
    self.sectionID = try row.get(Section.foreignIdKey)
  }
  
  func makeRow() throws -> Row {
    var row = Row()
    try row.set(SectionItem.titleKey, self.title)
    try row.set(SectionItem.subTitleKey, self.subTitle)
    try row.set(SectionItem.contentKey, self.content)
    try row.set(SectionItem.attachmentURLKey, self.attachmentURL)
    try row.set(SectionItem.fromKey, self.from)
    try row.set(SectionItem.toKey, self.to)
    try row.set(Section.foreignIdKey, self.sectionID)
    
    return row
  }
}

// MARK: Relation

extension SectionItem {
  var owner: Parent<SectionItem, Section> {
    return parent(id: self.sectionID)
  }
}

// MARK: JSON

extension SectionItem: JSONRepresentable {
  convenience init(json: JSON) throws {
    let sectionID: Identifier = try json.get(SectionItem.sectionIDKey)
    
    guard let section = try Section.find(sectionID) else {
      throw Abort.badRequest
    }
    
    try self.init(
      title: json.get(SectionItem.titleKey),
      subTitle: json.get(SectionItem.subTitleKey),
      content: json.get(SectionItem.contentKey),
      attachmentURL: json.get(SectionItem.attachmentURLKey),
      from: json.get(SectionItem.fromKey),
      to: json.get(SectionItem.toKey),
      section: section
    )
  }
  
  func makeJSON() throws -> JSON {
    var json = JSON()
    try json.set(Section.idKey, self.id)
    try json.set(SectionItem.titleKey, self.title)
    try json.set(SectionItem.subTitleKey, self.subTitle)
    try json.set(SectionItem.contentKey, self.content)
    try json.set(SectionItem.attachmentURLKey, self.attachmentURL)
    try json.set(SectionItem.fromKey, self.from)
    try json.set(SectionItem.toKey, self.to)
    try json.set(SectionItem.sectionIDKey, self.sectionID)
    
    return json
  }
}

// MARK: HTTP

extension SectionItem: ResponseRepresentable { }

// MARK: Preparation

extension SectionItem: Preparation {
  static func prepare(_ database: Database) throws {
    try database.create(self) { builder in
      builder.id()
      builder.string(SectionItem.titleKey)
      builder.string(SectionItem.subTitleKey)
      builder.string(SectionItem.contentKey)
      builder.string(SectionItem.attachmentURLKey)
      builder.date(SectionItem.fromKey)
      builder.date(SectionItem.toKey)
      builder.parent(Section.self)
    }
  }
  static func revert(_ database: Database) throws {
    try database.delete(self)
  }
}
