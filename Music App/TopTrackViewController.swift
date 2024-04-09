//
//  TopTrackViewController.swift
//  Music App
//
//  Created by Simran on 05/04/24.
//

import UIKit

class TopTrackViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var songs : [Datum] = []
    var data = NetworkRequest.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchData()
    }
    
    func fetchData() {
            guard let url = URL(string: "https://cms.samespace.com/items/songs") else {
                print("Invalid URL")
                return
            }

            URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
                guard let data = data else {
                    print("No data received: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                do {
                    let decoder = JSONDecoder()
                    let songs = try decoder.decode(MusicModule.self, from: data)
                    print("Fetched: ", songs.data.count)
                    self?.songs = songs.data.filter { $0.topTrack }
                    // Reload corresponding table view cell on the main thread
                    DispatchQueue.main.async {
                        
                        self?.tableView.reloadData()
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }.resume()
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Total top track count:", songs.count)
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"MusicListViewCell" , for: indexPath) as! MusicListViewCell
        let datass = songs[indexPath.row]
        cell.nameLabel.text = datass.name
        cell.artistNameLabel.text = datass.artist
        
        // Set the text color of the text view
        cell.nameLabel.textColor = UIColor.white
        cell.artistNameLabel.textColor = UIColor.white
        
        // Set the content mode of the cover image view
        cell.listImageView.contentMode = .scaleToFill
        cell.listImageView.layer.cornerRadius = min(cell.listImageView.frame.size.width, cell.listImageView.frame.size.height) / 2
        cell.listImageView.layer.masksToBounds = true

        // Fetch the image asynchronously
        self.data.fetchImage(from: "https://cms.samespace.com/assets/\(datass.cover)") { (image) in
                DispatchQueue.main.async {
                    cell.listImageView.image = image
                }
            }
        return cell
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showDetails",
               let indexPath = sender as? IndexPath,
               let detailViewController = segue.destination as? MusicDetailViewController {
                // Pass data to the detail view controller
                print("Your value", songs[indexPath.row])
                detailViewController.selectedMusicIndex = indexPath.row
                detailViewController.musicItems = songs
              //  detailViewController.list = songs[indexPath.row]
            }
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This is select index \(indexPath.row)")
        performSegue(withIdentifier: "showDetails", sender: indexPath)
//        let detailViewController = storyboard?.instantiateViewController(withIdentifier: "MusicDetailViewController") as! MusicDetailViewController
    }

}
