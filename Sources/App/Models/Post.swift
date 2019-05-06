import Foundation
import Vapor
import FluentProvider
import PostgreSQLProvider

final class Post: Model, Parameterizable {
    let storage = Storage()
    
    // MARK: Properties and database keys
    
    /// The content of the post
    var id: Node?
    var title: String?
    var postedon: String?
    var summary: String?
    var content: String?
    var tags: String?
    var slugurl: String?
    var poststatus: Bool?
    
    /// The column names for `id` and `content` in the database
    //  static let idKey = "id"
    static let titleKey = "title"
    static let postedonKey = "postedon"
    static let summaryKey = "summary"
    static let contentKey = "content"
    static let tagsKey = "tags"
    static let slugurlKey = "slugurl"
    static let poststatusKey = "poststatus"
    
    /// Creates a new Post
    init(title: String, postedon: String, summary: String, content: String, tags: String, slugurl: String, poststatus: Bool) {
        self.id = nil
        self.title = title
        self.postedon = postedon
        self.summary = summary
        self.content = content
        self.tags = tags
        self.slugurl = slugurl
        self.poststatus = poststatus
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        id = try row.get(Post.idKey)
        title = try row.get(Post.titleKey)
        postedon = try row.get(Post.postedonKey)
        summary = try row.get(Post.summaryKey)
        content = try row.get(Post.contentKey)
        tags = try row.get(Post.tagsKey)
        slugurl = try row.get(Post.slugurlKey)
        poststatus = try row.get(Post.poststatusKey)
    }
    
    // Init model from a Node-structure to allow data from web
    init(node: Node) throws {
        title = try node.get(Post.titleKey)
        postedon = try node.get(Post.postedonKey)
        summary = try node.get(Post.summaryKey)
        content = try node.get(Post.contentKey)
        tags = try node.get(Post.tagsKey)
        slugurl = try node.get(Post.slugurlKey)
        poststatus = try node.get(Post.poststatusKey)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Post.titleKey, title)
        try row.set(Post.postedonKey, postedon)
        try row.set(Post.summaryKey, summary)
        try row.set(Post.contentKey, content)
        try row.set(Post.tagsKey, tags)
        try row.set(Post.slugurlKey, slugurl)
        try row.set(Post.poststatusKey, poststatus)
        return row
    }
}

// MARK: Fluent Preparation

extension Post: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Post.titleKey)
            builder.custom(Post.postedonKey, type: "TIMESTAMP")
            builder.custom(Post.summaryKey, type: "text")
            builder.custom(Post.contentKey, type: "text")
            builder.string(Post.tagsKey)
            builder.string(Post.slugurlKey)
            builder.bool(Post.poststatusKey)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: Node Representation

// How the model sets form data
extension Post: NodeRepresentable {
    
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        
        try node.set(Post.idKey, id?.int)
        try node.set(Post.titleKey, title)
        try node.set(Post.postedonKey, postedon)
        try node.set(Post.summaryKey, summary)
        try node.set(Post.contentKey, content)
        try node.set(Post.tagsKey, tags)
        try node.set(Post.slugurlKey, slugurl)
        try node.set(Post.poststatusKey, poststatus)
        
        return node
    }
}


// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension Post: JSONRepresentable {
    convenience init(json: JSON) throws {
        try self.init(
            title: json.get(Post.titleKey),
            postedon: json.get(Post.postedonKey),
            summary: json.get(Post.summaryKey),
            content: json.get(Post.contentKey),
            tags: json.get(Post.tagsKey),
            slugurl: json.get(Post.slugurlKey),
            poststatus: json.get(Post.poststatusKey)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Post.idKey, id)
        try json.set(Post.titleKey, title)
        try json.set(Post.postedonKey, postedon)
        try json.set(Post.summaryKey, summary)
        try json.set(Post.contentKey, content)
        try json.set(Post.tagsKey, tags)
        try json.set(Post.slugurlKey, slugurl)
        try json.set(Post.poststatusKey, poststatus)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension Post: ResponseRepresentable { }

// MARK: Update

// This allows the Post model to be updated
// dynamically by the request.
extension Post: Updateable {
    // Updateable keys are called when `post.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Post>] {
        return [
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Post.titleKey, String.self) { post, title in
                post.title = title
            },
            UpdateableKey(Post.summaryKey, String.self) { post, summary in
                post.summary = summary
            },
            UpdateableKey(Post.postedonKey, String.self) { post, postedon in
                post.postedon = postedon
            },
            UpdateableKey(Post.contentKey, String.self) { post, content in
                post.content = content
            },
            UpdateableKey(Post.tagsKey, String.self) { post, tags in
                post.tags = tags
            },
            UpdateableKey(Post.slugurlKey, String.self) { post, slugurl in
                post.slugurl = slugurl
            },
            UpdateableKey(Post.poststatusKey, Bool.self) { post, poststatus in
                post.poststatus = poststatus
            }
        ]
    }
}


extension Post: Timestampable {
    
    var formattedCreatedAt: String? {
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 60 * 60 * 9)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return createdAt.map { formatter.string(from: $0) }
    }
    
    var formattedUpdatedAt: String? {
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 60 * 60 * 9)
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return updatedAt.map { formatter.string(from: $0) }
    }
}
