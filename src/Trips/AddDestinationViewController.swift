//
//  AddDestinationViewController.swift
//  Tripezza
//
//  Created by Chloe Ang on 01/05/2023.
//
//  This view controller used to add destination into the itinerary.
//
import UIKit

class AddDestinationViewController: UIViewController{


    @IBOutlet weak var startDateTextField: UITextField!
    @IBOutlet weak var destinationTextField: UITextField!
    @IBOutlet weak var endDateTextField: UITextField!
    weak var tripDatabaseController: TripDatabaseProtocol?
    var currentTrip: Trip?
    var notification = NotificationTableTableViewController()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let appDelegate = UIApplication.shared.delegate as?AppDelegate
        tripDatabaseController = appDelegate?.tripDatabaseController
    }
    
    // MARK: - IBActions
    
    // this function saves the information after the user enters the destination information
    // it will validate it, and updates the itinerary
    @IBAction func saveButton(_ sender: Any) {
        guard let startDate  = startDateTextField.text, let endDate = endDateTextField.text, let destination = destinationTextField.text else {
            return
        }
        if destination.isEmpty || startDateTextField.text?.isEmpty ?? true || endDateTextField.text?.isEmpty ?? true {
            var errorMsg = "Please ensure all fields are filled in:\n"
            
            if destination.isEmpty {
                errorMsg += "- Must provide a destination\n"
            }
            if startDateTextField.text?.isEmpty ?? true {
                errorMsg += "- Must provide a start date\n"
            }
            if endDateTextField.text?.isEmpty ?? true {
                errorMsg += "- Must provide an end date\n"
            }
            
            displayMessage(title: "Not all fields filled", message: errorMsg)
            return
        }

        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        guard let startDate = dateFormatter.date(from: startDate),let endDate = dateFormatter.date(from: endDate)
        else {
            displayMessage(title: "Invalid Date Format", message: "Please enter dates in the format yyyy-MM-dd")
            return
        }
        
        let _ = tripDatabaseController?.addDestination(destination: destination, startDate: startDate, endDate: endDate,trip:tripDatabaseController!.currentTrip!)
        
        navigationController?.popViewController(animated: true)
    }
    
    // this function display an error message
    func displayMessage(title: String, message: String){
        let alertController = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    

}
