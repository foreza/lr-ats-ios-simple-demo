//
//  ViewController.swift
//  LiveRamp ATS SDK - Simple Demo
//
//  Created by Jason Chiu on 4/1/22.
//

import UIKit
import AppTrackingTransparency
import LRAtsSDK


class ViewController: UIViewController {

    
    // View references
    @IBOutlet weak var label_sdkversion: UILabel!
    @IBOutlet weak var label_sdkinitstatus: UILabel!
    @IBOutlet weak var label_errMessage: UILabel!
    
    @IBOutlet weak var label_envelopeValue: UILabel!
    @IBOutlet weak var label_emailValue: UITextField!
    
    // TODO: Replace the init appID with your own app ID
    // DO NOT use this in production - it will cause you monetization issues.
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
        let tcfString = "CPKZ42oPKZ5YtADABCENBlCgAP_AAAAAAAAAAwwAQAwgDDABADCAAA.YAAAAAAAA4AA"
        let expectedPurposesConsent = "1111111111"
        let expectedVendorsConsent = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
        let ccpaString = "1YNY"
        
        // Required for GDPR if EU
         UserDefaults.standard.set(tcfString, forKey: "IABTCF_TCString")
         UserDefaults.standard.set(expectedPurposesConsent, forKey: "IABTCF_PurposeConsents")
         UserDefaults.standard.set(expectedVendorsConsent, forKey: "IABTCF_VendorConsents")
        
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
            
            var displayString = ""
        
            
            // Example of how to use envelopes for advertising use cases:
            if let lr_envelope: String = result?.envelope {
                print("RampID Envelope: \(lr_envelope)")
                
                // TODO: Now, provide the lr_envelope value to your partner(s).
                // This value expires - by calling `getEnvelope`, you will ensure this value remains relevant.
                // Do NOT cache this value. It will not be valuable or useful!
                // You should always be using the most up to date envelope with downstream partners.
                // More documentation here: https://developers.liveramp.com/authenticatedtraffic-api/docs/configure-programmatic-ad-solution
                
                // self.setLREnvelopeForPartnerSDKs(envelope: lr_envelope)
                
                displayString += "lr_envelope: \(self.formatStringForDisplay(originalString: lr_envelope))"
                self.updateErrMessage(errMsg: "")
            }
            
            
            // If you are enabled for PairIDs:
            if let pair_envelope: String = result?.envelope25 {
                print("Encoded PairIDs: \(pair_envelope)")
                displayString += "pair_envelope: \(self.formatStringForDisplay(originalString: pair_envelope))"
                // self.setPairIDsForPartnerSDKs(envelope: pair_envelope)
            } else {
                print("No PairIDs returned")
            }
            
            self.updateDisplayString(envelopeString: displayString)
        }
        
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
