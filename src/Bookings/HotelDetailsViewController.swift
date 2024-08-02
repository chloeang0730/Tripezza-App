//
//  HotelDetailsViewController.swift
//  Tripezza
//
//  Created by Chloe Ang on 17/05/2023.
//
//  This is the view controller where the user can check the details of the hotel.

import UIKit
import CoreData

class HotelDetailsViewController: UIViewController{

    @IBOutlet weak var hotelNameDetails: UILabel!
    @IBOutlet weak var hotelRating: UILabel!
    @IBOutlet weak var hotelVicinity: UILabel!
    @IBOutlet weak var hotelBusinessStatus: UILabel!
    
    weak var TripDatabaseController: TripDatabaseProtocol?
       
    
    var selectedHotel: HotelData?
    var managedObjectContext: NSManagedObjectContext!
    var persistentContainer: NSPersistentContainer?
    
    
    
    
    init() {
    
        self.persistentContainer = NSPersistentContainer(name: "TripModel")
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    
    // the view controller will display the name, rating, vicinity and business status of the hotel.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hotelNameDetails.text = selectedHotel?.name
        if let rating = selectedHotel?.rating {
            hotelRating.text = String(rating)
        } else {
            hotelRating.text = "N/A"
        }
        hotelVicinity.text = selectedHotel?.vicinity
        hotelBusinessStatus.text = selectedHotel?.business_status
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        
        
        // Other setup code
        
        
        
        
    }
    // this function is do save the hotel data to core data and the data will be retrieved on bookinglist view controller
    // if the user has interest to book this hotel, he/she may add the hotel to the favourite booking list
    @IBAction func saveButtonTapped(_ sender: UIButton) {
    
        guard let hotelName = hotelNameDetails.text,
                let hotelBusinessStatus = hotelBusinessStatus.text,
                let hotelVicinity = hotelVicinity.text,
                  let hotelRating = Double(hotelRating.text!)
        else {
                // Handle validation or input error
                return
            }
        // check if tripmodel exist and load it
        guard let modelURL = Bundle.main.url(forResource: "TripModel", withExtension: "momd"),
                      let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
                    fatalError("Unable to initialize managed object model")
                }
        let persistentContainer = NSPersistentContainer(name: "TripModel", managedObjectModel: managedObjectModel)
               persistentContainer.loadPersistentStores { (_, error) in
                   if let error = error {
                       fatalError("Failed to load persistent store: \(error)")
                   }
               }

        let managedContext = persistentContainer.viewContext
        
        // create a hotel instance
        let newHotel = Hotel2(context: managedContext)
        newHotel.name = hotelName
        newHotel.vicinity = hotelVicinity
        newHotel.rating = hotelRating
        newHotel.businessStatus = hotelBusinessStatus
            
        // Save the changes to the Core Data persistent store
        do {
            try persistentContainer.viewContext.save()
                
        // Error handling for saving the hotel details
        } catch {
            
                print("Failed to save hotel details: \(error)")
        }
        self.displayMessage(message: "Added to Favourite list")

    }
    func displayMessage(message: String){
        let alertController = UIAlertController(title:title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style:.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    


}
