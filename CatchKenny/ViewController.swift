//
//  ViewController.swift
//  CatchKenny
//
//  Created by Ata Çalışkan on 6.10.2023.
//

import UIKit

struct GameInfo {
    var gameId: Int
    var score: Int
}

class ViewController: UIViewController, UICollectionViewDataSource {
        
    let timer = Timer()
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var highscoreLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    let kennyImage: UIImageView = UIImageView(image: UIImage(named: "kenny"))
    var cellStates: [Bool] = Array(repeating: false, count: 9)
    
    public var game: Game = Game(gameDuration: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        game.setViewController(viewController: self)
        collectionView.dataSource = self

        // Add tap gesture on kenny image
        kennyImage.isUserInteractionEnabled = true
        let kennyTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(kennyTapped))
        kennyImage.addGestureRecognizer(kennyTapGestureRecognizer)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if game.latestGames.isEmpty {
            showGameAlert(title: "Start Game", message: "Start a new game now!")
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellStates.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.white.cgColor
        cell.contentView.layer.cornerRadius = 4.0
        
        if cellStates[indexPath.item] {
            let imageView = kennyImage
            imageView.frame.size.width = 100
            imageView.frame.size.height = 100
            imageView.center = cell.contentView.center
            imageView.contentMode = .scaleAspectFit
            cell.contentView.addSubview(imageView)
        }
        
        return cell
    }
    
    func showGameAlert(title: String, message: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let replayAction = UIAlertAction(title: "Replay", style: .default) { action in
            print("New Game Started!")
            self.game.startNewGame()
        }
        
        alertController.addAction(replayAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func kennyTapped(){
        game.kennyTapped()
    }

}

class Game {
    
    public var isGameActive: Bool = false
    
    private var gameDuration: Int = 0
    private var counter: Int = 0
    private var currentGameScore: Int = 0
    private var gameTimer = Timer()
    private var positionChangeInterval = Timer()
    private weak var vc: ViewController!
    
    var latestGames: [GameInfo] = []
    
    init(gameDuration duration: Int){
        self.gameDuration = duration
    }

    public func startNewGame(){
        isGameActive = true
        counter = gameDuration
        vc.timeLabel.text = String(counter)
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timeController), userInfo: nil, repeats: true)
        positionChangeInterval = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(changeKennyPosition), userInfo: nil, repeats: true)
        
    }
    
    public func endCurrentGame() {
        isGameActive = false
        gameTimer.invalidate()
        positionChangeInterval.invalidate()
        setGameResults()
        counter = gameDuration
        currentGameScore = 0
        vc.scoreLabel.text = "Score : 0"
        vc.showGameAlert(title: "Time is up!", message: "Would you like to start a new game ?")
    }
    
    public func getHighestScore() -> Int {
        
        var highestScore: Int = 0
        
        for gameInfo in latestGames {
            if gameInfo.score > highestScore {
                highestScore = gameInfo.score
            }
        }
        
        return highestScore
    }
    
    public func setViewController(viewController: ViewController){
        self.vc = viewController
    }
    
    private func setGameResults(){
        
        if let last: GameInfo = latestGames.last {
            
            let currentGameId = last.gameId + 1
            var currentGameInfo: GameInfo = GameInfo(gameId: currentGameId, score: self.currentGameScore)
            
            latestGames.append(currentGameInfo)
            
        } else {
            
            var currentGameInfo: GameInfo = GameInfo(gameId: 0, score: self.currentGameScore)
            latestGames.append(currentGameInfo)
        }
        
        vc.highscoreLabel.text = "Highscore : \(getHighestScore())"
        
    }
    
    @objc func timeController(){
        counter -= 1
        vc.timeLabel.text = String(counter)
        
        if counter == 0 {
            endCurrentGame()
        }
    }
    
    @objc func changeKennyPosition() {
    
        let newRandomIndex = Int.random(in: 0...8)
        let previousTrueIndex: Int? = vc.cellStates.firstIndex { state in
            return state
        }
        
        if previousTrueIndex != nil {
            vc.cellStates[previousTrueIndex!] = false
        }
        
        vc.cellStates[newRandomIndex] = true
        vc.collectionView.reloadData()
    }
    
    @objc func kennyTapped() {
        if isGameActive {
            currentGameScore += 1
        }
        vc.scoreLabel.text = "Score : \(currentGameScore)"
        print("Tapped")
    }
    
}


