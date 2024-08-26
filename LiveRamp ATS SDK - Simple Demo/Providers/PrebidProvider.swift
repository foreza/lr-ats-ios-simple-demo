//
//  PrebidProvider.swift
//  LiveRamp ATS SDK - Simple Demo
//
//  Created by Jason Chiu on 8/15/24.
//

import Foundation
import PrebidMobile


// https://github.com/prebid/prebid-mobile-ios/blob/master/Example/PrebidDemo/PrebidDemoSwift/AppDelegate.swift
// https://github.com/prebid/prebid-mobile-ios/blob/master/Example/PrebidDemo/PrebidDemoSwift/Examples/In-App/InAppDisplayInterstitialViewController.swift

private var renderingInterstitial: InterstitialRenderingAdUnit!


func setupPrebid() {
    
    Prebid.shared.prebidServerAccountId = "0689a263-318d-448b-a3d4-b02e8a709d9d"
    try! Prebid.shared.setCustomPrebidServer(url: "https://prebid-server-test-j.prebid.org/openrtb2/auction")
    
    Prebid.initializeSDK { status, error in
        if let error = error {
            print("Initialization Error: \(error.localizedDescription)")
            return
        }
    }
    
    Targeting.shared.sourceapp = "PrebidDemoSwift"
    
    
    
    
}


func makePrebidRequest(controller: ViewController) {
    
    renderingInterstitial = InterstitialRenderingAdUnit(configID: "prebid-demo-display-interstitial-320-480")
    
    
    renderingInterstitial.adFormats = [.banner]
    renderingInterstitial.delegate = controller
    
    // 3. Load the interstitial ad
    renderingInterstitial.loadAd()
    
    
}
