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
                        "items", handler: addSectionItem)
    
    // Get
    portfolioGroup.get(Portfolio.parameter, handler: getPortfolio)
    portfolioGroup.get(Portfolio.parameter, "full", handler: getFullPortfolio)
    portfolioGroup.get(Portfolio.parameter, "links", handler: getLinks)
    portfolioGroup.get(Portfolio.parameter, "sections", handler: getSections)
    portfolioGroup.get(Portfolio.parameter, "section", "item",
                       SectionItem.parameter, handler: getSectionItem)
    portfolioGroup.get(Portfolio.parameter, "section", Section.parameter,
                       "items", handler: getSectionItems)
    
    // Delete
    portfolioGroup.delete(Portfolio.parameter, handler: removePortfolio)
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
  
  func getFullPortfolio(_ req: Request) throws -> ResponseRepresentable {
    let portfolio = try req.parameters.next(Portfolio.self)
    
    let portfolioData = try portfolio.fullPortfolio()    
    
    return portfolioData
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
  
  func getSectionItems(_ req: Request) throws -> ResponseRepresentable {
    let section = try req.parameters.next(Section.self)
    
    return try section.sectionItems.all().makeJSON()
  }
  
  // MARK: Deleters
  func removePortfolio(_ req: Request) throws -> ResponseRepresentable {
    let portfolio = try req.parameters.next(Portfolio.self)
    
    try portfolio.links.all().forEach { link in
      try link.delete()
    }
    
    try portfolio.sections.all().forEach{ section in
      try section.sectionItems.all().forEach { item in
        try item.delete()
      }
      try section.delete()
    }
    
    try portfolio.delete()
    
    return Response(status: .ok)
  }
}
