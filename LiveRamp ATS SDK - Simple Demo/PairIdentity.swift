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

func setPairIdsForPartnerSDKs(envelope: String) {
    
    //    setLREnvelopeForPrebid(envelope: envelope)
    //    setLREnvelopeForInMobi(envelope: envelope)
    //    setLREnvelopeForPubmaticOW(envelope: envelope)
    //    setLREnvelopeForNimbus(envelope: envelope)
    //    setLREnvelopeForPubmaticOW(envelope: envelope)
    // More partners coming soon!
    // Note: Google Ad Manager is a separate workflow.
    
}


// [PREBID] Set the updated RampID envelope in Prebid SDK (or managed Prebid Partner)
// https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution#prebid-sdk
// https://docs.prebid.org/prebid-mobile/pbm-api/ios/pbm-targeting-ios.html#user-identity-api
// This ensures all subsequent ad requests to Prebid Server contain the RampID envelope.
func setPairIdsForPrebid(envelope: String) {
    
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
func setPairIdsForPubmaticOW(envelope: String){
    
    var userId = POBExternalUserId(source: "liveramp.com", andId: envelope)
//    userId.atype =
//    OpenWrapSDK.addExternalUserId(userId)
    
    // TODO: Do a sample OpenWrap ad request to validate
}


// [Nimbus] Set the updated RampID envelope in Nimbus's SDK
// https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution#nimbus
// https://docs.adsbynimbus.com/docs/sdk/ios/extensions/liveramp#setup
func setPairIdsForNimbus(envelope: String){
    
//    var extendedId = NimbusExtendedId(source: "liveramp.com", id: envelope)
//    extendedId.extensions = ["rtiPartner": NimbusCodable("idl")]
//    NimbusAdManager.extendedIds = [extendedId]
    
    // TODO: Do a sample Nimbus ad request to validate
}

