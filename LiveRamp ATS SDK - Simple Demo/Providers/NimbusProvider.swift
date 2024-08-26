//
//  NimbusProvider.swift
//  LiveRamp ATS SDK - Simple Demo
//
//  Created by Jason Chiu on 8/15/24.
//

import Foundation
import NimbusKit

import NimbusRenderStaticKit
import NimbusRenderVideoKit


// https://docs.adsbynimbus.com/docs/sdk/ios/integration
// https://github.com/adsbynimbus/nimbus-ios-sample/blob/main/Application/Sources/Initialization.swift
// https://github.com/adsbynimbus/nimbus-ios-sample/blob/main/Resources/Info.plist

// TODO: get Nimbus Ad Request to Fire

var test_publisherKey = "dev-sdk"
var test_apiKey = "d352cac1-cae2-4774-97ba-4e15c6276be0"
var test_reqURL = "https://\(test_publisherKey).adsbynimbus.com/rta/test"

func setupNimbus() {
        
    Nimbus.shared.initialize(
             publisher: test_publisherKey,
             apiKey: test_apiKey
         )
    
//    Nimbus.shared.renderers = [
//        .forAuctionType(.static): NimbusStaticAdRenderer(),
//        .forAuctionType(.video): NimbusVideoAdRenderer(),
//    ]
//    
    Nimbus.shared.logLevel = .info
//    Nimbus.shared.testMode = true
    Nimbus.shared.coppa = false
    Nimbus.shared.usPrivacyString = "1YNY"
    
    
    NimbusAdManager.requestUrl = URL(string: test_reqURL)!
    NimbusAdManager.user = NimbusUser(age: 33, gender: .male)

    var adManager: NimbusAdManager?

}


func makeNimbusRequest(controller: ViewController) {
    
    // Please make sure Nimbus.shared.initialize is called before this
    var adManager: NimbusAdManager?
    
    let request = NimbusRequest.forInterstitialAd(position: "position")
    
    adManager = NimbusAdManager()
    
    adManager?.showBlockingAd(
        request: request,
        closeButtonDelay: 10,
        adPresentingViewController: controller
    )
}
