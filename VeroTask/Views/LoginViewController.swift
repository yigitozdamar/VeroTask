//
//  ViewController.swift
//  VeroTask
//
//  Created by Yigit Ozdamar on 23.03.2023.
//

import UIKit
import RealmSwift

class LoginViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    var personTask: Results<PersonTaskRM>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHomeVC" {
            guard let homeVC = segue.destination as? HomeViewController else { return  }
            homeVC.tasks = personTask
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if let usernameText = username.text, let passwordText = password.text {
            
            APIManager.shared.authenticateUser(username: usernameText, password: passwordText) { success in
                if success {
                    APIManager.shared.requestUrl(accessToken: UserDefaults.standard.getAccessToken()!) { [weak self] personTaskRM in
                        self?.personTask = personTaskRM
                        self?.performSegue(withIdentifier: "toHomeVC", sender: nil)
                    }
                }
            }
            
        }
    }
}


