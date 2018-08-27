import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    
    func boot(router: Router) throws {
    
        
        
        
    let acronymsRoutes = router.grouped("api", "acronyms")
    
        acronymsRoutes.get(use: getAllHandler)
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    
}
