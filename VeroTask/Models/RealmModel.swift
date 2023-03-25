//
//  RealmModel.swift
//  VeroTask
//
//  Created by Yigit Ozdamar on 24.03.2023.
//

import Foundation
import RealmSwift

class PersonTaskRM: Object {
    @Persisted var id: String = UUID().uuidString
    @Persisted var task: String = ""
    @Persisted var title: String = ""
    @Persisted var descriptions: String = ""
    @Persisted var color: String = ""
}
