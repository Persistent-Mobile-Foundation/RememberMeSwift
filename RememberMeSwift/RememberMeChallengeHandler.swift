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

class RememberMeChallengeHandler: SecurityCheckChallengeHandler {
    
    var isChallenged: Bool
    let defaults = UserDefaults.standard
    let challengeHandlerName = "RememberMeChallengeHandler"
    let securityCheckName = "UserLogin"
    
    override init(){
        self.isChallenged = false
        super.init(securityCheck: "UserLogin")
        WLClient.sharedInstance().registerChallengeHandler(challengeHandler: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(login(_:)), name: NSNotification.Name(rawValue: LoginNotificationKey), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(logout), name: NSNotification.Name(rawValue: LogoutNotificationKey), object: nil)
    }
    
    override func handleChallenge(_ challenge: [AnyHashable: Any]!) {
        print("\(self.challengeHandlerName): handleChallenge - \(String(describing: challenge))")
        if (defaults.string(forKey: "displayName") != nil){
            defaults.removeObject(forKey: "displayName")
        }
        self.isChallenged = true
        var errMsg: String!
        
        if(challenge["errorMsg"] is NSNull){
            errMsg = ""
        } else {
            errMsg = challenge["errorMsg"] as? String
        }
        let remainingAttempts = challenge["remainingAttempts"]
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: LoginRequiredNotificationKey), object: nil, userInfo: ["errorMsg":errMsg!, "remainingAttempts":remainingAttempts!])
        
    }
    
    override func handleSuccess(_ success: [AnyHashable: Any]!) {
        print("\(self.challengeHandlerName): handleSuccess - \(String(describing: success))")
        self.isChallenged = false
        let user = success["user"]  as! [String:Any]
        let displayName = user["displayName"] as! String
        self.defaults.set(displayName , forKey: "displayName")
        NotificationCenter.default.post(name: Notification.Name(rawValue: LoginSuccessNotificationKey), object: nil)
    }
    
    override func handleFailure(_ failure: [AnyHashable: Any]!) {
        print("\(self.challengeHandlerName): handleFailure - \(failure)")
        if (defaults.string(forKey: "displayName") != nil){
            defaults.removeObject(forKey: "displayName")
        }
        self.isChallenged = false
        if let _ = failure["failure"] as? String {
            NotificationCenter.default.post(name: Notification.Name(rawValue: LoginFailureNotificationKey), object: nil, userInfo: ["errorMsg":failure["failure"]!])
        }
        else{
            NotificationCenter.default.post(name: Notification.Name(rawValue: LoginFailureNotificationKey), object: nil, userInfo: ["errorMsg":"Unknown error"])
        }
    }
    
    // (Triggered by Login Notification)
    @objc func login(_ notification:Notification){
        print("\(self.challengeHandlerName): login")
        let userInfo = notification.userInfo as! Dictionary<String, AnyObject?>
        let username = userInfo["username"] as! String
        let password = userInfo["password"] as! String
        let rememberMe = userInfo["rememberMe"] as! Bool
        
        // If challenged use submitChallengeAnswer API, else use login API
        if(!self.isChallenged){
            if(rememberMe==false)
            {
                print("FALSE REMEMBER MEEE")
            }
            WLAuthorizationManager.sharedInstance().login(self.securityCheckName, withCredentials: ["username": username, "password": password, "rememberMe": rememberMe]) { (error) -> Void in
                if(error != nil){
                    print("Login failed \(String(describing: error))")
                } else {
                    print("I am remebered- \(rememberMe)")
                    print("\(self.challengeHandlerName): preemptiveLogin success")
                }
            }
        }
        else{
            print("submitChallengeAnswer")
            print("I am remebered-- \(rememberMe)")
            self.submitChallengeAnswer(["username": username, "password": password, "rememberMe": rememberMe])
        }
    } 
        // (Triggered by Logout Notification)
    @objc func logout(){
        print("\(self.challengeHandlerName): logout")
        self.defaults.removeObject(forKey: "displayName")
        WLAuthorizationManager.sharedInstance().logout(self.securityCheckName){
            (error) -> Void in
            if(error != nil){
                
                print("Logout failed \(String(describing: error))")
            }
            print("\(self.challengeHandlerName): logout success")
            self.isChallenged = false
            NotificationCenter.default.post(name: Notification.Name(rawValue: logoutSuccessNotificationKey), object: nil)
        }
        
    }
}


