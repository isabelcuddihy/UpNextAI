//
//  UserProfileCoreData+CoreDataProperties.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/22/25.
//
//

import Foundation
import CoreData


extension UserProfileCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProfileCoreData> {
        return NSFetchRequest<UserProfileCoreData>(entityName: "UserProfileCoreData")
    }

    @NSManaged public var id: UUID
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var createdDate: Date?
    @NSManaged public var name: String
    @NSManaged public var preferences: Set<UserPreferenceCoreData>?
    @NSManaged public var hasCompletedOnboarding: Bool

}

extension UserProfileCoreData : Identifiable {

}
