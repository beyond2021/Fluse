//
//  DatabaseManager.swift
//  Fluse
//
//  Created by KEEVIN MITCHELL on 5/11/24.
// Singleton
/*
 Singleton Pattern: The most common use of a private initializer is in implementing the Singleton pattern. By making the initializer private and providing a static instance of the class, you ensure that only one instance of the class can exist throughout the application. This is particularly useful for managing global state or controlling access to a resource that is shared across various parts of an application.
 () -> passing something
 */
// This class interfaces with Firebase Database: CRUD
import FirebaseFirestore
import Foundation
class DatabaseManager {
    static let shared = DatabaseManager()
    private init() {}
    private (set) lazy var logsCollection : CollectionReference = {
        Firestore.firestore().collection("logs")
    }()
    //MARK: CRUD
    func add(log: ExpenseLog) throws {
        // we will generate the document at client side// on the device
        try logsCollection.document(log.id).setData(from: log)
    }
    func update(log: ExpenseLog) {
        logsCollection.document(log.id).updateData([
            "name": log.name,
            "amount": log.amount,
            "category": log.category,
            "date": log.date
        ])
    }
    func delete(log: ExpenseLog) {
        logsCollection.document(log.id).delete()
    }
    
}
