//
//  Acronym.swift
//  Acronyms
//
//  Created by Developer on 3/23/17.
//  Copyright © 2017 Zubair. All rights reserved.
//

import Foundation

class Meaning {
    var abbreviation: String
    var longForm: String
    
    init(abbreviation : String, longForm : String) {
        self.abbreviation = abbreviation
        self.longForm = longForm
    }
}
