import FluentProvider
import Foundation

final class AnalyticsData: Model {
    let storage = Storage()
    
    // YAGNI - Keep it basic for now. Tracking web visits, Name/URL of app, link clicks, and duration of visit.
    
    let ApplicationName:  String
    let ApplicationURI:   String
    let ApplicationKey:   String
    
    let VisitedFrom:      String
    
    // Since relational databases are weak with arrays, this will have to be a comma dilimited string instead.
    let LinksNavigated:   String
    
    let TimeOfVisit:      String
    let VisitDurationMin: Int
    
    let OwnerID:          Int
    
    // Comma delimited string of ID numbers
    let VisitorIDs:       String
    
    
    init(
        applicationName: String,
        applicationURI: String,
        visitedFrom: String,
        ownerID: Int            ) {
        
        self.ApplicationName = applicationName
        self.ApplicationURI  = applicationURI
        self.ApplicationKey  = UUID().uuidString
        self.OwnerID         = ownerID
        self.VisitorIDs      = ""
        
        self.VisitedFrom     = visitedFrom
        self.LinksNavigated  = ""
        
        let currentDate       = Date()
        let DTFormatter       = DateFormatter()
        DTFormatter.dateStyle = .long
        DTFormatter.timeStyle = .long
        self.TimeOfVisit      = DTFormatter.string(from: currentDate)
        
        self.VisitDurationMin = 0
    }
    
    
    init(row: Row) throws {
        ApplicationName  = try row.get("ApplicationName")
        ApplicationURI   = try row.get("ApplicationURI")
        ApplicationKey   = try row.get("ApplicationKey")
        VisitedFrom      = try row.get("VisitedFrom")
        LinksNavigated   = try row.get("LinksNavigated")
        TimeOfVisit      = try row.get("TimeOfVisit")
        VisitDurationMin = try row.get("VisitDurationMin")
        OwnerID          = try row.get("OwnerID")
        VisitorIDs       = try row.get("VisitorIDs")
    }
    
    
    func makeRow() throws -> Row {
        var row = Row()
        
        try row.set("ApplicationName", ApplicationName)
        try row.set("ApplicationURI",  ApplicationURI)
        try row.set("ApplicationKey",  ApplicationKey)
        try row.set("VisitedFrom",     VisitedFrom)
        try row.set("LinksNavigated",  LinksNavigated)
        try row.set("TimeOfVisit",     TimeOfVisit)
        try row.set("VisitDurationMin",VisitDurationMin)
        try row.set("OwnerID",         OwnerID)
        try row.set("VisitorIDs",      VisitorIDs)
        
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
            builder.string( "VisitedFrom"      )
            builder.string(   "LinksNavigated" )
            builder.string( "TimeOfVisit"      )
            builder.int(    "VisitDurationMin" )
            builder.int(    "OwnerID"          )
            builder.string( "VisitorIDs"       )
        }
        
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
