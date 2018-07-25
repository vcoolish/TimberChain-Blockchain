import Vapor
import HTTP

final class PostController: ResourceRepresentable {
    
    func index(_ req: Request) throws -> ResponseRepresentable {
        return try Post.all().makeJSON()
    }

    func store(_ req: Request) throws -> ResponseRepresentable {
        let post = try req.post()
        try post.save()
        return post
    }

    func show(_ req: Request, post: Post) throws -> ResponseRepresentable {
        return post
    }

    func delete(_ req: Request, post: Post) throws -> ResponseRepresentable {
        try post.delete()
        return Response(status: .ok)
    }

    func clear(_ req: Request) throws -> ResponseRepresentable {
        try Post.makeQuery().delete()
        return Response(status: .ok)
    }

    func update(_ req: Request, post: Post) throws -> ResponseRepresentable {
        try post.update(for: req)

        try post.save()
        return post
    }

    func replace(_ req: Request, post: Post) throws -> ResponseRepresentable {
        
        let new = try req.post()

        post.content = new.content
        try post.save()

        return post
    }

    func makeResource() -> Resource<Post> {
        return Resource(
            index: index,
            store: store,
            show: show,
            update: update,
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    func post() throws -> Post {
        guard let json = json else { throw Abort.badRequest }
        return try Post(json: json)
    }
}

extension PostController: EmptyInitializable { }
