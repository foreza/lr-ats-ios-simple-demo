//
//  PairIdentity.swift
//  LiveRamp ATS SDK - Simple Demo
//
//  Created by Jason Chiu on 08/15/24.
//

import Foundation

import PrebidMobile
import OpenWrapSDK
import NimbusKit

func setPairIdsForPartnerSDKs(pairIdsArr: [String]) {
    setPairIdsForPubmaticOW(pairIds: pairIdsArr)
    setPairIdsForPrebid(pairIds: pairIdsArr)
    setPairIdsForNimbus(pairIds: pairIdsArr)
}


// [PREBID] Set the PairIDs envelope in Prebid SDK (or managed Prebid Partner)
// https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution#prebid-sdk
// https://docs.prebid.org/prebid-mobile/pbm-api/ios/pbm-targeting-ios.html#user-identity-api
// This ensures all subsequent ad requests to Prebid Server contain the RampID envelope.
func setPairIdsForPrebid(pairIds: [String]) {
    for pairId in pairIds {
        
        Targeting.shared.storeExternalUserId(ExternalUserId(source: "google.com", identifier: pairId, atype: 571187))
//        Prebid.shared.externalUserIdArray.append(ExternalUserId(source: "google.com", identifier: pairId, atype: 571187))
    }
    
    
    
    
    
    
}



// [Pubmatic OW] Set the PairIDs in Pubmatic's OW SDK
// https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution#pubmatic
// https://community.pubmatic.com/display/IOPO/Advanced+topics#Advancedtopics-UserIdentity(DataPartnerIDs)
// This ensures all subsequent ad requests to Pubmatic OpenWrap contain the RampID envelope.
func setPairIdsForPubmaticOW(pairIds: [String]){
    
    for pairId in pairIds {
        let tPairId = POBExternalUserId(source: "google.com", andId: pairId)
        tPairId.atype = 571187;
        OpenWrapSDK.addExternalUserId(tPairId)
    }
    


}


// [Nimbus] Set the PairIDs in Nimbus's SDK
func setPairIdsForNimbus(pairIds: [String]){
    
    for pairId in pairIds {
        NimbusRequestManager.extendedIds?.insert(
        NimbusExtendedId(source: "google.com", uids: [NimbusExtendedId.UID(id: pairId, atype: 571187)])
        )
    }
}
