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

class LoginViewController: UIViewController {
        
    @IBOutlet weak var currentYear: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rememberMe: UISwitch!
    @IBOutlet weak var remainingAttempts: UILabel!
    @IBOutlet weak var error: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.username.text = ""
        self.password.text = ""
        rememberMe.isOn = false
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        self.currentYear.text = "©\(appDelegate.currentYear) Persistent System"
        NotificationCenter.default.addObserver(self, selector: #selector(updateLabels(_:)), name: NSNotification.Name(rawValue: LoginRequiredNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loginSuccess), name: NSNotification.Name(rawValue: LoginSuccessNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loginFailure(_:)), name: NSNotification.Name(rawValue: LoginFailureNotificationKey), object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func login(_ sender: UIButton) {
        if(self.username.text != "" && self.password.text != ""){
            print("Login view Remember me \(rememberMe.isOn)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: LoginNotificationKey), object: nil, userInfo: ["username": username.text!, "password": password.text!, "rememberMe": rememberMe.isOn])
        } else {
            self.error.text = "Username and password are required"
        }
    }
    
    //(triggered by LoginRequired notification)
    @objc func updateLabels(_ notification:Notification){
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject?>
        let errMsg = userInfo["errorMsg"] as! String
        let remainingAttempts = userInfo["remainingAttempts"] as! Int
        self.error.text = errMsg
        self.remainingAttempts.text = "Remaining Attempts: " + String(remainingAttempts)
    }
    
    //(triggered by LoginSuccess notification)
    @objc func loginSuccess(){
        
        
     _   =    self.navigationController?.popViewController(animated: true)
    }
    
    //(triggered by LoginFailure notification)
    @objc func loginFailure(_ notification:Notification){
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject?>
        let errMsg = userInfo["errorMsg"] as! String
        
        let alert = UIAlertController(title: "Error",
            message: errMsg,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
        self.username.text = ""
        self.password.text = ""
        self.remainingAttempts.text = ""
        self.error.text = ""
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("LoginViewController: viewDidDisappear")
        NotificationCenter.default.removeObserver(self)
    }
    
}
