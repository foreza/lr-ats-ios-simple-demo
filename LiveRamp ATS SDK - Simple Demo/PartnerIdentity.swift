//
//  PartnerIdentity.swift
//  LiveRamp ATS SDK - Simple Demo
//
//  Created by Jason Chiu on 11/6/23.
//

import Foundation
//
import PrebidMobile
import OpenWrapSDK
import NimbusKit
//import InMobiSDK
//import MobileFuseSDK



var atsdTargetingValues = [String]() // store ATSD here
let atsdTargetingKey = "atsd";


func setLREnvelopeForPartnerSDKs(envelope: String) {
    
        setLREnvelopeForPrebid(envelope: envelope)
        setLREnvelopeForPubmaticOW(envelope: envelope)
        setLREnvelopeForNimbus(envelope: envelope)
    //    setLREnvelopeForInMobi(envelope: envelope)
    //    setLREnvelopeForMobileFuse(envelope: envelope)
    // More partners coming soon!
    // Note: Google Ad Manager is a separate workflow.
    
}


// [PREBID] Set the updated RampID envelope in Prebid SDK (or managed Prebid Partner)
// https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution#prebid-sdk
// https://docs.prebid.org/prebid-mobile/pbm-api/ios/pbm-targeting-ios.html#user-identity-api
// This ensures all subsequent ad requests to Prebid Server contain the RampID envelope.
func setLREnvelopeForPrebid(envelope: String) {
    
//    var externalUserIdArray = [ExternalUserId]()
//    externalUserIdArray.append(
//        ExternalUserId(source: "liveramp.com", identifier: envelope))
//
//    Prebid.shared.externalUserIdArray = externalUserIdArray
  
    
    Targeting.shared.storeExternalUserId(ExternalUserId(source: "liveramp.com", identifier: envelope))

    
    // TODO: Do a sample Prebid ad request to validate
}


// [InMobi UnifId] Set the updated RampID envelope in InMobi's UnifID service
// https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution#inmobi
// https://support.inmobi.com/monetize/data-identity/unifid/unifid-sdk-contract-specifications#unifid-api-specification
// This ensures all subsequent ad requests to InMobi's exchange contain the RampID envelope.
func setLREnvelopeForInMobi(envelope: String) {
    
//    var idDictionary = ["liveramp.com": envelope]
//    IMSdk.self.setPublisherProvidedUnifiedId(idDictionary)
//
    // TODO: Do a sample InMobi ad request to validate
}


// [Pubmatic OW] Set the updated RampID envelope in Pubmatic's OW server
// https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution#pubmatic
// https://community.pubmatic.com/display/IOPO/Advanced+topics#Advancedtopics-UserIdentity(DataPartnerIDs)
// This ensures all subsequent ad requests to Pubmatic OpenWrap contain the RampID envelope.
func setLREnvelopeForPubmaticOW(envelope: String){
    let userId = POBExternalUserId(source: "liveramp.com", andId: envelope)
    OpenWrapSDK.addExternalUserId(userId)
}


// [Nimbus] Set the updated RampID envelope in Nimbus's SDK
// https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution#nimbus
// https://docs.adsbynimbus.com/docs/sdk/ios/extensions/liveramp#setup
func setLREnvelopeForNimbus(envelope: String){
    
    var extendedId = NimbusExtendedId(source: "liveramp.com", id: envelope)
    extendedId.extensions = ["rtiPartner": NimbusCodable("idl")]
    NimbusAdManager.extendedIds = [extendedId]
    
    // TODO: Do a sample Nimbus ad request to validate
}


// [MobileFuse] Set the updated RampID envelope in MobileFuse's SDK
// https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution#mobilefuse
// https://docs.mobilefuse.com/docs/leveraging-rampid-and-uid2#passing-in-a-liveramp-envelope-directly
func setLREnvelopeForMobileFuse(envelope: String){
    
//        MobileFuseTargetingData.setLiveRampEnvelope(envelope)
    
    // TODO: Do a sample MF ad request to validate

}


// [ATSD] Get the key value pair and persist it here for use in Google's SDK
func setAtsdTargetingValues(values: [String]){
    
    if (values.isEmpty) {
        atsdTargetingValues = [String]()
    }
    
    atsdTargetingValues = values
}

func getATSDirectKeyValues() -> [String]{
    return atsdTargetingValues
}

