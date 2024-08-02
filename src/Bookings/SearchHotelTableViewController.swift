//
//  SearchHotelTableViewController.swift
//  Tripezza
//
//  Created by Chloe Ang on 14/05/2023.
//
//  This is the view controller where the user can search for the hotels.
//  There can key in the prefix of hotel name and it will list out the hotel that starts with the prefix.
//  Then the user can click on the hotel and it will go to the hotel details page.
//  from the hotel details page, the user can add the hotel to the favourite list if they are interested in this hotel

import UIKit

class SearchHotelTableViewController: UITableViewController ,UISearchBarDelegate{
    
    let CELL_HOTEL = "hotelCell"
    var requestString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-37.8136,144.9631&radius=5000000&type=lodging&key=AIzaSyA6o9s0UpViHZ4q0eEFk7KDDS5YkGoaSwg"
    
    var newHotels = [HotelData]()
    var indicator = UIActivityIndicatorView()
    var currentRequestIndex: Int = 0
    let MAX_ITEMS_PER_REQUEST = 20
    let MAX_REQUESTS = 4
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchBar.showsCancelButton = false
        navigationItem.searchController = searchController
        
        // Ensure the search bar is always visible.
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // shows the indicator
        indicator.style = UIActivityIndicatorView.Style.large
        indicator.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo:view.safeAreaLayoutGuide.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo:view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    // this function perform an asynchronous network request to the Google Places API to retrieve information about hotels with a given name.
    // it will handle the pagination and update the UI accordingly
    func requestHotelsNamed(_ hotelName: String,nextPageToken: String? = nil,iteration:Int = 1) async {
        
        guard let queryString = hotelName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)else{
            print("Query String can't be encoded")
            return
        }
        var requestString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-37.8136,144.9631&radius=5000000&type=lodging&key=AIzaSyA6o9s0UpViHZ4q0eEFk7KDDS5YkGoaSwg"
        
        if let nextPageToken = nextPageToken {
            requestString += "&pagetoken=\(nextPageToken)"
        }
        
        guard let requestURL = URL(string: requestString )else {
            print("Invalid URL.")
            return
        }
        

        do {
                // Start animating the indicator
                DispatchQueue.main.async {
                    self.indicator.startAnimating()
                }
                
                let (data, _) = try await URLSession.shared.data(from: requestURL)
                
                let decoder = JSONDecoder()
                let volumeData = try decoder.decode(VolumeData.self, from: data)
                
                if let hotels = volumeData.hotels {
                    let filteredHotels = hotels.filter { $0.name.hasPrefix(hotelName) }
                    
                    if iteration == 1 {
                        newHotels = filteredHotels
                    } else {
                        newHotels.append(contentsOf: filteredHotels)
                    }
                    
                    // Reload the table view on the main queue, async after is to slow it down, so it can show all the data
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.tableView.reloadData()
                        self.indicator.stopAnimating()
                    }
                    
                    if let nextPageToken = volumeData.nextPageToken, iteration < MAX_REQUESTS {
                        // Call the function recursively with the nextPageToken
                        await requestHotelsNamed(hotelName, nextPageToken: nextPageToken, iteration: iteration + 1)
                    }
                }
            } catch {
                print(error)
            }
        
       
    }
            
            
        
    // this function will be triggered when the user finishes editing the search bar
    // it will remove all the previously search result and start a new search for the hotel
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        newHotels.removeAll() // remove all previously search result
        tableView.reloadData()

        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
        }
        
        navigationItem.searchController?.dismiss(animated: true)
        indicator.startAnimating()
        URLSession.shared.invalidateAndCancel() // cancel ongoing URLSession task

        Task {
            await requestHotelsNamed(searchText)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newHotels.count
    }
    

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CELL_HOTEL, for: indexPath)

        let hotel = newHotels[indexPath.row]
        cell.textLabel?.text = hotel.name

        return cell
    }
    
    // MARK: - Navigation
    
    // this function show a segue transaction to hotel details view controller
    // whenever the user click on the row of the hotel, it will go to the hotel details view controller
    // and shows the user the details
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showDetailsSegue" { 
                let indexPath = self.tableView.indexPathForSelectedRow
                let selectedHotel = self.newHotels[indexPath!.row]
                let hotelDetailVC = segue.destination as! HotelDetailsViewController
                hotelDetailVC.selectedHotel = selectedHotel
            }
            
        }

}
