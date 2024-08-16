//
//  PubmaticOWProvider.swift
//  LiveRamp ATS SDK - Simple Demo
//
//  Created by Jason Chiu on 8/15/24.
//

import Foundation
import OpenWrapSDK

// https://github.com/PubMatic/ios-openwrap-sdk-samples/blob/master/OpenWrap/Basic/NoAdServer/Swift/SampleApp/SampleApp/AppDelegate/AppDelegate.swift
// https://github.com/PubMatic/ios-openwrap-sdk-samples/blob/master/OpenWrap/Basic/NoAdServer/Swift/SampleApp/SampleApp/ViewControllers/Interstitial/InterstitialViewController.swift

let owAdUnit  = "OpenWrapInterstitialAdUnit"
let pubId = "156276"
let profileId : NSNumber = 1165
var interstitial: POBInterstitial?

func setupPubmaticOW() {
    
    OpenWrapSDK.setLogLevel(.all)
    OpenWrapSDK.setSSLEnabled(false)
    
    let appInfo = POBApplicationInfo()
    appInfo.storeURL = URL(string: "https://itunes.apple.com/us/app/pubmatic-sdk-app/id1175273098?mt=8")!

    OpenWrapSDK.setApplicationInfo(appInfo)
    OpenWrapSDK.setDSAComplianceStatus(.required)

    
    interstitial = POBInterstitial(publisherId: pubId, profileId: profileId, adUnitId: owAdUnit)

}


func makePubmaticOWRequest() {
    interstitial?.loadAd()
}
