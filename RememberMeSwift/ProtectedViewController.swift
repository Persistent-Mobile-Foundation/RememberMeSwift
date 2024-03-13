/**
 * Copyright 2016 IBM Corp.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit
import IBMMobileFirstPlatformFoundation

class ProtectedViewController: UIViewController {
    
    @IBOutlet weak var currentYear: UILabel!
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var helloUserLabel: UILabel!
    @IBOutlet weak var displayBalanceLabel: UILabel!
    @IBOutlet weak var getBalanceBtn: UIButton!
    @IBOutlet weak var logoutBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WLAuthorizationManager.sharedInstance().obtainAccessToken(forScope: "UserLogin") { (token, error) -> Void in
            if(error != nil){
                print("obtainAccessToken failed! \(String(describing: error))")
            }
            else{
                print("obtainAccessToken success")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        NotificationCenter.default.addObserver(self, selector: #selector(showLoginScreen(_:)), name: NSNotification.Name(rawValue: LoginRequiredNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshUI), name: NSNotification.Name(rawValue: LoginSuccessNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLoginScreen(_:)), name: NSNotification.Name(rawValue: LoginFailureNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLoginScreen(_:)), name: NSNotification.Name(rawValue: logoutSuccessNotificationKey), object: nil)
     
  //        NotificationCenter.default.addObserver(self, selector: #selector(showLoginScreen(_:)), name: NSNotification.Name(rawValue: RemembermeFalseNotification), object: nil)
        refreshUI()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.currentYear.text = "©\(appDelegate.currentYear) Persistent System"
    }
    
    @objc func refreshUI(){
        print("refreshUI")
        
       
        if let displayName = defaults.string(forKey: "displayName"){
            self.getBalanceBtn.isHidden = false
            self.logoutBtn.isHidden = false
            self.helloUserLabel.isHidden = false
            self.helloUserLabel.text = "Hello, " + displayName
            self.displayBalanceLabel.text = ""
        }
    }
    
    @IBAction func getBalanceClicked(_ sender: UIButton) {
        let url = URL(string: "/adapters/ResourceAdapter/balance");
        let request = WLResourceRequest(url: url, method: WLHttpMethodGet);
        request?.send{ (response, error) -> Void in
            if(error != nil){
                NSLog("Failed to get balance. error: " + String(describing: error))
                self.displayBalanceLabel.text = "Failed to get balance...";
            }
            else if(response != nil){
                self.displayBalanceLabel.text = "Balance: " + (response?.responseText)!;
            }
        }
    }
    
    @IBAction func logoutClicked(_ sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: LogoutNotificationKey), object: nil)
    }
    
    @objc func showLoginScreen(_ notification:Notification){
        
        print("showLoginScreen")
        self.performSegue(withIdentifier: "ShowLoginScreen", sender: self)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
}
