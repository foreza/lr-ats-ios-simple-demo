//
//  ViewController.swift
//  LiveRamp ATS SDK - Simple Demo
//
//  Created by Jason Chiu on 4/1/22.
//

import UIKit
import AppTrackingTransparency
import LRAtsSDK

import PrebidMobile
import InMobiSDK
import OpenWrapSDK
import MobileFuseSDK
import NimbusKit



class ViewController: UIViewController {

    
    // View references
    @IBOutlet weak var label_sdkversion: UILabel!
    @IBOutlet weak var label_sdkinitstatus: UILabel!
    @IBOutlet weak var label_errMessage: UILabel!
    
    @IBOutlet weak var label_envelopeValue: UILabel!
    @IBOutlet weak var label_emailValue: UITextField!
    
    // TODO: Replace the init appID with your own app ID before you go into production
     let appId = "e47b5b24-f041-4b9f-9467-4744df409e31"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeHideKeyboard();            // It's 2022. Yet, here we are still.
        updateSDKVersionLabel();             // This (very important) API will be available in a future version.
        updateSDKInitStatus(isInitialized: false);
        updateErrMessage(errMsg: "");
        
        // initializeATSSDK();
        setTestConsent();           // To enable ease of testing. Ensure consent is set before initializing the LR ATS SDK
    }
    
    
    
    // We require ATT in order to operate!
    // No ATT = No RampID envelopes!
    func checkATTF(){
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                   switch status {
                   case .authorized:
                       // ATS can function!
                       print("Authorized")
                   case .denied:
                       // NO ATS calls can be made!
                       print("Denied")
                   case .notDetermined:
                       // NO ATS calls can be made!
                       print("Not Determined")
                   case .restricted:
                       // NO ATS calls can be made!
                       print("Restricted")
                   @unknown default:
                       // NO ATS calls can be made!
                       print("Unknown")
                   }
               }

        }
    }
 
    
    
    // Strictly TEST consent values - to be only used for testing!
    func setTestConsent() {
        
        // Your CMP SDK should be responsible for setting these values.
        let tcfString = "CPKZ42oPKZ5YtADABCENBlCgAP_AAAAAAAAAAwwAQAwgDDABADCAAA.YAAAAAAAA4AA"
        let expectedPurposesConsent = "1111111111"
        let expectedVendorsConsent = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
        let ccpaString = "1YNN"
        
        // Required for GDPR if EU
        // UserDefaults.standard.set(tcfString, forKey: "IABTCF_TCString")
        // UserDefaults.standard.set(expectedPurposesConsent, forKey: "IABTCF_PurposeConsents")
        // UserDefaults.standard.set(expectedVendorsConsent, forKey: "IABTCF_VendorConsents")
        
        // Required for CCPA if US
        UserDefaults.standard.set(ccpaString, forKey:"IABUSPrivacy_String");
    }
    
    
    func initializeATSSDK() {
            
        self.checkATTF()
        
        // Example workflow for how you determine whether you invoke hasConsentForNoLegislation
        let doNotRequireCCPACheckInUS = false;
        let supportOtherGeos = true;                // For handling initialization in a country that isn't US or EU
        
        if (doNotRequireCCPACheckInUS || supportOtherGeos) {
            LRAts.shared.hasConsentForNoLegislation = true
            // LRAts.shared.hasConsentForNoLegislation = true;
        }
     
        // Provide just the appId - optional arg for isTestMode (by default, it'll be false)
        let lrAtsConfiguration = LRAtsConfiguration(appId: appId, isTestMode: false);

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
        
        let lrEmailIdentifier = LREmailIdentifier(email)
                
        LRAts.shared.getEnvelope(lrEmailIdentifier) { result, error in
            
            if (error != nil) {
                let errString = "Couldn't retrieve envelope. Error: \(error?.localizedDescription)"
                self.updateErrMessage(errMsg: errString)
            }
            
            // Fetch RampID Envelope - this is used in most downstream bids, and segmentation usecases
//            guard let lr_envelope = result?.envelope else {
//                let errString = "Couldn't retrieve envelope. Error: \(error?.localizedDescription)"
//                self.updateErrMessage(errMsg: errString)
//                print(errString)
//            }
            
            var displayString = ""
        
            if let lr_envelope: String = result?.envelope {
                print("RampID Envelope: \(lr_envelope)")
                displayString += "lr_envelope: \(self.formatStringForDisplay(originalString: lr_envelope))"
                self.setLREnvelopeForPartnerSDKs(envelope: lr_envelope)
            }
            
            
            if let pair_envelope: String = result?.envelope25 {
                print("Encoded PairIDs: \(pair_envelope)")
                displayString += "pair_envelope: \(self.formatStringForDisplay(originalString: pair_envelope))"
                // self.setPairIDsForPartnerSDKs(envelope: pair_envelope)
            } else {
                print("No PairIDs returned")
            }
            
            self.updateDisplayString(envelopeString: displayString)


//            self.updateErrMessage(errMsg: "");
        }
        
    }
    
    // Always make sure your RampID envelope is up to date!
    // Always fetch RampID envelope using getEnvelope to ensure the value is not stale
    // Then, set that value for downstream partners.
    func setLREnvelopeForPartnerSDKs(envelope: String) {
        
        setLREnvelopeForPrebid(envelope: envelope)
        setLREnvelopeForInMobi(envelope: envelope)
        setLREnvelopeForPubmaticOW(envelope: envelope)
        setLREnvelopeForNimbus(envelope: envelope)
        setLREnvelopeForPubmaticOW(envelope: envelope)
        // More partners coming soon!
        // Note: Google Ad Manager is a separate workflow.
        
        
    }
    
    
    // [PREBID] Set the updated RampID envelope in Prebid SDK (or managed Prebid Partner)
    // https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution#prebid-sdk
    // https://docs.prebid.org/prebid-mobile/pbm-api/ios/pbm-targeting-ios.html#user-identity-api
    // This ensures all subsequent ad requests to Prebid Server contain the RampID envelope.
    func setLREnvelopeForPrebid(envelope: String) {
        
        var externalUserIdArray = [ExternalUserId]()
        externalUserIdArray.append(
            ExternalUserId(source: "liveramp.com", identifier: envelope))
        
        Prebid.shared.externalUserIdArray = externalUserIdArray
        
        // TODO: Do a sample Prebid ad request to validate
    }
    
    
    // [InMobi UnifId] Set the updated RampID envelope in InMobi's UnifID service
    // https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution#inmobi
    // https://support.inmobi.com/monetize/data-identity/unifid/unifid-sdk-contract-specifications#unifid-api-specification
    // This ensures all subsequent ad requests to InMobi's exchange contain the RampID envelope.
    func setLREnvelopeForInMobi(envelope: String) {
        
        var idDictionary = ["liveramp.com": envelope]
        IMSdk.self.setPublisherProvidedUnifiedId(idDictionary)
        
        // TODO: Do a sample InMobi ad request to validate
    }
    
    
    // [Pubmatic OW] Set the updated RampID envelope in Pubmatic's OW server
    // https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution#pubmatic
    // https://community.pubmatic.com/display/IOPO/Advanced+topics#Advancedtopics-UserIdentity(DataPartnerIDs)
    // This ensures all subsequent ad requests to Pubmatic OpenWrap contain the RampID envelope.
    func setLREnvelopeForPubmaticOW(envelope: String){
        
        var userId = POBExternalUserId(source: "liveramp.com", andId: envelope)
        OpenWrapSDK.addExternalUserId(userId)
        
        // TODO: Do a sample OpenWrap ad request to validate
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
        
        MobileFuseTargetingData.setLiveRampEnvelope(envelope)
        
        // TODO: Do a sample MF ad request to validate
    
    }

    
    
    // Other misc code to make this application run
    @IBAction func touchInitSDK(_ sender: Any) {
        self.initializeATSSDK();
    }
    
    
    @IBAction func touchFetchEnvelope(_ sender: Any) {
        let emailValue = label_emailValue.text;
        fetchEnvelopeForEmail(email: emailValue ?? "test@liveramp.com");
    }
    
    
    @IBAction func touchResetSDK(_ sender: Any) {
        LRAts.shared.resetSDK()
        updateSDKInitStatus(isInitialized: false)
        print("SDK Reset")
    }
    
    
    
    @IBAction func touchClearAll(_ sender: Any) {
        DispatchQueue.main.async {
            self.updateErrMessage(errMsg: "")
            self.label_envelopeValue.text = ""
            self.label_emailValue.text = ""
        }
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

