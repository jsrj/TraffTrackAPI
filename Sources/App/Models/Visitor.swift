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
    let TimeOfVisit:      String
    let VisitDurationMin: Int
    let AssocAppkey:      String
    let AssocAppTitle:    String
    let Source:           String
    
    init(
        vistorID:      String,
        visitorPort:   String,
        userAgent:     String,
        assocAppKey:   String,
        assocAppTitle: String,
        source:        String
        
        ) {
        // vistorID    - X-Forwarded-For
        // VisitorPort - X-Forwarded-Port
        self.VisitorSignature = "\(String(vistorID)):\(String(visitorPort))/"
        
        self.UserAgent        = userAgent
        self.AssocAppkey      = assocAppKey
        self.AssocAppTitle    = assocAppTitle
        
        let currentDate       = Date()
        let DTFormatter       = DateFormatter()
        DTFormatter.dateStyle = .long
        DTFormatter.timeStyle = .long
        self.TimeOfVisit      = DTFormatter.string(from: currentDate)
        
        self.VisitDurationMin = 0
        self.Source           = source
    }
    
    init(row: Row) throws {
        VisitorSignature = try row.get("VisitorSignature")
        UserAgent        = try row.get("UserAgent")
        TimeOfVisit      = try row.get("TimeOfVisit")
        VisitDurationMin = try row.get("VisitDurationMin")
        AssocAppkey      = try row.get("AssocAppKey")
        AssocAppTitle    = try row.get("AssocAppTitle")
        Source           = try row.get("Source")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        
            try row.set("VisitorSignature", VisitorSignature)
            try row.set("UserAgent"       , UserAgent)
            try row.set("TimeOfVisit"     , TimeOfVisit)
            try row.set("VisitDurationMin", VisitDurationMin)
            try row.set("AssocAppKey"     , AssocAppkey)
            try row.set("AssocAppTitle"   , AssocAppTitle)
            try row.set("Source"          , Source)
        
        return row
    }
}

extension Visitor: Preparation {
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { builder in
            
            builder.id()
            builder.string("VisitorSignature")
            builder.string("UserAgent")
            builder.string("TimeOfVisit")
            builder.int("VisitDurationMin")
            builder.string("AssocAppKey")
            builder.string("AssocAppTitle")
            builder.string("Source")
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
            assocAppKey:    json.get("AppKey"),
            assocAppTitle:  json.get("assocAppTitle"),
            source:         json.get("Source")
        )}
    
    func makeJSON() throws -> JSON {
        // JSONification from Database for GET request
        var VisitorTraceJson = JSON()
        
        try VisitorTraceJson.set("id", id)
        try VisitorTraceJson.set("VisitorSignature", VisitorSignature)
        try VisitorTraceJson.set("UserAgent"       , UserAgent)
        try VisitorTraceJson.set("TimeOfVisit"     , TimeOfVisit)
        try VisitorTraceJson.set("VisitDurationMin", VisitDurationMin)
        try VisitorTraceJson.set("AssocAppKey"     , AssocAppkey)
        try VisitorTraceJson.set("AssocAppTitle"   , AssocAppTitle)
        try VisitorTraceJson.set("Source"          , Source)
        
        return VisitorTraceJson
    }
}

extension Visitor: ResponseRepresentable {}
