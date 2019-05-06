@_exported import Vapor

extension Droplet {
    public func setup() throws {
        let postCollection = PostCollection(view)
        try collection(postCollection)
        // Do any additional droplet setup
    }
}
