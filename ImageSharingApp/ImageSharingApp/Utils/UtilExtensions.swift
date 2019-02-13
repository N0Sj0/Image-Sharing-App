//
//  UtilExtensions.swift
//  ImageSharingApp
//
//  Created by Noah Sjöberg on 2019-01-21.
//  Copyright © 2019 Noah Sjöberg. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper


extension Character {
    var ascii: Int? {
        let ascii = Int(self.unicodeScalars.first?.value ?? 0)
        return (ascii == 0) ? nil : ascii
    }
}

extension String {
    
    // If string contains only english letters a-z or A-Z
    var containsInvalidCharacters: Bool {
        var containsInvalidCharacters = false
        for char in self {
            if let ascii = char.ascii {
                if !(CharacterConstants.lowercaseAAscii ... CharacterConstants.lowercaseZAscii ~= ascii), !(CharacterConstants.uppercaseAAscii ... CharacterConstants.uppercaseZAscii ~= ascii) {
                    containsInvalidCharacters = true
                    break
                }
            } else {
                containsInvalidCharacters = true
                break
            }
        }
        return containsInvalidCharacters
    }
    
}
