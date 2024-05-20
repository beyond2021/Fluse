//
//  Sort.swift
//  Fluse
//
//  Created by KEEVIN MITCHELL on 5/9/24.
//

import Foundation
enum SortType: String, Identifiable, CaseIterable {
    var id: Self { self }
    case date, amount, name
    var systemImageIcon: String {
        switch self {
            
        case .date:
            return "calendar"
        case .amount:
            return "dollarsign.circle"
        case .name:
            return "a"
        }
    }
}

// Could have used a Boolean instaed of enum because of only 2 of them
enum SortOrder: String, Identifiable, CaseIterable {
    var id: Self { self }
    case ascending, descending
}
