import Vapor
import FluentProvider
import HTTP

final class Post: Model {
    let storage = Storage()
    
    var content: String
    
    struct Keys {
        static let id = "id"
        static let content = "content"
    }
    
    init(content: String) {
        self.content = content
    }

    init(row: Row) throws {
        content = try row.get(Post.Keys.content)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Post.Keys.content, content)
        return row
    }
}

extension Post: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Post.Keys.content)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Post: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            content: try json.get(Post.Keys.content)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Post.Keys.id, id)
        try json.set(Post.Keys.content, content)
        return json
    }
}

extension Post: ResponseRepresentable { }

extension Post: Updateable {
    public static var updateableKeys: [UpdateableKey<Post>] {
        return [
            UpdateableKey(Post.Keys.content, String.self) { post, content in
                post.content = content
            }
        ]
    }
}
