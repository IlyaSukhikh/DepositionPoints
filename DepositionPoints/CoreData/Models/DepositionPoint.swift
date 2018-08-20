//
//  DepositionPoint.swift
//  DepositionPoints
//
//  Created by Ilya Sukhikh on 16/08/2018.
//  Copyright © 2018 Ilya Sukhikh. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

@objc(DepositionPoint)
public class DepositionPoint: ManagedObject, Decodable, ManagedObjectType {

    @NSManaged public var externalId: String
    @NSManaged public var partnerName: String
    @NSManaged public var latitude: Float
    @NSManaged public var longitude: Float
    
    @NSManaged public var workHours: String?
    @NSManaged public var phones: String?
    @NSManaged public var addressInfo: String?
    @NSManaged public var fullAddress: String?

    @NSManaged public var partner: Partner?
    
    private enum CodingKeys: String, CodingKey {
        case externalId, partnerName, location, workHours, phones, addressInfo, fullAddress
    }
    
    var picture: String? {
        return self.partner?.picture
    }
    
    convenience public required init(from decoder: Decoder) throws {
        
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext
            else { fatalError("Missing context or invalid context") }
        
        self.init(entity: DepositionPoint.entity(), insertInto: context)
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.externalId = try container.decode(String.self, forKey: .externalId)
        self.partnerName = try container.decode(String.self, forKey: .partnerName)
        
        let location = try container.decode(Location.self, forKey: .location)
        self.latitude = location.latitude
        self.longitude = location.longitude

        self.workHours = try container.decodeIfPresent(String.self, forKey: .workHours)
        self.phones = try container.decodeIfPresent(String.self, forKey: .phones)
        self.addressInfo = try container.decodeIfPresent(String.self, forKey: .addressInfo)
        self.fullAddress = try container.decodeIfPresent(String.self, forKey: .fullAddress)
        
        let predicate = Partner.makePredicate(partnerId: self.partnerName)
        self.partner = Partner.findOrCreateInContext(moc: context, matchingPredicate: predicate) { blankPartner in
            blankPartner.id = self.partnerName
            blankPartner.isBlank = true
        }
    }
}

extension DepositionPoint {
    
    static func makePartnerPredicate(_ partnerName: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", argumentArray: [#keyPath(DepositionPoint.partnerName), partnerName])
    }
}

extension DepositionPoint {

    public override var debugDescription: String {
        return "\(partnerName) at lat: \(latitude) long: \(longitude)"
    }
}
