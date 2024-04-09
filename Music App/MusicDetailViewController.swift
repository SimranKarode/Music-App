//
//  MusicDetailViewController.swift
//  Music App
//
//  Created by Simran on 07/04/24.
//

/* In this music list some audio urls are not working because of space issue.
 For Example = "https://pub-172b4845a7e24a16956308706aaf24c2.r2.dev/ first-touch-160603.mp3"
 
 */

import UIKit
import AVFoundation

class MusicDetailViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var MusicName: UILabel!
    @IBOutlet weak var ArtistName: UILabel!
    @IBOutlet weak var playPauseBtn: UIButton!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    var player: AVPlayer?
    var playerItem: AVPlayerItem?
    var isSet: Bool = false
    var songURLs = [String]()
    var audioPlayer: AVAudioPlayer?
    var selectedMusicIndex: Int = 0
    var musicItems: [Datum] = []
    var timer: Timer?
    var timeObserver: Any?
    var data = NetworkRequest.shared
    var musicURL = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        updateCurrentMusicLabel()
        updateCoverImageInCollectionView(currentIndex: selectedMusicIndex)
        
        // Scroll to the selected music item
        let indexPath = IndexPath(item: selectedMusicIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        
        let urlString = musicItems[selectedMusicIndex].url
        let trimmedString = urlString.trimmingCharacters(in: .whitespaces)
           print("URL...", trimmedString)
                guard let url = URL(string: trimmedString) else {
                    print("Invalid URL")
                    return
                }
                
        // Download and play the audio
        downloadAndPlayAudio(from: url)
    }
    
    // Update the current music label with the selected music name
        func updateCurrentMusicLabel() {
            MusicName.text = musicItems[selectedMusicIndex].name
            ArtistName.text = musicItems[selectedMusicIndex].artist
            musicURL = musicItems[selectedMusicIndex].url
        }

    
    func updateCoverImageInCollectionView(currentIndex: Int) {
        let indexPath = IndexPath(item: currentIndex, section: 0)
        print("IndexPath:", indexPath)

        guard currentIndex >= 0 && currentIndex < musicItems.count else {
            print("Invalid index")
            return
        }

        let song = musicItems[currentIndex]
        let imageURL = "https://cms.samespace.com/assets/\(song.cover)"
        print("Image URL:", imageURL)
    }




    
    @IBAction func playMusic(_ sender: Any) {
       // musicItems[selectedMusicIndex] = musicItems[selectedMusicIndex + 1]
        let nextSongURL = musicItems[selectedMusicIndex].url
        print("Forward Music", musicItems[selectedMusicIndex].name)
        guard let url = URL(string: nextSongURL) else {
            print("Invalid URL")
            return
        }
        
        if let player = player {
          if player.rate == 0 {
              player.play()
              playAudio(at: url)
              playPauseBtn.setImage(UIImage(named: "pauseBtn"), for: .normal)
           } else {
               player.pause()
               playPauseBtn.setImage(UIImage(named: "playButton"), for: .normal)
      }
     }
    }
    
    @IBAction func forwardMusic(_ sender: Any) {
        print("Next Music will Play")
        forwardMusic()
        updateCurrentMusicLabel()
    }
    
    @IBAction func backwordMusic(_ sender: Any) {
        print("Previous Music will Play")
       backwardMusic()
        updateCurrentMusicLabel()
    }
    
}

extension MusicDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return musicItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! SongsDetailsCollectionCell
        let song = musicItems[indexPath.item]
        data.fetchImage(from: "https://cms.samespace.com/assets/\(song.cover)") { (image) in
                DispatchQueue.main.async {
                    cell.imageView.image = image
                    cell.imageView.layer.cornerRadius = 4
                }
            }
         
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMusicIndex = indexPath.item
    }
}

extension MusicDetailViewController {
    // MARK: - Progress View Methods
    
