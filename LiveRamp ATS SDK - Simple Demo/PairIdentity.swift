//
//  PairIdentity.swift
//  LiveRamp ATS SDK - Simple Demo
//
//  Created by Jason Chiu on 08/15/24.
//

import Foundation

//import PrebidMobile
import OpenWrapSDK
//import NimbusKit

func setPairIdsForPartnerSDKs(pairIdsArr: [String]) {
    setPairIdsForPubmaticOW(pairIds: pairIdsArr)
    setPairIdsForPrebid(pairIds: pairIdsArr)
    setPairIdsForNimbus(pairIds: pairIdsArr)
}


// [PREBID] Set the updated RampID envelope in Prebid SDK (or managed Prebid Partner)
// https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution#prebid-sdk
// https://docs.prebid.org/prebid-mobile/pbm-api/ios/pbm-targeting-ios.html#user-identity-api
// This ensures all subsequent ad requests to Prebid Server contain the RampID envelope.
func setPairIdsForPrebid(pairIds: [String]) {
    
//    var externalUserIdArray = [ExternalUserId]()
//    externalUserIdArray.append(
//        ExternalUserId(source: "liveramp.com", identifier: envelope))
//
//    Prebid.shared.externalUserIdArray = externalUserIdArray
    
    // TODO: Do a sample Prebid ad request to validate
}



// [Pubmatic OW] Set the updated RampID envelope in Pubmatic's OW server
// https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution#pubmatic
// https://community.pubmatic.com/display/IOPO/Advanced+topics#Advancedtopics-UserIdentity(DataPartnerIDs)
// This ensures all subsequent ad requests to Pubmatic OpenWrap contain the RampID envelope.
func setPairIdsForPubmaticOW(pairIds: [String]){
    
    for pairId in pairIds {
        var tPairId = POBExternalUserId(source: "google.com", andId: pairId)
        tPairId.atype = 571187;
        OpenWrapSDK.addExternalUserId(tPairId)
    }

}


// [Nimbus] Set the updated RampID envelope in Nimbus's SDK
// https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution#nimbus
// https://docs.adsbynimbus.com/docs/sdk/ios/extensions/liveramp#setup
func setPairIdsForNimbus(pairIds: [String]){
    
//    var extendedId = NimbusExtendedId(source: "liveramp.com", id: envelope)
//    extendedId.extensions = ["rtiPartner": NimbusCodable("idl")]
//    NimbusAdManager.extendedIds = [extendedId]
    
    // TODO: Do a sample Nimbus ad request to validate
}

