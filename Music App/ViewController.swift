//
//  ViewController.swift
//  Music App
//
//  Created by Simran on 03/04/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var MusicList: UITableView!
     var data = NetworkRequest.shared
    var songs : [Datum] = []
    var dataCount = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        MusicList.allowsSelection = true
        MusicList.delegate = self
        MusicList.dataSource = self
        fetchData()
        DispatchQueue.main.async {
            self.MusicList.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "showDetail",
               let indexPath = sender as? IndexPath,
               let detailViewController = segue.destination as? MusicDetailViewController {
                // Pass data to the detail view controller
                print("Your value", songs[indexPath.row])
                detailViewController.selectedMusicIndex = indexPath.row
                detailViewController.musicItems = songs
                detailViewController.musicURL = songs[indexPath.row].url
              //  detailViewController.list = songs[indexPath.row]
            }
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("This is select index \(indexPath.row)")
        performSegue(withIdentifier: "showDetail", sender: indexPath)
    }
  
    
    
    
}

extension ViewController {
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
                    self?.songs = songs.data
                    // Reload corresponding table view cell on the main thread
                    DispatchQueue.main.async {
                        
                        self?.MusicList.reloadData()
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }.resume()
        }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate{
    // Display Music List Using Table View Method
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Fetched2: ", songs.count)
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MusicList.dequeueReusableCell(withIdentifier:"MusicListViewCell" , for: indexPath) as! MusicListViewCell
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
}
