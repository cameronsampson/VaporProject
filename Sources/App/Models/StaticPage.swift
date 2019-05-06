import Foundation
import Vapor
import FluentProvider
import HTTP

final class StaticPage: Model {
    let storage = Storage()
    
    var exists: Bool = false

    let name: String
    let title: String?
    let body: String?
    
    init(name: String, title: String?, body: String?) {
        self.name = name
        self.title = title
        self.body = body
    }
    
    //Initializable from a Node
    init(row: Row) throws {
        name = try row.get("name")
        title = try row.get("title")
        body = try row.get("body")
    }
    
    //Node representable
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("title", title)
        try row.set("body", body)
        return row
    }
}

// MARK: Fluent Preparation
extension StaticPage: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { staticPage in
            staticPage.id()
            staticPage.string("name")
            staticPage.string("body", optional: true)
            staticPage.string("title", optional: true)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
