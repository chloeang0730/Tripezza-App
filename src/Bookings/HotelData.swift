
//  HotelData.swift
//  Tripezza
//
//  Created by Chloe Ang on 12/05/2023.
//
//  HotelData represents the decoded data structure for a single hotel

import Foundation


class HotelData: NSObject,Decodable{
    
    // the properties of the hotel
    var name: String
    var rating: Double?
    var vicinity: String?
    var business_status:String?
    
    // map the JSON key name to the corresponding property name in the class
    private enum CodingKeys:String,CodingKey{
        case name
        case vicinity
        case business_status
    }
    // rating's data type is double
    // map rating's JSOn key name to the corresponding name in the class
    private enum DoubleKeys:String,CodingKey{
        case rating
 
    }

    // this function creates the required initialiser for the HotelData
    required init(from decoder: Decoder) throws{
        // create container to decode properties in CodingKeys
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // special container to decode ratings
        let KeyContainer = try decoder.container(keyedBy:DoubleKeys.self)
        
        //decode the data
        name = try container.decode(String.self, forKey: .name)
        vicinity = try container.decodeIfPresent(String.self, forKey: .vicinity)
        business_status = try container.decodeIfPresent(String.self, forKey: .business_status)
    
        rating = try KeyContainer.decodeIfPresent(Double.self, forKey: .rating)
        
        super.init()
    }
    
    
    
    
    
}
