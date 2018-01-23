//
//  Visitor.swift
//  trafftrak-api
//
//  Created by Arjay Jones on 1/23/18.
//

import FluentProvider
import Foundation

final class Reminder: Model {
    let storage = Storage()
    
    let VisitorSignature: String
    let UserAgent:        String
    
    
    init(vistorID: String, visitorPort: String, userAgent: String) {
        // vistorID    - X-Forwarded-For
        // VisitorPort - X-Forwarded-Port
        self.VisitorSignature = "\(String(vistorID)):\(String(visitorPort))/"
        self.UserAgent        = userAgent
    }
    
    init(row: Row) throws {
        VisitorSignature = try row.get("VisitorSignature")
        UserAgent        = try row.get("UserAgent")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set("VisitorSignature", VisitorSignature)
        try row.set("UserAgent",        UserAgent)
        
        return row
    }
}

extension Reminder: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            
            builder.id()
            builder.string("VisitorSignature")
            builder.string("UserAgent")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
