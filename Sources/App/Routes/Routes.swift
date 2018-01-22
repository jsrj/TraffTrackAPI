import Vapor

extension Droplet {
    func setupRoutes() throws {
        get("/") { req in
            var resJson = JSON()
            try resJson.set("message", "Trafftrak-API layer hosted on Heroku works!")
        }
        
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        try resource("posts", PostController.self)
    }
}
