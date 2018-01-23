import Vapor

extension Droplet {
    func setupRoutes() throws {
        
        let analyticsController = AnalyticsController()
        analyticsController.addRoutes(to: self)
        
        let visitorLoggingController = VisitorLoggingController()
        visitorLoggingController.addRoutes(to: self)

        
        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            
            // req.description will also be usable for logging data about visitor such as user-agent, for responsive optimization in the future.
            
            // x-Forwarded-For info can be used to identify unique sessions semi-reliably as well.
            return req.description
        }
        get("description") { req in return req.description }
    }
}
