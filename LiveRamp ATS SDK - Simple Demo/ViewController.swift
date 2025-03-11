//
//  ViewController.swift
//  LiveRamp ATS SDK - Simple Demo
//
//  Created by Jason Chiu on 4/1/22.
//

import UIKit
import AppTrackingTransparency
import LRAtsSDK
import GoogleMobileAds


class ViewController: UIViewController, BannerViewDelegate, AppEventDelegate {
    

    
    // View references
    @IBOutlet weak var label_sdkversion: UILabel!
    @IBOutlet weak var label_sdkinitstatus: UILabel!
    @IBOutlet weak var label_errMessage: UILabel!
    
    @IBOutlet weak var label_envelopeValue: UILabel!
    @IBOutlet weak var label_emailValue: UITextField!
    
    var bannerView: AdManagerBannerView!

    
    
    

    
    // TODO: Replace the init appID with your own app ID
    // DO NOT use this in production - it will cause you monetization issues.
    // let appId = "e47b5b24-f041-4b9f-9467-4744df409e31"
    let appId = "9fb12afd-5cc8-49c0-9716-2b8dfca21b06" // for ATSD POC
    let bloomApiKey = "0226Ae8c61cE03d0DDba71EaddB0D5CE"
    
    // For eCST logging POC
    var ecst_creativeId = ""
    var ecst_advertiserId = ""
    var ecst_campaignId = ""
    var ecst_lineItemId = ""
    var ecst_slot = ""

    var atsd_values = [String()]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeHideKeyboard();            // It's 2022. Yet, here we are still.
        updateSDKVersionLabel();             // This (very important) API will be available in a future version.
        updateSDKInitStatus(isInitialized: false);
        updateErrMessage(errMsg: "");
        
        // initializeATSSDK();
        setTestConsent();           // To enable ease of testing. Ensure consent is set before initializing the LR ATS SDK
        
        
        // Sample Setup of Ad SDKs (Testing programmatic supply paths)
        setupPubmaticOW()
        setupNimbus()
        setupPrebid()
        
        // Init GMA on start
        // GADMobileAds.sharedInstance().start(completionHandler: nil)
        MobileAds.shared.start()
        
        
        let viewWidth = view.frame.inset(by: view.safeAreaInsets).width

        let adaptiveSize = currentOrientationAnchoredAdaptiveBanner(width: viewWidth)
        bannerView = AdManagerBannerView(adSize: AdSizeMediumRectangle)
        
        bannerView.appEventDelegate = self
        bannerView.delegate = self
    }
    
    
    func adView(_ banner: BannerView, didReceiveAppEvent name: String, with info: String?) {
        // The AdManager banner sends app event messages to its app event delegate, this view controller. The
        // GADAppEventDelegate will be notified when the SDK receives an app event message from the
        // banner. In this demo, the GADAppEventDelegate method sets the background of this view
        // controller to match the data that comes in. The banner will send "red" when it loads, "blue"
        // five seconds later, and "green" if the user taps the banner.
        //
        // This is just a demonstration, of course. Your apps can do much more interesting things with
        // app events.
        
        print("didReceiveAppEvent!" + name);
        

        if name == "color" {
            guard let infoString = info else { return }
            switch infoString {
            case "blue":
                view.backgroundColor = UIColor.blue
            case "red":
                view.backgroundColor = UIColor.red
            case "green":
                view.backgroundColor = UIColor.green
            default:
                break
            }
        }
        
        // pick up the varios events we are sending from the creative -
//            admob.events.dispatchAppEvent("creativeId", creativeId);
//            admob.events.dispatchAppEvent("advertiserId", creativeId);
//            admob.events.dispatchAppEvent("campaignId", creativeId);
//            admob.events.dispatchAppEvent("lineItemId", creativeId);
//            admob.events.dispatchAppEvent("slot", creativeId);
        
        
        if name == "creativeId" {
            ecst_creativeId = info ?? "notFound"
        }
        
        if name == "advertiserId" {
            ecst_advertiserId = info ?? "notFound"
        }
        
        if name == "campaignId" {
            ecst_campaignId = info ?? "notFound"
        }
        
        if name == "lineItemId" {
            ecst_lineItemId = info ?? "notFound"
        }
        
        if name == "slot" {
            ecst_slot = info ?? "notFound"
        }
            

            
    }
    
    
    func fire_eCSTPOC() async {
        
        var exampleDataDict = [
            "creativeId": ecst_creativeId,
            "advertiserId": ecst_advertiserId,
            "campaignId": ecst_campaignId,
            "lineItemId": ecst_lineItemId,
            "slot": ecst_slot,
            "isMobileTest": "1"
        ] as [String : String]
        
        
        
        for (index, atsd_value) in atsd_values.enumerated() {
            print("KV \(index): \(atsd_value)")
            exampleDataDict["atsdealid\(index+1)"] = atsd_value
        }
        
        let ecstData = LReCSTData(jsonDict: exampleDataDict)
        
        do {
            let data = try await LRAts.shared.logeCST(with: ecstData)
            print("eCST sent: \(data)")
        } catch {
            print("Failed to call eCSTR: \(error)")
               }
        
        
        
    }
    
    
