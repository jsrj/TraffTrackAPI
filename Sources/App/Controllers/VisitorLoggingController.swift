//
//  VisitorLoggingController.swift
//  trafftrak-api
//
//  Created by Arjay Jones on 1/23/18.
//

import Vapor
import FluentProvider
import Foundation

struct VisitorLoggingController {
    func addRoutes(to drop: Droplet) {
        
        // Translates to www.url.com/visitor/trace/
        let visitorsGroup = drop.grouped("visitor", "trace")
        
        // www.url.com/visitor/trace/log/0ab34-exo1f-829d-920dd3
        visitorsGroup.post("log/", handler: sendLogData)
    }
    
    func sendLogData(_ req: Request) throws -> ResponseRepresentable {
        
        var initJson = JSON()
        let UserAgent   = String(req.headers["User-Agent"]       != nil ? req.headers["User-Agent"]! : "Unknown")
        let VisitorIP   = String(req.headers["X-Forwarded-For"]  != nil ? req.headers["X-Forwarded-For"]!  : "0")
        let VisitorPort = String(req.headers["X-Forwarded-Port"] != nil ? req.headers["X-Forwarded-Port"]! : "0")

        try initJson.set("UserAgent",   UserAgent)
        try initJson.set("VisitorIP",   VisitorIP)
        try initJson.set("VisitorPort", VisitorPort)
        try initJson.set("uniqueLink",  String(describing: req.uri))
        try initJson.set("appURI",      (req.headers["Host"] != nil ? req.headers["Host"]! : "None"))

        let newVisitorTrace = try Visitor(json: initJson)
        try newVisitorTrace.save()

        return newVisitorTrace
    }
}
