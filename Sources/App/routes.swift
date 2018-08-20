import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Waazzzuuppp, Homes??!!"
    }
    
    // POST
    router.post("api", "acronyms") { req -> Future<Acronym> in
        return try req.content.decode(Acronym.self).flatMap(to: Acronym.self) { acronym in
            
            return acronym.save(on: req)
        }
    }
    
    // GET (RETRIEVE) ALL
    router.get("api", "acronyms") { req -> Future<[Acronym]> in
        return Acronym.query(on: req).all()
    }
    
    // GET (RETRIEVE) ONE
    router.get("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        return try req.parameters.next(Acronym.self)
    }
    
    // PUT (UPDATE)
    router.put("api", "acronyms", Acronym.parameter) { req -> Future<Acronym> in
        
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
    router.delete("api", "acronyms", Acronym.parameter) { req -> Future<HTTPStatus> in
            return try req.parameters.next(Acronym.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }
    
    
    // FILTER
    router.get("api", "acronyms", "search") { req -> Future<[Acronym]> in
        
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest)
        }
        // FILTER ONLY short ACRONYM
//        return try Acronym.query(on: req)
//            .filter(\.short == searchTerm)
//            .all()
        
        return try Acronym.query(on: req).group(.or) { or in
            try or.filter(\.short == searchTerm)
            try or.filter(\.long == searchTerm)
        }.all()
    }
    
    // FIRST RESULT
    router.get("api", "acronyms", "first") { req -> Future<Acronym> in
        
        return Acronym.query(on: req)
            .first()
            .map(to: Acronym.self) { acronym in
                guard let _acronym = acronym else {
                    throw Abort(.notFound)
                }
                return _acronym
        }
    }
    
    // SORTING RESULTS
    router.get("api", "acronyms", "sorted") {
        req -> Future<[Acronym]> in
        return try Acronym.query(on: req)
            .sort(\.short, .ascending)
            .all()
    }
    
}



// starting a postgresql database

