import Vapor
import FluentProvider

class PortfolioController {
  
  func addRoutes(to drop: Droplet) {
    let portfolioGroup = drop.grouped("api", "v1", "portfolio")
    
    // Post
    portfolioGroup.post(handler: addPortfolio)
    portfolioGroup.post(Portfolio.parameter, "links", handler: addLink)
    portfolioGroup.post(Portfolio.parameter, "sections", handler: addSection)
    portfolioGroup.post(Portfolio.parameter, "section", Section.parameter,
                        "item", handler: addSectionItem)
    
    // Get
    portfolioGroup.get(Portfolio.parameter, handler: getPortfolio)
    portfolioGroup.get(Portfolio.parameter, "links", handler: getLinks)
    portfolioGroup.get(Portfolio.parameter, "sections", handler: getSections)
    portfolioGroup.post(Portfolio.parameter, "section", Section.parameter,
                        "item", SectionItem.parameter, handler: getSectionItem)
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
  
  func addSectionItem(_ req: Request) throws -> ResponseRepresentable {
    let section = try req.parameters.next(Section.self)
    
    guard var json = req.json  else {
      throw Abort.badRequest
    }
    
    try json.set(SectionItem.sectionIDKey, section.id)
    
    let sectionItem = try SectionItem(json: json)
    try sectionItem.save()
    
    return sectionItem
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
  
  func getSectionItem(_ req: Request) throws -> ResponseRepresentable {
    let sectionItem = try req.parameters.next(SectionItem.self)
    
    return sectionItem
  }
}
