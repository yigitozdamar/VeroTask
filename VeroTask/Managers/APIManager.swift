//
//  Service.swift
//  VeroTask
//
//  Created by Yigit Ozdamar on 23.03.2023.
//

import Foundation
import SwiftyJSON
import RealmSwift

class APIManager {
    
    static let shared = APIManager()
    
    func authenticateUser(username: String, password: String, completion: @escaping (Bool) -> Void) {
        callingAuthAPI(username: username, password: password) { accessToken in
            if !accessToken.isEmpty {
                UserDefaults.standard.setAccessToken(accessToken)
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func callingAuthAPI(username: String = "365", password: String = "1", completion: @escaping (String)-> Void) {
        
        //In case of basic Oauth token changes use base64LoginString
//        let loginString = String(format: "%@:%@", username, password)
//        let loginData = loginString.data(using: String.Encoding.utf8)!
//        let base64LoginString = loginData.base64EncodedString()
        
        let headers = [
            "Authorization": "Basic QVBJX0V4cGxvcmVyOjEyMzQ1NmlzQUxhbWVQYXNz",
            "Content-Type": "application/json"
        ]
        let parameters = [
            "username": "\(username)",
            "password": "\(password)"
        ] as [String : Any]
        
        let postData = try! JSONSerialization.data(withJSONObject: parameters, options: [])
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://api.baubuddy.de/index.php/login")! as URL,
                                          cachePolicy: .reloadRevalidatingCacheData,
                                          timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = headers
        request.httpBody = postData as Data
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if let error {
                print(error.localizedDescription)
            } else if let data = data,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200 {
                
                    if let json = try? JSON(data: data) {
                        DispatchQueue.main.async {
                            let accessToken = json["oauth"]["access_token"].stringValue
                            print("Access Token: \(accessToken)")
                            completion(accessToken)
                            UserDefaults.standard.setAccessToken(accessToken)
                        }
                    }
                
            } else {
                print("Unexpected response: \(response.debugDescription)")
            }
           
        })
        
        dataTask.resume()

    }
    
    func requestUrl(accessToken: String, completion: @escaping (Results<PersonTaskRM>) -> Void) {
        
        let url = URL(string: "https://api.baubuddy.de/dev/index.php/v1/tasks/select")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200 {
                // Success! Parse the JSON response data
                let json = try? JSON(data: data)
                print(json)
                DispatchQueue.main.async {
                    let realm = try! Realm()
                    try! realm.write {
                        // Check if data already exists in Realm
                        let existingTasks = realm.objects(PersonTaskRM.self)
                        let existingTaskNames = existingTasks.map { $0.task }
                        
                        for row in json!.arrayValue {
                            let taskRow = PersonTaskRM()
                            taskRow.task = try! row["task"].stringValue.strippingHTML() ?? ""
                            taskRow.color = try! row["colorCode"].stringValue.strippingHTML() ?? ""
                            taskRow.descriptions = try! row["description"].stringValue.strippingHTML() ?? ""
                            taskRow.title = try! row["title"].stringValue.strippingHTML() ?? ""
                            
                            if !existingTaskNames.contains(taskRow.task) {
                                realm.add(taskRow)
                            }
                        }
                        
                        let tasks = realm.objects(PersonTaskRM.self)
                        completion(tasks)
                    }
                }
            } else {
                print("Unexpected response: \(String(describing: response))")
            }
        }
        
        task.resume()
    }


}
