//
//  AnalyticsController.swift
//  trafftrak-api
//
//  Created by Arjay Jones on 1/23/18.
//
// Primary Roles: Create New Analytics Profile for an App, View All Profiles by Owner, View Profile by Application Key

import Vapor
import FluentProvider
import Foundation

struct AnalyticsController {
    func addRoutes(to drop: Droplet) {
        
        // Translates to www.url.com/app/tracker/
        let analyticsGroup = drop.grouped("app", "tracker")
        
        // www.url.com/app/tracker/new
        analyticsGroup.post("/new", handler: createNewTracker)
    }
    
    
    func createNewTracker(_ req: Request) throws -> ResponseRepresentable {
        guard let json = req.json else {
            throw Abort.badRequest
        }
        
        let newTracker = try AnalyticsData(json: json)
        try newTracker.save()
        
        return newTracker
    }
}
