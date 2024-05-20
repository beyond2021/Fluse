//
//  Utils.swift
//  Fluse
//
//  Created by KEEVIN MITCHELL on 5/9/24.
//

import Foundation

struct Utils {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter
    }() // () for initilization
    
    
    static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.isLenient = true //
        formatter.numberStyle = .currency
        return formatter
    }()
}
