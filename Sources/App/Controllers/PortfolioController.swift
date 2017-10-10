import Vapor
import FluentProvider

class PortfolioController {
  
  func addRoutes(to drop: Droplet) {
    let portfolioGroup = drop.grouped("api", "v1", "portfolio")
    
    // Post
    portfolioGroup.post(handler: addPortfolio)
    portfolioGroup.post(Portfolio.parameter, "sections", handler: addSection)
    portfolioGroup.post(Portfolio.parameter, "links", handler: addLink)
    
    // Get
    portfolioGroup.get(Portfolio.parameter, handler: getPortfolio)
    portfolioGroup.get(Portfolio.parameter, "sections", handler: getSections)
    portfolioGroup.get(Portfolio.parameter, "links", handler: getLinks)
  }
  
  // MARK: POSTERS
  
  func addPortfolio(_ req: Request) throws -> ResponseRepresentable {
    guard let json = req.json else {
      throw Abort.badRequest
    }
    
    let portfolio = try Portfolio(json: json)
    try portfolio.save()
    
    return portfolio
  }
  
  func addSection(_ req: Request) throws -> ResponseRepresentable {
    guard let json = req.json else {
      throw Abort.badRequest
    }
    
    let section = try Section(json: json)
    try section.save()
    
    return section
  }
  
  func addLink(_ req: Request) throws -> ResponseRepresentable {
    guard let json = req.json else {
      throw Abort.badRequest
    }
    
    let link = try Link(json: json)
    try link.save()
    
    return link
  }
  
  // MARK: GETTERS
  
  func getPortfolio(_ req: Request) throws -> ResponseRepresentable {
    let portfolio = try req.parameters.next(Portfolio.self)
    
    return portfolio
  }
  
  func getSections(_ req: Request) throws -> ResponseRepresentable {
    let portfolio = try req.parameters.next(Portfolio.self)
    
    return try portfolio.sections.all().makeJSON()
  }
  
  func getLinks(_ req: Request) throws -> ResponseRepresentable {
    let portfolio = try req.parameters.next(Portfolio.self)
    
    return try portfolio.links.all().makeJSON()
  }
}
