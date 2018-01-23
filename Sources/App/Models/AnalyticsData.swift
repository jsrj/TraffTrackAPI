import FluentProvider
import Foundation

final class AnalyticsData: Model {
    let storage = Storage()
    
    // YAGNI - Keep it basic for now. Tracking web visits, Name/URL of app, link clicks, and duration of visit.
    
    let ApplicationName:  String
    let ApplicationURI:   String
    let ApplicationKey:   String
    let URIsVisitedFrom:  String
    
    // Since relational databases are weak with arrays, this will have to be a comma dilimited string instead.
    let OwnerID:          Int
    
    // Comma delimited string of ID numbers
    let VisitorLogIDs:    String
    
    
    init(
        applicationName: String,
        applicationURI:  String,
        ownerID: Int            ) {
        
        self.ApplicationName = applicationName
        self.ApplicationURI  = applicationURI
        self.ApplicationKey  = UUID().uuidString
        self.OwnerID         = ownerID
        
        self.VisitorLogIDs   = ""
        self.URIsVisitedFrom = "\(applicationURI),"
        
    }
    
    
    init(row: Row) throws {
        ApplicationName  = try row.get("ApplicationName")
        ApplicationURI   = try row.get("ApplicationURI")
        ApplicationKey   = try row.get("ApplicationKey")
        URIsVisitedFrom  = try row.get("URIsVisitedFrom")
        OwnerID          = try row.get("OwnerID")
        VisitorLogIDs    = try row.get("VisitorLogIDs")
    }
    
    
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set("ApplicationName", ApplicationName)
        try row.set("ApplicationURI",  ApplicationURI)
        try row.set("ApplicationKey",  ApplicationKey)
        try row.set("URIsVisitedFrom", URIsVisitedFrom)
        try row.set("OwnerID",         OwnerID)
        try row.set("VisitorLogIDs",   VisitorLogIDs)
        
        return row
    }
}


extension AnalyticsData: Preparation {
    static func prepare(_ database: Database) throws {
        
        try database.create(self) { builder in
            
            builder.id()
            builder.string( "ApplicationName"  )
            builder.string( "ApplicationURI"   )
            builder.string( "ApplicationKey"   )
            builder.string( "URIsVisitedFrom"  )
            builder.int(    "OwnerID"          )
            builder.string( "VisitorLogIDs"    )
        }
        
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// Route Specific Extensions
extension AnalyticsData: JSONConvertible {
    convenience init(json: JSON) throws {
        // Creation from JSON/POST request
        try self.init(
            applicationName:  json.get("ApplicationName"),
            applicationURI:   json.get("ApplicationURI"),
            ownerID:          json.get("OwnerID")
        )}
    
    func makeJSON() throws -> JSON {
        // JSONification from Database for GET request
        var AnalyticsDataJson = JSON()
        
        try AnalyticsDataJson.set("id", id)
        try AnalyticsDataJson.set("ApplicationName", ApplicationName)
        try AnalyticsDataJson.set("ApplicationURI",  ApplicationURI)
        try AnalyticsDataJson.set("ApplicationKey",  ApplicationKey)
        try AnalyticsDataJson.set("URIsVisitedFrom", URIsVisitedFrom)
        try AnalyticsDataJson.set("OwnerID",         OwnerID)
        // MARK: Convert to an array of Visitor objects queried from the parsed IDs string.
        try AnalyticsDataJson.set("VisitorLogIDs",   VisitorLogIDs)
        
        return AnalyticsDataJson
    }
}

extension AnalyticsData: ResponseRepresentable {}
