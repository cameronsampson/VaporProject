import Foundation
import Vapor
import HTTP
import Slugify

/// Here we have a controller that helps facilitate
/// RESTful interactions with our Posts table
final class PostController {
    
    private let view: ViewRenderer
    
    init(view: ViewRenderer) {
        self.view = view
    }
    
    /// When users call 'GET' on '/posts'
    /// it should return an index of all available posts
    func index(_ req: Request) throws -> ResponseRepresentable {
        let post = try Post.makeQuery().all()
        
        return try self.view.make("admin/post-index", [
            // "postlist": post
            "postlist": post.makeNode(in: nil)
            ])
    }
    
    /// When the user calls 'GET' on a specific resource, ie:
    /// '/posts/create' we should show that specific form to create post
    func create(_ req: Request) throws -> ResponseRepresentable {
        return try self.view.make("admin/post-create")
    }
    
    /// When consumers call 'POST' on '/posts' with valid JSON
    /// create and save the post
    func store(_ req: Request) throws -> ResponseRepresentable {
        guard let form = req.formURLEncoded else {
            throw Abort.badRequest
        }
        
        let post = try Post(node: form)
        
        post.slugurl = post.title?.slugify() // create a slug URL
        try post.save()
        
        return Response(redirect: "/admin/posts")
    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/posts/13rd88' we should show that specific post
    func show(_ req: Request) throws -> ResponseRepresentable {
        let post = try req.parameters.next(Post.self)
        return post
    }
    
    /// When the consumer calls 'GET' on a specific resource, ie:
    /// '/posts/13rd88/edit' we should show that specific post to edit
    func edit(_ req: Request) throws -> ResponseRepresentable {
        // Make sure the request contains an id
        guard let postId = req.parameters["id"]?.int else {
            throw Abort.badRequest
        }

        let post = try Post.makeQuery().find(postId)
        
//        let myDate = post?.postedon
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
//        let date = dateFormatter.date(from:myDate!)
//        dateFormatter.dateFormat = "MMMM dd, yyyy"
//        let dateString = dateFormatter.string(from:date!)
//
//        post?.postedon = dateString
        
        // Grab current date value of queried ID from Post table
        // to execute in formatDateString function
        let myDate = post?.postedon
        formatDateString(myDate!)
        
        // Grab converted date result from function to display properly on edit page
        post?.postedon = formatDateString(myDate!)
        
        return try self.view.make("admin/post-edit", [
            "post": post
            ])
    }
    
    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'posts/l2jd9' we should remove that resource from the database
    func delete(_ req: Request) throws -> ResponseRepresentable {
        let post = try req.parameters.next(Post.self)
        try post.delete()
        return Response(status: .ok)
    }
    
    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/posts' we should remove the entire table
    func clear(_ req: Request) throws -> ResponseRepresentable {
        try Post.makeQuery().delete()
        return Response(status: .ok)
    }
    
    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(_ req: Request) throws -> ResponseRepresentable {
        // Make sure the request contains an id
        guard let form = req.formURLEncoded else {
            throw Abort.badRequest
        }
        
        guard let postId = req.parameters["id"]?.int else {
            throw Abort.badRequest
        }
        
        guard let post = try Post.makeQuery().find(postId) else {
            throw Abort.notFound
        }
        
        let newpost = try Post(node: form)
        
        newpost.slugurl = newpost.title?.slugify() // slugify before assigning
        
        // Assign the new values back to old
        post.title = newpost.title
        post.postedon = newpost.postedon
        post.content = newpost.content
        post.tags = newpost.tags
        post.slugurl = newpost.slugurl
        post.poststatus = newpost.poststatus
        
        // Save and return the updated post
        try post.save()
        
        return Response(redirect: "/admin/posts")
    }
    
    /// When a user calls 'PUT' on a specific resource, we should replace any
    /// values that do not exist in the request with null.
    /// This is equivalent to creating a new Post with the same ID.
    func replace(_ req: Request) throws -> ResponseRepresentable {
        let post = try req.parameters.next(Post.self)
        // First attempt to create a new Post from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new = try req.post()
        
        // Update the post with all of the properties from
        // the new post
        post.content = new.content
        try post.save()
        
        // Return the updated post
        return post
    }
    
}

extension PostController {
    /// Converts the date back into a string in the 'MMMM d, yyyy' format
    /// Example: January 10, 1900
    @discardableResult func formatDateString(_ myDate: String) -> String? {
        // Assign newDate constant for date value and use DateFormatter class
        let newDate = myDate
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 60 * 60 * 9)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = formatter.date(from: newDate)
        formatter.dateFormat = "MMMM d, yyyy"
        let myDate = formatter.string(from: date!)

        return myDate
    }

}

//extension String {
//    /// Function to create a blurb by truncating characters
//    /// Example: My name is Cameron... 'Read more...'
//    func truncate(length: Int, trailing: String = "…") -> String {
//        return (self.count > length) ? self.prefix(length) + trailing : self
//    }
//}

extension Request {
    /// Create a post from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func post() throws -> Post {
        guard let json = json else { throw Abort.badRequest }
        return try Post(json: json)
    }
}
