//
//  signInViewController.swift
//  Tripezza
//
//  Created by Chloe Ang on 30/04/2023.
//
//  This is the sign in page, if the user does not have an account, they can create an account here.
//  The app will check if the user exist or not through email because email is unique for everyone.

import UIKit
import FirebaseAuth
import Firebase

class signInViewController: UIViewController {
    
    var authController: Auth?
    var authStateListener:AuthStateDidChangeListenerHandle?
    weak var databaseController: DatabaseProtocol?
    
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        databaseController = appDelegate?.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        guard let authHandle = authStateListener else { return }
        Auth.auth().removeStateDidChangeListener(authHandle)
    }
    
    // MARK: - IBActions
    
    // this function is to create an account in Tripezza
    // it will first check if the user email exists or not
    // if the user exists, the app will ask the user to key in another email
    // if not, it will create an account in the firebase
    // the user will need to go back to the log in page to go into the page
    @IBAction func createAccountButton(_ sender: Any) {
        guard let useremail = emailTextField.text else {
            displayMessage("Error", "Enter username")
            return
        }
        checkUserExists(userEmail: useremail) { exists in
            if exists {
                // Username already exists, display error message to user
                self.displayMessage("Opps! User already exists!", "Please enter another email.")
            } else {
                if self.validEntry() {
                    self.databaseController!.createNewUser(email: self.emailTextField!.text!, password: self.passwordTextField!.text!) {
                        // Successful login, perform segue to next page
                        
                        self.displayMessage("Success!", "User created! Go Back Login Page.")
                    }
                }
            }
        }
    }
    
    // this function check if the password entered by the user is valid or not
    func validEntry() -> Bool{
        var errorMessage: String = ""
        if passwordTextField.text == "" || passwordTextField.text!.count < 8 {
            errorMessage += "\nInvalid password\nPassword must have at least 8 characters"
        }
        
        if errorMessage != "" {
            displayMessage("Error Message", "Password must have at least 8 characters")
            return false
        } else {
            return true
        }
    }
    
    // this function check if any sign-in methods are associated with the email
    // if email does not exist in the identifier field, it will create an account
    // if email exists in the identifier field, it will tell that the user exists
    func checkUserExists(userEmail: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().fetchSignInMethods(forEmail: userEmail) { signInMethods, error in
            if let error = error {
                print("Error fetching sign-in methods: \(error.localizedDescription)")
                completion(false)
            }else if let signInMethods = signInMethods {
                if signInMethods.isEmpty {
                    
                    completion(false)
                } else {
                    completion(true)
                }
            } else {
                completion(false)
            }
        }
    }
    
    // this function display an error message with title and message
    func displayMessage(_ title:String,_ message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
