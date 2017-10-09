import Vapor

extension Droplet {
  func setupRoutes() throws {
    let userController = UserController()
    userController.addRoutes(to: self)
    
    let portfolioController = PortfolioController()
    portfolioController.addRoutes(to: self)
  }
}
