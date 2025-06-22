//
//  UserPreferenceCoreData+CoreDataProperties.swift
//  UpNextAI
//
//  Created by Isabel Cuddihy on 6/22/25.
//
//

import Foundation
import CoreData


extension UserPreferenceCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserPreferenceCoreData> {
        return NSFetchRequest<UserPreferenceCoreData>(entityName: "UserPreferenceCoreData")
    }

    @NSManaged public var isLiked: Bool
    @NSManaged public var tmdbId: Int64
    @NSManaged public var name: String?
    @NSManaged public var type: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var profile: UserProfileCoreData?

}

extension UserPreferenceCoreData : Identifiable {

}
