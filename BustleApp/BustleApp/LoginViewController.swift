/**
 * Copyright IBM Corporation 2016
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
 **/

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var signinButton: CustomButton!
    @IBOutlet weak var statusLabel: UILabel!
    var connected: Bool?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func loginButton(sender: UIButton) {
        if self.connected == true {
            self.performSegue(withIdentifier: "todolist", sender: self)
        }
        else {
            connectToServer()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThemeManager.applyTheme(theme: ThemeManager.currentTheme())
        ThemeManager.replaceGradient(inView: self.view)
        connectToServer()
        
    }
    
    func connectToServer() {
        self.signinButton.isEnabled = false
        TodoItemDataManager.sharedInstance.hasConnection {
            hasConnection in
            
            DispatchQueue.main.async {
                if hasConnection == false {
                    self.signinButton.setTitle("Try again", for: UIControlState.normal)
                    let serverURL = TodoItemDataManager.sharedInstance.getBaseRequestURL()
                    self.statusLabel.text = "Could not connect to \(serverURL)"
                    self.connected = false
                }
                else {
                    self.signinButton.setTitle("Sign in", for: UIControlState.normal)
                    self.statusLabel.text = ""
                    self.connected = true
                }
                self.signinButton.isEnabled = true
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        view.layer.sublayers?.first?.frame = self.view.bounds
    }
}
