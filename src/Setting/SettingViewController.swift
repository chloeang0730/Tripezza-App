//
//  SettingViewController.swift
//  Tripezza
//
//  Created by Chloe Ang on 15/05/2023.
//
//  This view controller is the setting screen.
//  There is a sign out button where user can sign out the app with that.
//

import UIKit
import FirebaseAuth
import Firebase
class SettingViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    
    var authController: Auth?
    var authStateListener: AuthStateDidChangeListenerHandle?
    weak var databaseController: DatabaseProtocol?

    @IBOutlet weak var secondTableView: UITableView!
    @IBOutlet weak var firstTableView: UITableView!
    
    // this function will sign the user out
    @IBAction func signOutButton(_ sender: Any) {
        Task{
            do {
                try Auth.auth().signOut()
                if let tabBarController = self.tabBarController,
                           let navigationController = tabBarController.navigationController {
                            navigationController.popToRootViewController(animated: true)
                        }
                
            } catch {
                print("Log out error: \(error.localizedDescription)")
            }
        }
        
    }
    @IBOutlet weak var SignOutButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // Make firstTableView edges rounded
            firstTableView.layer.cornerRadius = 10
            firstTableView.layer.masksToBounds = true
            
            // Make secondTableView edges rounded
            secondTableView.layer.cornerRadius = 10
            secondTableView.layer.masksToBounds = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == firstTableView {return 1}
        else {return 3}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == firstTableView {
            // Configure cells for the first table view
            let cell = tableView.dequeueReusableCell(withIdentifier: "PersonalCell", for: indexPath)
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Username: John Doe"
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        } else if tableView == secondTableView {
            // Configure cells for the second table view
            let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
            
            if indexPath.row == 0 {
                cell.textLabel?.text = "Notification Setting"
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Help Centre"
            } else if indexPath.row == 2 {
                cell.textLabel?.text = "User Agreement"
            }
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        // Default return statement
        return UITableViewCell()
    }



}
