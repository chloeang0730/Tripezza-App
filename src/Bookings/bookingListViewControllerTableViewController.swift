//
//  bookingListViewControllerTableViewController.swift
//  Tripezza
//
//  Created by Chloe Ang on 11/05/2023.
//
//  This is the view controller that show alls the hotels that the users intended to book.
//  When the user click on the save to favourite button, the data of the hotel appears on this page.
//
//
import UIKit
import CoreData

class bookingListViewControllerTableViewController: UITableViewController ,NSFetchedResultsControllerDelegate{
    
    var fetchedResultsController: NSFetchedResultsController<Hotel2>!
    var persistentContainer: NSPersistentContainer?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    init() {
        self.persistentContainer = NSPersistentContainer(name: "TripModel")
        super.init(style: .plain)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    override func viewDidAppear(_ animated: Bool) {
        // Initialize Core Data managed object context
        // Set up the fetched results controller
        let fetchRequest: NSFetchRequest<Hotel2> = Hotel2.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        guard let modelURL = Bundle.main.url(forResource: "TripModel", withExtension: "momd"),
              let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Unable to initialize managed object model")
        }
        let persistentContainer = NSPersistentContainer(name: "TripModel")
        persistentContainer.loadPersistentStores { (_, error) in
            if let error = error {
                fatalError("Failed to load persistent stores: \(error)")
            }
        }
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
        managedObjectContext: persistentContainer.viewContext,sectionNameKeyPath: nil,cacheName: nil)
        fetchedResultsController.delegate = self
        super.viewDidAppear(animated)
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch Request Failed: \(error)")
        }
    }
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController?.fetchedObjects?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookingCell", for: indexPath)
        if let hotel = fetchedResultsController.fetchedObjects?[indexPath.row] {
            cell.textLabel?.text = hotel.name
        }
        
        return cell
    }
    // this function handle deletion of the row of notification
    // it helps to delete the data in the core data also
    override func tableView(_ tableView: UITableView,commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            fetchedResultsController.delegate = self
            let fetchRequest: NSFetchRequest<Hotel2> = Hotel2.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            guard let modelURL = Bundle.main.url(forResource: "TripModel", withExtension: "momd"),
                  let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
                fatalError("Unable to initialize managed object model")
            }
            let persistentContainer = NSPersistentContainer(name: "TripModel")
            if let hotel = fetchedResultsController.fetchedObjects?[indexPath.row] {
                fetchedResultsController.managedObjectContext.delete(hotel)
                    
                        do {
                            try fetchedResultsController.managedObjectContext.save()
                    
                        } catch {
                            print("Failed to delete hotel: \(error)")
                        }
            }
        }
    }
    // handle the changes in the fetched result controller
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            tableView.reloadData()
        }
     
        
}

