import Vapor

final class PostCollection: RouteCollection {
    
    private let view: ViewRenderer
    
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {

        // Admin Routes
        let postAdmin = builder.grouped("admin", "posts")
        let pc = PostController(view: view)
        
        postAdmin.get(handler: pc.index) // show list of posts
        postAdmin.get("new", handler: pc.create) // create new post
        postAdmin.get(":id", "edit", handler: pc.edit) // edit post
        postAdmin.post("created", handler: pc.store) // save new post
        postAdmin.post(":id", "edited", handler: pc.update) // save edited post (needs parameter)
        
        builder.get("info") { req in
            return req.description
        }

    }
}
