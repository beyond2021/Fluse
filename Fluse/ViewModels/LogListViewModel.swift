//
//  LogListViewModel.swift
//  Fluse
//
//  Created by KEEVIN MITCHELL on 5/11/24.
// Represents the state of the expense List

import FirebaseFirestore
import Foundation
import Observation

@Observable

class LogListViewModel {
    let db = DatabaseManager.shared
    var sortType: SortType = .date
    var sortOrder: SortOrder = .descending
    var selectedCategories = Set<Category>() // ENUM
    
    //add or edit from sheet
    //add
    var isLogFormPresented = false
    var logToEdit: ExpenseLog?
    
    var predicates: [QueryPredicate] {
        var predicates = [QueryPredicate]()
        if selectedCategories.count > 0 {
            predicates.append(.whereField("category", isIn: Array(selectedCategories).map {$0.rawValue}))
//            predicates.append(.whereField("category", isIn: [Category.food.rawValue]))
        }
        predicates.append(.order(by: sortType.rawValue, descending: sortOrder == .descending ? true : false))
        return predicates
    }
}
