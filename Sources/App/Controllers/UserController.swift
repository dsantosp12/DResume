import Vapor
import FluentProvider

class UserController {
  func addRoutes(to drop: Droplet) {
    
    let userGroup = drop.grouped("api", "v1", "user")
    
    // Post
    userGroup.post(handler: createUser)
    userGroup.post(User.parameter, "skills", handler: addSkill)
    userGroup.post(User.parameter, "languages", handler: addLanguage)
    userGroup.post(User.parameter, "education", handler: addEducation)
    
    // Get
    userGroup.get(User.parameter, handler: getUser)
    userGroup.get(User.parameter, "skills", handler: getUserSkills)
    userGroup.get(User.parameter, "languages", handler: getLanguageSkills)
    userGroup.get(User.parameter, "education", handler: getEducation)
  }
  
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
  
  func getUser(_ req: Request) throws -> ResponseRepresentable {
    let user = try req.parameters.next(User.self)
    return user
  }
  
  func getUserSkills(_ req: Request) throws -> ResponseRepresentable {
    let user = try req.parameters.next(User.self)
    
    return try user.skills.all().makeJSON()
  }
  
  func getLanguageSkills(_ req: Request) throws -> ResponseRepresentable {
    let user = try req.parameters.next(User.self)
    
    return try user.languages.all().makeJSON()
  }
  
  func getEducation(_ req: Request) throws -> ResponseRepresentable {
    let user = try req.parameters.next(User.self)
    
    return try user.educations.all().makeJSON()
  }
}
