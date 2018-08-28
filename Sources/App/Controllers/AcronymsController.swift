import Vapor
import Fluent

struct AcronymsController: RouteCollection {
    
    func boot(router: Router) throws {
        
    let acronymsRoutes = router.grouped("api", "acronyms")
        //acronymsRoutes.get(use: getAllHandler)
        
        acronymsRoutes.post(Acronym.self, use: createHandler)
        acronymsRoutes.get(Acronym.parameter, use: getHandler)
        acronymsRoutes.put(Acronym.parameter, use: updateHandler)
        acronymsRoutes.delete(Acronym.parameter, use: deleteHandler)
        acronymsRoutes.get("search", use: searchHandler)
        acronymsRoutes.get("first", use: getFirstHandler)
        acronymsRoutes.get("sorted", use: sortedHandler)
    }

    // GET ALL
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    
    // CREATE
    func createHandler(_ req: Request, acronym: Acronym) throws -> Future<Acronym> {
                return acronym.save(on: req)
    }
    
    // GET SINGLE
    func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    // PUT / UPDATE
    func updateHandler(_ req: Request) throws -> Future<Acronym> {
            // 1
            return try flatMap(to: Acronym.self,
                               req.parameters.next(Acronym.self),
                               req.content.decode(Acronym.self)) { acronym, updatedAcronym in
            //2
            acronym.short = updatedAcronym.short
            acronym.long = updatedAcronym.long
    
            //3
                return acronym.save(on: req)
            }
    }
    
    // DELETE
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    // SEARCH
    func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
            guard let searchTerm = req.query[String.self, at: "term"] else {
                throw Abort(.badRequest)
            }
            return try Acronym.query(on: req).group(.or) { or in
                try or.filter(\.short == searchTerm)
                try or.filter(\.long == searchTerm)
            }.all()
    }
    
    func getFirstHandler(_ req: Request) throws -> Future<Acronym> {
            return Acronym.query(on: req)
                .first()
                .map(to: Acronym.self) { acronym in
                    guard let _acronym = acronym else {
                        throw Abort(.notFound)
                    }
                    return _acronym
            }
    }
    
    func sortedHandler(_ req: Request) throws -> Future<[Acronym]> {
            return try Acronym.query(on: req)
                .sort(\.short, .ascending)
                .all()
    }
    
    
}