     func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let visibleIndexPaths = collectionView.indexPathsForVisibleItems
            if let firstIndexPath = visibleIndexPaths.first {
                selectedMusicIndex = firstIndexPath.item
                updateCurrentMusicLabel()
            }
        }
    
      func startUpdatingProgressView() {
          timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgressView), userInfo: nil, repeats: true)
      }
      
      func stopUpdatingProgressView() {
          timer?.invalidate()
          timer = nil
      }
      
      @objc func updateProgressView() {
          if let player = audioPlayer {
              let currentTime = player.currentTime
              let duration = player.duration
              let progress = Float(currentTime / duration)
              progressView.progress = progress
              
              // Update labels
              currentTimeLabel.text = formattedTime(timeInterval: currentTime)
              durationLabel.text = formattedTime(timeInterval: duration)
          }
      }
    
    func formattedTime(timeInterval: TimeInterval) -> String {
            let minutes = Int(timeInterval) / 60
            let seconds = Int(timeInterval) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
}

extension MusicDetailViewController {
    // MARK: - Audio Playback
   func downloadAndPlayAudio(from url: URL) {
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
                       self.playAudio(at: destinationURL)
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

    // MARK: - Music Player Methods
    
    func playAudio(at url: URL) {
            let playerItem = AVPlayerItem(url: url)
            player = AVPlayer(playerItem: playerItem)
        if playerItem.status == .failed {
                print("Failed to load player item with error: \(playerItem.error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Add time observer to update progress view
            timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC)), queue: DispatchQueue.main) { [weak self] time in
                guard let self = self else { return }
                guard let playerItem = self.player?.currentItem else {
                    print("Player item is nil.")
                    return
                }
                
                guard let duration = playerItem.duration.seconds.isFinite ? playerItem.duration.seconds : nil else {
                    print("Invalid duration.")
                    return
                }

                let currentTime = CMTimeGetSeconds(time)
                let progress = Float(currentTime / duration)
                DispatchQueue.main.async {
                    self.progressView.progress = progress
                    self.currentTimeLabel.text = self.formatTime(currentTime)
                    self.durationLabel.text = self.formatTime(duration)
                }
            }
            
            player?.play()
        }
        
    func formatTime(_ time: TimeInterval) -> String {
            let minutes = Int(time) / 60
            let seconds = Int(time) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    
        func pauseAudio() {
            player?.pause()
            // Stop updating progress view
                    stopUpdatingProgressView()
        }
    
    
    
       func pauseMusic() {
            audioPlayer?.pause()
        
              // Stop updating progress view
                stopUpdatingProgressView()
        }
        
        func forwardMusic() {
            if selectedMusicIndex == musicItems.count - 1 {
                    // If current index is the last index, reset to 0
                    selectedMusicIndex = 0
                    let nextSongURL = musicItems[selectedMusicIndex].url
                     print("Forward Music", musicItems[selectedMusicIndex].name)
                    guard let url = URL(string: nextSongURL) else {
                    print("Invalid URL")
                    return
                }
                playAudio(at: url)
                } else {
                    // Increment the index
                    selectedMusicIndex = selectedMusicIndex + 1
//                    musicItems[selectedMusicIndex] = musicItems[selectedMusicIndex + 1]
                    let nextSongURL = musicItems[selectedMusicIndex].url
                    print("Forward Music", musicItems[selectedMusicIndex].name)
                    guard let url = URL(string: nextSongURL) else {
                        print("Invalid URL")
                        return
                    }
                    playAudio(at: url)
                    
                    // Update the cover image in the collection view
                    updateCoverImageInCollectionView(currentIndex: selectedMusicIndex)
                }
            
        }
        
        func backwardMusic() {
            
            if selectedMusicIndex == musicItems.count - 1 {
                
                    // If current index is the last index, reset to 0
                
                    selectedMusicIndex = 0
                    let nextSongURL = musicItems[selectedMusicIndex].url
                     print("Forward Music", musicItems[selectedMusicIndex].name)
                    guard let url = URL(string: nextSongURL) else {
                    print("Invalid URL")
                    return
                    
                }
                playAudio(at: url)
                } else {
                    
                    // Increment the index
                    
                    selectedMusicIndex = selectedMusicIndex - 1
                    let nextSongURL = musicItems[selectedMusicIndex].url
                    print("backward Music", musicItems[selectedMusicIndex].name, selectedMusicIndex)
                    guard let url = URL(string: nextSongURL) else {
                        print("Invalid URL")
                        return
                    }
                    playAudio(at: url)
                }
        }
    
}
