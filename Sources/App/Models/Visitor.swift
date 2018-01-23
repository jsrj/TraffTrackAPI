//
//  Visitor.swift
//  trafftrak-api
//
//  Created by Arjay Jones on 1/23/18.
//

import FluentProvider
import Foundation

final class Visitor: Model {
    let storage = Storage()
    
    let VisitorSignature: String
    let UserAgent:        String
    let LinkNavigated:    String
    let TimeOfVisit:      String
    let VisitDurationMin: Int
    let AssocAppURI:      String
    
    init(
        vistorID:      String,
        visitorPort:   String,
        userAgent:     String,
        linkNavigated: String,
        assocAppURI:   String
        ) {
        // vistorID    - X-Forwarded-For
        // VisitorPort - X-Forwarded-Port
        self.VisitorSignature = "\(String(vistorID)):\(String(visitorPort))/"
        
        self.UserAgent        = userAgent
        self.LinkNavigated   = linkNavigated
        
        let currentDate       = Date()
        let DTFormatter       = DateFormatter()
        DTFormatter.dateStyle = .long
        DTFormatter.timeStyle = .long
        self.TimeOfVisit      = DTFormatter.string(from: currentDate)
        
        self.VisitDurationMin = 0
        self.AssocAppURI      = assocAppURI
    }
    
    init(row: Row) throws {
        VisitorSignature = try row.get("VisitorSignature")
        UserAgent        = try row.get("UserAgent")
        LinkNavigated    = try row.get("LinkNavigated")
        TimeOfVisit      = try row.get("TimeOfVisit")
        VisitDurationMin = try row.get("VisitDurationMin")
        AssocAppURI      = try row.get("AssocAppURI")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set("VisitorSignature", VisitorSignature)
        try row.set("UserAgent",        UserAgent)
        try row.set("LinkNavigated",    LinkNavigated)
        try row.set("TimeOfVisit",      TimeOfVisit)
        try row.set("VisitDurationMin", VisitDurationMin)
        try row.set("AssocAppURI",      AssocAppURI)
        
        return row
    }
}

extension Visitor: Preparation {
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { builder in
            
            builder.id()
            builder.string("VisitorSignature")
            builder.string("UserAgent")
            builder.string("LinkNavigated")
            builder.string("TimeOfVisit")
            builder.int("VisitDurationMin")
            builder.string("AssocAppURI")
        }
        
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// Route Specific Extensions
extension Visitor: JSONConvertible {
    convenience init(json: JSON) throws {
        // Creation from JSON/POST request
        try self.init(
            vistorID:       json.get("VisitorIP"),
            visitorPort:    json.get("VisitorPort"),
            userAgent:      json.get("UserAgent"),
            
            // From req.json
            linkNavigated:  json.get("uniqueLink"),
            assocAppURI:    json.get("appURI")
        )}
    
    func makeJSON() throws -> JSON {
        // JSONification from Database for GET request
        var VisitorTraceJson = JSON()
        
        try VisitorTraceJson.set("id", id)
        try VisitorTraceJson.set("VisitorSignature", VisitorSignature)
        try VisitorTraceJson.set("UserAgent",        UserAgent)
        try VisitorTraceJson.set("LinkNavigated",    LinkNavigated)
        try VisitorTraceJson.set("TimeOfVisit",      TimeOfVisit)
        try VisitorTraceJson.set("VisitDurationMin", VisitDurationMin)
        try VisitorTraceJson.set("AssocAppURI",      AssocAppURI)
        
        return VisitorTraceJson
    }
}

extension Visitor: ResponseRepresentable {}
