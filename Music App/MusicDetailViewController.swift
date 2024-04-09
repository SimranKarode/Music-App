//
//  MusicDetailViewController.swift
//  Music App
//
//  Created by Simran on 07/04/24.
//

import UIKit
import AVFoundation

class MusicDetailViewController: UIViewController, UICollectionViewDataSource {

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
    //let musicPlayer = MusicPlayer()
    var data = NetworkRequest.shared
    var musicURL = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        updateCurrentMusicLabel()
        updateCoverImageInCollectionView(currentIndex: selectedMusicIndex)
       // fetchSongs()
        
        // Scroll to the selected music item
        let indexPath = IndexPath(item: selectedMusicIndex, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
        
        let urlString = musicItems[selectedMusicIndex].url
           print("URL...", musicURL)
                guard let url = URL(string: urlString) else {
                    print("Invalid URL")
                    return
                }
                
        // Download and play the audio
        downloadAndPlayAudio(from: url)
    }
    
    // MARK: - Audio Playback
        func downloadAndPlayAudio(from url: URL) {
            let downloadTask = URLSession.shared.downloadTask(with: url) { [weak self] (location, response, error) in
                guard let self = self else { return }
                if let location = location {
                    do {
                        // Move the downloaded file to a permanent location
                        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                        let destinationURL = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
                        try FileManager.default.moveItem(at: location, to: destinationURL)
                        
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let visibleIndexPaths = collectionView.indexPathsForVisibleItems
            if let firstIndexPath = visibleIndexPaths.first {
                selectedMusicIndex = firstIndexPath.item
                updateCurrentMusicLabel()
            }
        }
    
    // Update the current music label with the selected music name
        func updateCurrentMusicLabel() {
            MusicName.text = musicItems[selectedMusicIndex].name
            ArtistName.text = musicItems[selectedMusicIndex].artist
            musicURL = musicItems[selectedMusicIndex].url
        }
    
    func playSong(at index: Int) {
            guard index >= 0 && index < musicItems.count else { return }
            let songURL = musicItems[index].url
        if let urlString = songURL.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
           let url = URL(string: urlString) {
            // Use the URL here
          //  musicPlayer.playMusic(url:url)
            print("Your URL", url)
        } else {
            // Handle invalid URL string
            print("Invalid URL string")
        }
    }

    
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
    
    // MARK: - Music Player Methods
        func playMusics(at index: Int) {
            guard index >= 0 && index < songURLs.count else { return }
            guard let url = URL(string: songURLs[index]) else { return }
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
                // Start updating progress view
                startUpdatingProgressView()
            } catch {
                print("Error playing audio: \(error.localizedDescription)")
            }
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
                    print("Forward Music", musicItems[selectedMusicIndex].name)
                    guard let url = URL(string: nextSongURL) else {
                        print("Invalid URL")
                        return
                    }
                    playAudio(at: url)
                }
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

//        data.fetchImage(from: imageURL) { [weak self] (image) in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                // Check if the cell is still visible and the index path is valid
//                if let visibleIndexPaths = self.collectionView.indexPathsForVisibleItems,
//                   visibleIndexPaths.contains(indexPath) {
//                    // Update cell directly if it's still visible
//                    if let cell = self.collectionView.cellForItem(at: indexPath) as? SongsDetailsCollectionCell {
//                        cell.imageView.image = image
//                    }
//                }
//                else {
//                    // If the cell is not visible, create a new song instance with updated image
//                    var updatedMusicItems = self.musicItems
//                    var updatedSong = song // Assuming song is a struct
////                    updatedSong.image = image
//                    updatedMusicItems[currentIndex] = updatedSong
//                    self.musicItems = updatedMusicItems
//                    self.collectionView.reloadData()
//                }
//            }
//        }
    }




    
    @IBAction func playMusic(_ sender: Any) {
       // musicItems[selectedMusicIndex] = musicItems[selectedMusicIndex + 1]
        let nextSongURL = musicItems[selectedMusicIndex].url
        print("Forward Music", musicItems[selectedMusicIndex].name)
        guard let url = URL(string: nextSongURL) else {
            print("Invalid URL")
            return
        }
        playAudio(at: url)
        if let player = player {
          if player.rate == 0 {
              player.play()
              playPauseBtn.setImage(UIImage(named: "pauseBtn"), for: .normal)
           } else {
               player.pause()
               playPauseBtn.setImage(UIImage(named: "playButton"), for: .normal)
      }
     }
//        player?.play()
        //playPauseBtn.setImage(UIImage(named: "pauseBtn"), for: .normal)
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

extension MusicDetailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMusicIndex = indexPath.item
        playSong(at: selectedMusicIndex)
        playMusics(at: selectedMusicIndex)
    }
}

extension MusicDetailViewController {
    // MARK: - Progress View Methods
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
