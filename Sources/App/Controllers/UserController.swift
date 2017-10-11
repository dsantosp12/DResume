import Vapor
import FluentProvider

class UserController {
  
  func addRoutes(to drop: Droplet) {
    let userGroup = drop.grouped("api", "v1", "user")
    
    // Post
    userGroup.post(handler: createUser)
    userGroup.post(User.parameter, "skills", handler: addSkill)
    userGroup.post(User.parameter, "languages", handler: addLanguage)
    userGroup.post(User.parameter, "educations", handler: addEducation)
    userGroup.post(User.parameter, "attachments", handler: addAttachment)
    
    // Get
    userGroup.get(User.parameter, handler: getUser)
    userGroup.get(User.parameter, "skills", handler: getUserSkills)
    userGroup.get(User.parameter, "languages", handler: getLanguages)
    userGroup.get(User.parameter, "educations", handler: getEducation)
    userGroup.get(User.parameter, "attachments", handler: getAttachment)
    
    // Delete
    userGroup.delete("skill", Skill.parameter, handler: removeSkill)
    userGroup.delete("language", Language.parameter, handler: removeLanguage)
    
    // Put
    userGroup.put("skill", Skill.parameter, handler: updateSkill)
    userGroup.put("language", Language.parameter, handler: updateLanguage)
  }
  
  // MARK: POSTERS
  
  func createUser(_ req: Request) throws -> ResponseRepresentable {
    guard let json = req.json else {
      throw Abort.badRequest
    }
    
    let user = try User(json: json)
    try user.save()
    
    return user
  }
  
  func addSkill(_ req: Request) throws -> ResponseRepresentable {
    guard let json = req.json else {
      throw Abort.badRequest
    }
    
    let skill = try Skill(json: json)
    try skill.save()
    
    return skill
  }
  
  func addLanguage(_ req: Request) throws -> ResponseRepresentable {
    guard let json = req.json else {
      throw Abort.badRequest
    }
    
    let language = try Language(json: json)
    try language.save()
    
    return language
  }
  
  func addEducation(_ req: Request) throws -> ResponseRepresentable {
    guard let json = req.json else {
      throw Abort.badRequest
    }
    
    let education = try Education(json: json)
    try education.save()
    
    return education
  }
  
  func addAttachment(_ req: Request) throws -> ResponseRepresentable {
    guard let json = req.json else {
      throw Abort.badRequest
    }
    
    let attachment = try Attachment(json: json)
    try attachment.save()
    
    return attachment
  }
  
  // MARK: GETTERS
  
  func getUser(_ req: Request) throws -> ResponseRepresentable {
    let user = try req.parameters.next(User.self)
    return user
  }
  
  func getUserSkills(_ req: Request) throws -> ResponseRepresentable {
    let user = try req.parameters.next(User.self)
    
    return try user.skills.all().makeJSON()
  }
  
  func getLanguages(_ req: Request) throws -> ResponseRepresentable {
    let user = try req.parameters.next(User.self)
    
    return try user.languages.all().makeJSON()
  }
  
  func getEducation(_ req: Request) throws -> ResponseRepresentable {
    let user = try req.parameters.next(User.self)
    
    return try user.educations.all().makeJSON()
  }
  
  func getAttachment(_ req: Request) throws -> ResponseRepresentable {
    let user = try req.parameters.next(User.self)
    
    return try user.attachments.all().makeJSON()
  }
  
  // MARK: DELETERS
  
  func removeSkill(_ req: Request) throws -> ResponseRepresentable {
    let skill = try req.parameters.next(Skill.self)
    try skill.delete()
    
    return Response(status: .ok)
  }
  
  func removeLanguage(_ req: Request) throws -> ResponseRepresentable {
    let language = try req.parameters.next(Language.self)
    try language.delete()
    
    return Response(status: .ok)
  }
  
  // MARK: PUTTERS
  
  func updateSkill(_ req: Request) throws -> ResponseRepresentable {
    let skill = try req.parameters.next(Skill.self)
    
    guard let json = req.json else {
      throw Abort.badRequest
    }
    
    try skill.update(with: json)
   
    return skill
  }
  
  func updateLanguage(_ req: Request) throws -> ResponseRepresentable {
    let language = try req.parameters.next(Language.self)
    
    guard let json = req.json else {
      throw Abort.badRequest
    }
    
    try language.update(with: json)
    
    return language
  }
}




















