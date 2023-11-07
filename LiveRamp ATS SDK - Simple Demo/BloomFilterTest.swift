//
//  BloomFilterTest.swift
//  LiveRamp ATS SDK - Simple Demo
//
//  Created by Jason Chiu on 10/31/23.
//

import Foundation
import LRAtsSDK
import CommonCrypto


func doBloomFilterFlow(rawEmail: String) async -> String {
    
    var status = await LRAts.shared.syncFilters()

    var dealID = await lookupDealID(email: rawEmail)
    
    return dealID
}



func util_hashInputEmail(rawEmail: String)-> String{
    
    if let data = rawEmail.data(using: .utf8) {
            var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            data.withUnsafeBytes {
                _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
            }
            let hashedData = Data(hash)
            let hashedString = hashedData.map { String(format: "%02hhx", $0) }.joined()
            return hashedString
        }
    
        return ""

}


func lookupDealID(email: String) async -> String{
        
    let response = await LRAts.shared.getDealIDs(for: LRDealIdentifier(email: email))

    print("We have this many dealIds:", response.dealIDs?.count ?? -1)
    
    return response.dealIDs?.joined(separator: ",") ?? ""

}

