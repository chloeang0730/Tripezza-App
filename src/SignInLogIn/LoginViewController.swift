//
//  LoginViewController.swift
//  Tripezza
//
//  Created by Chloe Ang on 25/04/2023.
//
// This is the view controller of log in page of the app.
// If the user already has an account, they can just key in their email and password to access the app.
// If not, they will need to create a new account by clicking on the sign in button.


import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    var authController: Auth?
    var authStateListener: AuthStateDidChangeListenerHandle?
    weak var databaseController: DatabaseProtocol?

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            databaseController = appDelegate?.databaseController
            // Access authController
            authController = Auth.auth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        authStateListener = Auth.auth().addStateDidChangeListener() {
        (auth, user) in
            // If there is an authenticated user, then the app will straight go into the app
            guard user != nil else { return  }
            self.performSegue(withIdentifier: "LoginSegue", sender: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let authHandle = authStateListener else { return }
        Auth.auth().removeStateDidChangeListener(authStateListener!)
    }

    // MARK: - IBActions
    
    // log in button
    // the app will check whether the user exists or not
    @IBAction func LogInButton(_ sender: Any) {
        if self.validEntry() {
            databaseController!.signInUser(email: emailTextField.text!, password: passwordTextField.text!) {
                if self.authController?.currentUser != nil {
                            // unsuccessful login
                    self.displayMessage("Successful Login","Welcome to Tripezza!")
                    
                    } else {
                    self.displayMessage("Opps!User not exist!","Sign in to create account!")
                        
                    }
                }
        }

    }
    // sign in button
    // this button will perform segue to the sign in page
    @IBAction func SignInButton(_ sender: Any) {
        

    }
    // this function check whether the entry is valid or not
    func validEntry() -> Bool{
            var errorMessage: String = ""
            if passwordTextField.text == "" || passwordTextField.text!.count < 8 {
                errorMessage += "\nInvalid password\nPassword must have at least 8 characters"
            }
            
            if errorMessage != "" {
                return false
            } else {
                return true
            }
    }
    // this function display an error message with title and message
    func displayMessage(_ title: String,_ message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    



}
