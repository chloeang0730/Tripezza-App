//
//  FirebaseController.swift
//  Tripezza
//
//  Created by Chloe Ang on 25/04/2023.
//
// this controller handle all the methods related to firebase

import UIKit
import Firebase
import FirebaseFirestoreSwift
import FirebaseAuth

class FirebaseController: NSObject,DatabaseProtocol {
   
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var successfulSignUp: Bool
    var authController: Auth
    var database: Firestore
    
    var usersRef: CollectionReference?

    
    override init() {
        FirebaseApp.configure()
        
        authController = Auth.auth()
        database = Firestore.firestore()
        successfulSignUp = false
        
        usersRef = database.collection("users")
        super.init()

        
    }
    // this function handle the sign in of user
    func signInUser(email: String, password: String, completion: @escaping () -> Void){
            authController.signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    // unsuccessful
                    print("Error signing in: \(String(describing: error))")
                } else {
                    // successful
                }
                completion() // call the completion handler after setupHeroListener is finished
            }
    }
    // this function handle signout of user
    func signOutUser(){
            do {
                try authController.signOut()
            }
            catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
            
    }
    // this function uses to create a new user
    func createNewUser(email: String, password: String, completion: @escaping () -> Void) {
            authController.createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    // unsuccessful
                    print("Error creating user: \(String(describing: error))")
                } else {
                    // successful
                    self.successfulSignUp = true
                
                    print("successfully signed up user")
                }
                completion() // call the completion handler after setupHeroListener is finished
            }
    }





    
}
