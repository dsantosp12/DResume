import Vapor
import FluentProvider

class PortfolioController {
  
  func addRoutes(to drop: Droplet) {
    let portfolioGroup = drop.grouped("api", "v1", "portfolio")
    
    // Post
    portfolioGroup.post(handler: addPortfolio)
    
    // Get
    portfolioGroup.get(Portfolio.parameter, handler: getPortfolio)
    
  }
  
  func addPortfolio(_ req: Request) throws -> ResponseRepresentable {
    guard let json = req.json else {
      throw Abort.badRequest
    }
    
    let portfolio = try Portfolio(json: json)
    try portfolio.save()
    
    return portfolio
  }
  
  func getPortfolio(_ req: Request) throws -> ResponseRepresentable {
    let portfolio = try req.parameters.next(Portfolio.self)
    
    return portfolio
  }
}
