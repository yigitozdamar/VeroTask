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
        navigationItem.hidesBackButton = true
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toHomeVC" {
            guard let homeVC = segue.destination as? HomeViewController else { return  }
            homeVC.tasks = personTask
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        if let usernameText = username.text, let passwordText = password.text {
            
            APIManager.shared.authenticateUser(username: usernameText, password: passwordText) { success,message  in
                
                DispatchQueue.main.async {
                    if success {
                        APIManager.shared.requestUrl(accessToken: UserDefaults.standard.getAccessToken()!) { [weak self] personTaskRM in
                            self?.personTask = personTaskRM
                            self?.performSegue(withIdentifier: "toHomeVC", sender: nil)
                            
                        }
                        
                    }else {
                        print(message,"YIGIT")
                        guard let errorMessage = message else { return }
                        let alert = UIAlertController(title: errorMessage, message: "Invalid username or password", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                        
                    }
                }
                
           
            }
            
        }
    }
}