//    - (void)adView:(nonnull GADBannerView *)banner
//        didReceiveAppEvent:(nonnull NSString *)name
//                  withInfo:(nullable NSString *)info NS_SWIFT_NAME(adView(_:didReceiveAppEvent:with:));
//
//    /// Called when the interstitial receives an app event.
//    - (void)interstitialAd:(nonnull GADInterstitialAd *)interstitialAd
//        didReceiveAppEvent:(nonnull NSString *)name
//                  withInfo:(nullable NSString *)info NS_SWIFT_NAME(adView(_:didReceiveAppEvent:with:));

    
    // Section for GAD listeners

    

    
    // Test showing banners
    func requestAndShowBanner(){
        
        bannerView.translatesAutoresizingMaskIntoConstraints = false
           view.addSubview(bannerView)
           view.addConstraints(
             [NSLayoutConstraint(item: bannerView,
                                 attribute: .bottom,
                                 relatedBy: .equal,
                                 toItem: view.safeAreaLayoutGuide,
                                 attribute: .bottom,
                                 multiplier: 1,
                                 constant: 0),
              NSLayoutConstraint(item: bannerView,
                                 attribute: .centerX,
                                 relatedBy: .equal,
                                 toItem: view,
                                 attribute: .centerX,
                                 multiplier: 1,
                                 constant: 0)
             ])
          
        bannerView.adUnitID = "/22794602900/ats-direct-v2-demo"
        bannerView.rootViewController = self
        
        let request = AdManagerRequest()
        
        request.customTargeting = [atsdTargetingKey : getATSDirectKeyValues().joined(separator: ",")];

        
        bannerView.load(request)
    }
    
    
    // We require ATT in order to use ATS. (Without ATT)
    // No ATT = No RampID envelopes!
    func checkATTF(){
        
        print("Checking for ATT.")
        
        if #available(iOS 15, *), ATTrackingManager.trackingAuthorizationStatus != .authorized {
            print("[Warning] ATT was not authorized - authorize it to use ATS for envelopes!")
            
            ATTrackingManager.requestTrackingAuthorization { status in
               switch status {
                   case .authorized:
                       print("Authorized")      // Yes - ATS can fetch RampID envelopes!!
                   case .denied:
                       print("Denied")          // NO ATS calls can be made!
                   case .notDetermined:
                       print("Not Determined")  // NO ATS calls can be made!
                   case .restricted:
                       print("Restricted")      // NO ATS calls can be made!
                   @unknown default:
                       print("Unknown")         // NO ATS calls can be made!
               }
            }
        } else {
            print("ATT authorized - envelope fetch enabled!")
        }
    }
 
    
    
    // Strictly TEST consent values - to be only used for testing.
    // Your CMP should be doing this for you.
    func setTestConsent() {
        
        // Your CMP SDK should be responsible for setting these values.
//        let tcfString = "CPKZ42oPKZ5YtADABCENBlCgAP_AAAAAAAAAAwwAQAwgDDABADCAAA.YAAAAAAAA4AA"
//        let expectedPurposesConsent = "1111111111"
//        let expectedVendorsConsent = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
//        
        
        // Testing for Automatic
        let tcfString = "        CQNLZQAQNLZQAECACAENBeEgAP_AAELAAKiQGTgBxCJUCCFBIGBHAIIEIAgMQBAAQgQAAAIAAQAAAAAAEIgAgAAAAAAAACAAAAAAAAAAIAAAAAAAAAAAAIAABAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAEQABAAAEAAEAgAAAAAIACBk4AIAgVAABQABAQAAABAAAAEAQAEAAAAAAAAAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAEAAQAABAAAAIAAAAAAAAgAAAAA"
        let expectedPurposesConsent = "111111111100000000000000"
        let expectedVendorsConsent = "000000000111000100001000100101010000001000001000010100000100100000011000000100011100000000100000100000010000100000000010000000110001000000000100000000000001000010000001000000000000000000000000100000000000000001000000000000000000000000000000000000000000010000100010000000000010000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000100000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010001000000000000000100000000000000000000010000000000000000010000000010000000000000000000000000000000000000100000000000001"
        
        

        
        // let ccpaString = "1YNY"
        
        
    
        // Required for GDPR if EU
         UserDefaults.standard.set(tcfString, forKey: "IABTCF_TCString")
         UserDefaults.standard.set(expectedPurposesConsent, forKey: "IABTCF_PurposeConsents")
         UserDefaults.standard.set(expectedVendorsConsent, forKey: "IABTCF_VendorConsents")
        
        // Required for CCPA if US
        // UserDefaults.standard.set(ccpaString, forKey:"IABUSPrivacy_String");
    }
    
        
    
    func initializeATSSDK() {
            
        self.checkATTF()
        
        // Example workflow for how you determine whether you invoke hasConsentForNoLegislation
        let doNotRequireCCPACheckInUS = false;
        let supportOtherGeos = true;                // For handling initialization in a country that isn't US or EU
        
        if (doNotRequireCCPACheckInUS || supportOtherGeos) {
            LRAts.shared.hasConsentForNoLegislation = true
        }
     

        // let lrAtsConfiguration = LRAtsConfiguration(configID: appId)
        
        let lrAtsConfiguration = LRAtsConfiguration(configID: appId, apiKey: bloomApiKey)
    

            LRAts.shared.initialize(with: lrAtsConfiguration) { success, error in
            if success {
                print("LiveRamp ATS SDK is Ready!")
                self.updateSDKInitStatus(isInitialized: true)
                self.updateErrMessage(errMsg: "");
            } else {
                let errString = error?.localizedDescription
                print("Failed to init SDK with error", errString ?? "")
                self.updateErrMessage(errMsg: errString ?? "Unknown Error")
            }
        }
    
    }
    
        
    
    func fetchEnvelopeForEmail(email: String) {
        
        var displayString = ""
        
        
        Task {
            
            do {
                
                let identifier = LREmailIdentifier(email)
                 let envelope = try await LRAts.shared.getEnvelope(identifier)
                                // Handle Identity Envelopes
                
                
                let lr_envelope = envelope.envelope
                print("RampID Envelope: \(lr_envelope ?? "noEnvelope")")
                
                // TODO: Now, provide the lr_envelope value to your partner(s).
                // This value expires - by calling `getEnvelope`, you will ensure this value remains relevant.
                // Do NOT cache this value. It will not be valuable or useful!
                // You should always be using the most up to date envelope with downstream partners.
                // More documentation here: https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution
                setLREnvelopeForPartnerSDKs(envelope: lr_envelope ?? "noEnvelope")
                
                displayString += "lr_envelope: \(formatStringForDisplay(originalString: lr_envelope ?? "noEnvelope"))"
                
                // Handle PairIDs
                
                let pair_envelope = envelope.pairSegments
                print("PairID Segments: \(pair_envelope?.joined(separator: ",") ?? "noPairID")")
                // Join them together as a string array for display
                displayString += "pair_envelope: \(formatStringForDisplay(originalString: pair_envelope?.joined(separator: ",") ?? "noPairID"))"
                                
                setPairIdsForPartnerSDKs(pairIdsArr: pair_envelope ?? [])
                
                // Handle ATS Direct
                
                let atsd_envelope = envelope.atsDirectSegments
                atsd_values = envelope.atsDirectSegments ?? [] // duplicative, just for POC
                print("ATS Direct Segments: \(atsd_envelope?.joined(separator: ",") ?? "noATS_Direct")")
                setAtsdTargetingValues(values: atsd_envelope ?? [String]())
                
                
            } catch {
                let errString = "Couldn't retrieve envelopes. Error: \(error.localizedDescription)"
                updateErrMessage(errMsg: errString)
            }
            
                    
            
            // TEST: Make sample requests
            //            makePubmaticOWRequest()
            //            makeNimbusRequest(controller: self)
            //            makePrebidRequest(controller: self)
            
            updateDisplayString(envelopeString: displayString)

        }
    }

    
    // Other misc code to make this application run
    
    @IBAction func touchInitSDK(_ sender: Any) {
        self.initializeATSSDK();
    }
    
    
    @IBAction func touchFetchEnvelope(_ sender: Any) {
        let emailValue = label_emailValue.text;
        fetchEnvelopeForEmail(email: emailValue ?? "atstest+20@liveramp.com");
    }
    
    
    @IBAction func touchResetSDK(_ sender: Any) {
        LRAts.shared.resetSDK()             // Call this when the user is logged out!
        
        updateSDKInitStatus(isInitialized: false)
        print("SDK Reset")
        
        // On reset; also remember to clear targeting!
        setAtsdTargetingValues(values: [String()])
    }
    
    
    @IBAction func touchClearAll(_ sender: Any) {
        

        Task {
            await self.fire_eCSTPOC()
        }
        
        
        DispatchQueue.main.async {
            self.updateErrMessage(errMsg: "")
            self.label_envelopeValue.text = ""
            self.label_emailValue.text = ""
        }
    }
    
    @IBAction func touchRequestShowAd(_ sender: Any) {
        self.requestAndShowBanner()
    }
    
    
            
    func updateErrMessage(errMsg: String) {
        DispatchQueue.main.async {
            if (errMsg == "") {
                self.label_errMessage.isHidden = true;
            } else {
                self.label_errMessage.isHidden = false;
                self.label_errMessage.text = errMsg;
            }
        }

    }
            
    
    func updateSDKVersionLabel(){
        DispatchQueue.main.async {
            self.label_sdkversion.text = LRAts.sdkVersion;
        }
    }
    
    
    func updateDisplayString(envelopeString: String) {
        DispatchQueue.main.async {
            self.label_envelopeValue.self.text = envelopeString;
        }
    }
    
    
    func formatStringForDisplay(originalString: String) -> String{
        if (originalString.count > 100) {
            return originalString.prefix(100) + "... +" + String(originalString.count-100) + "\n"
        } else {
            return originalString
        }
    }
    
    
    func updateSDKInitStatus(isInitialized: Bool) {
        DispatchQueue.main.async {
            if (isInitialized) {
                self.label_sdkinitstatus.text = "Initialized"
            } else {
                self.label_sdkinitstatus.text = "Not Initialized"
            }
        }

    }
    
    
    func initializeHideKeyboard(){
        // Credits for keyboard hiding: https://www.cometchat.com/tutorials/how-to-dismiss-ios-keyboard-swift
        let tap: UITapGestureRecognizer = UITapGestureRecognizer( target: self, action: #selector(dismissMyKeyboard))
        view.addGestureRecognizer(tap)
     }
    
    
    @objc func dismissMyKeyboard(){
        view.endEditing(true)
     }

}
