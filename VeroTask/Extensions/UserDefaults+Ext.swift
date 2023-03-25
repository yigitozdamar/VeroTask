//
//  UserDefaults.swift
//  VeroTask
//
//  Created by Yigit Ozdamar on 24.03.2023.
//

import Foundation

extension UserDefaults {
    func setAccessToken(_ accessToken: String) {
        set(accessToken, forKey: "accessToken")
    }
    
    func getAccessToken() -> String? {
        return string(forKey: "accessToken")
    }
}
