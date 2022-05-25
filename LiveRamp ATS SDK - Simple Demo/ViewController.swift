//
//  ViewController.swift
//  LiveRamp ATS SDK - Simple Demo
//
//  Created by Jason Chiu on 4/1/22.
//

import UIKit
import LRAtsSDK

class ViewController: UIViewController {

    
    // View references
    @IBOutlet weak var label_sdkversion: UILabel!
    @IBOutlet weak var label_sdkinitstatus: UILabel!
    @IBOutlet weak var label_errMessage: UILabel!
    
    @IBOutlet weak var label_envelopeValue: UILabel!
    @IBOutlet weak var label_emailValue: UITextField!
    
    // TODO: Replace the init appID with your own app ID before you go into production
    // let appId = "24f06669-7cc1-4650-b6e3-0ef1ad9d8346"
    let appId = "1be7d320-3a62-4170-8633-30b38114d8fc"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeHideKeyboard();            // It's 2022. Yet, here we are still.
        updateSDKVersionLabel();             // This (very important) API will be available in a future version.
        updateSDKInitStatus(isInitialized: false);
        updateErrMessage(errMsg: "");
        
        
        // initializeATSSDK();
        // setTestConsent();           // To enable ease of testing. Ensure consent is set before initializing the LR ATS SDK
    }
    
    
    // Strictly TEST consent values - to be only used for testing!
    func setTestConsent() {
        
        // Your CMP SDK should be responsible for setting these values.
        let tcfString = "CPKZ42oPKZ5YtADABCENBlCgAP_AAAAAAAAAAwwAQAwgDDABADCAAA.YAAAAAAAA4AA"
        let expectedPurposesConsent = "1111111111"
        let expectedVendorsConsent = "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001"
        let ccpaString = "1YNN"
        
        // Required for GDPR if EU
        UserDefaults.standard.set(tcfString, forKey: "IABTCF_TCString")
        UserDefaults.standard.set(expectedPurposesConsent, forKey: "IABTCF_PurposeConsents")
        UserDefaults.standard.set(expectedVendorsConsent, forKey: "IABTCF_VendorConsents")
        
        // Required for CCPA if US
        UserDefaults.standard.set(ccpaString, forKey:"IABUSPrivacy_String");
    }
    
    
    func initializeATSSDK() {
        
        // Example workflow for how you determine whether you invoke hasConsentForNoLegislation
        let doNotRequireCCPACheckInUS = true;
        let supportOtherGeos = true;                // For handling initialization in a country that isn't US or EU
        
        if (doNotRequireCCPACheckInUS || supportOtherGeos) {
            LRAts.shared.hasConsentForNoLegislation = true;
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
                let errString = "Couldn't retrieve envelope. Error: \(error)"
                self.updateErrMessage(errMsg: errString)
                print(errString)
                return;
            }
            
            let envelope = result?.envelope
            self.updateEnvelopeString(envelopeString: "\(envelope)")
            self.updateErrMessage(errMsg: "");
            print("Received envelope: \(envelope)")
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
    
    
    func updateEnvelopeString(envelopeString: String) {
        DispatchQueue.main.async {
            self.label_envelopeValue.self.text = envelopeString;
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

