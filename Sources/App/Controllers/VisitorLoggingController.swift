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
        let visitorsGroup = drop.grouped("trace")
        
        // e.g. www.url.com/visitor/trace/log/ | www.url.com/visitor/trace/log/
        visitorsGroup.post("log", handler: sendLogData)
    }
    
    func sendLogData(_ req: Request) throws -> ResponseRepresentable {
        guard let clientIn = req.json else {
            print("Did not recieve any request data.")
            throw Abort.badRequest
        }
        
        var initJson = JSON()
        let UserAgent   = String(req.headers["User-Agent"]       != nil ? req.headers["User-Agent"]! : "Unknown")
        let VisitorIP   = String(req.headers["X-Forwarded-For"]  != nil ? req.headers["X-Forwarded-For"]!  : "0")
        let VisitorPort = String(req.headers["X-Forwarded-Port"] != nil ? req.headers["X-Forwarded-Port"]! : "0")

        // MARK: Evaluate incoming App Key. If no Key is provided in the meta tracker, then do not save data to DB.
        try initJson.set("VisitorIP"    , VisitorIP)
        try initJson.set("VisitorPort"  , VisitorPort)
        try initJson.set("UserAgent"    , UserAgent)
        try initJson.set("AppKey"       , (clientIn["AppKey"]   != nil ? clientIn["AppKey"]   : "Invalid Ping" ))
        try initJson.set("assocAppTitle", (clientIn["AppTitle"] != nil ? clientIn["AppTitle"] : "Untitled"     ))
        try initJson.set("Source"       , (clientIn["Referrer"] != nil ? clientIn["Referrer"] : "Non-External" ))

        let newVisitorTrace = try Visitor(json: initJson)
        try newVisitorTrace.save()
        return newVisitorTrace
    }
}
