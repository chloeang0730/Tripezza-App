//
//  VolumeData.swift
//  Tripezza
//
//  Created by Chloe Ang on 12/05/2023.
//
//  In order to do easy extraction of hotel information from the decoded data,
//  this class which provides a structure that matches the expected format of the JSON data.

import UIKit

class VolumeData: NSObject,Decodable {

    var hotels:[HotelData]?
    var nextPageToken:String?

    // map the JSON key names to the corresponding property names in the class during the decoding
    private enum CodingKeys: String, CodingKey{
        case nextPageToken = "next_page_token"
        case hotels = "results"
    }


}
