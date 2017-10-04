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
  
  let data: Blob
  let fileExtension: String
  let addedOn: Date
  let userID: Identifier?
  
  init(data: Blob,
       fileExtension: String,
       addedOn: Date,
       user: User
    ) {
    self.data = data
    self.fileExtension = fileExtension
    self.addedOn = addedOn
    self.userID = user.id
  }
  
  required init(row: Row) throws {
    <#code#>
  }
}
