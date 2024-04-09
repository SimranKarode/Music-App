//
//  MusicController.swift
//  Music App
//
//  Created by Simran on 03/04/24.
//

import Foundation
import UIKit

class NetworkRequest {
    static var shared = NetworkRequest()
    func fetchData(completion: @escaping (MusicModule?, Error?) -> Void) {
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
                //                    guard let fetchedSongs = songs.data else {
                //                        print("No songs fetched")
                //                        return
                //                    }
                //                           self?.songs = songs.data
                //                           DispatchQueue.main.async {
                //
                //                               self?.MusicList.reloadData()
                //                           }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    public func fetchImage(from url: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: url) else {
            print("Invalid URL")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Failed to fetch image:", error?.localizedDescription ?? "Unknown error")
                completion(nil)
                return
            }
            guard let image = UIImage(data: data) else {
                print("Failed to create image from data")
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }
    
    // MARK: - Audio Playback
     public func downloadAndPlayAudio(from url: URL) {
       let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] (location, response, error) in
           guard let self = self else { return }
           if let location = location {
               do {
                   // Move the downloaded file to a permanent location
                   let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                   let destinationURL = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
                   try FileManager.default.removeItem(at:location)
                   try FileManager.default.copyItem(at: location, to: destinationURL)
                   
                   // Play the audio from the downloaded file
                   DispatchQueue.main.async {
//                       self.playAudio(at: destinationURL)
                   }
               } catch {
                   print("Error moving file: \(error)")
               }
           } else {
               print("Error downloading audio: \(error?.localizedDescription ?? "Unknown error")")
           }
       }
       
       downloadTask.resume()
   }
}
