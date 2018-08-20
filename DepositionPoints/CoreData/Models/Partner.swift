//
//  Partner+Decadable.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import Foundation
import CoreData

@objc(Partner)
public class Partner: ManagedObject, Decodable, ManagedObjectType {
    
    @NSManaged public var id: String
    @NSManaged public var name: String?
    @NSManaged public var picture: String?
    @NSManaged public var url: String?
    @NSManaged public var hasLocations: Bool
    @NSManaged public var isMomentary: Bool
    @NSManaged public var depositionDuration: String?
    @NSManaged public var limitations: String?
    @NSManaged public var note: String?
    @NSManaged public var isBlank: Bool
    @NSManaged public var points: Set<DepositionPoint>

    private enum CodingKeys: String, CodingKey {
        case id, name, picture, url, hasLocations, depositionDuration, limitations, pointType, isMomentary
        case note = "description"
    }
    
    convenience public required init(from decoder: Decoder) throws {
        
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext
            else { fatalError("Missing context or invalid context") }
        
        self.init(entity: Partner.entity(), insertInto: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.picture = try container.decodeIfPresent(String.self, forKey: .picture)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.hasLocations = try container.decodeIfPresent(Bool.self, forKey: .hasLocations) ?? false
        self.isMomentary = try container.decodeIfPresent(Bool.self, forKey: .isMomentary) ?? false
        self.depositionDuration = try container.decodeIfPresent(String.self, forKey: .depositionDuration)
        self.limitations = try container.decodeIfPresent(String.self, forKey: .limitations)
        self.note = try container.decodeIfPresent(String.self, forKey: .note)
        self.isBlank = false
    }
}

extension Partner {
    
    static func makePredicate(partnerId: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", argumentArray: [#keyPath(Partner.id), partnerId])
    }
}

