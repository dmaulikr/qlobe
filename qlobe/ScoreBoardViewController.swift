//
//  ScoreBoardViewController.swift
//  qlobe
//
//  Created by allen rand on 11/17/15.
//  Copyright © 2015 qlobe. All rights reserved.
//

import UIKit
import AVFoundation

var triviaGameCount = 0
//current round number
var ROUND = 1
//number of rounds the match will have, default = 10.
var numberOfRoundsPerMatch = 2 // number of rounds is actually numberOfRoundsPerMatch - 1
//because of off by one errors prevention

class ScoreBoardViewController: UIViewController {
    var segues : [String] = settings.getGamesSetting()
    //var segues : [String] = ["Trivia"]
    //var segues : [String] = ["TapRace"]
    //var segues : [String] = ["SimonSays"]
    var rand = 0
    
    var tapRaceAudio = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("mk64_racestart", ofType: "wav")!))
    
    var triviaAudio = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("trivia", ofType: "wav")!))
    
    var simonSaysAudio = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("simonSaysStart", ofType: "mp3")!))
    
    var changeGameAudio = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("boing", ofType: "wav")!))
    
    var roundAudio = try? AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("round", ofType: "mp3")!))
    
    // MARK: Outlets
    
    @IBOutlet weak var P1ScoreTop: UITextView!
    @IBOutlet weak var P2ScoreTop: UITextView!
    @IBOutlet weak var P1ScoreBottom: UITextView!
    @IBOutlet weak var P2ScoreBottom: UITextView!
    @IBOutlet weak var displayLabelBottom: UILabel!
    @IBOutlet weak var displayLabelTop: UILabel!
    @IBOutlet weak var ContinueButtonBottom: UIButton!
    @IBOutlet weak var ContinueButtonTop: UIButton!
    @IBOutlet weak var ChangeGameButtonBottom: UIButton!
    @IBOutlet weak var ChangeGameButtonTop: UIButton!
    @IBOutlet weak var muteBtnBottom: UIButton!
    @IBOutlet weak var muteBtnTop: UIButton!
    @IBOutlet weak var QuitButtonBottom: UIButton!
    @IBOutlet weak var QuitButtonTop: UIButton!

    
    // MARK: Actions
    func quitGame(){
        // set the number of rounds in the match to the number at the time of quitting + 1 for off by one error
        numberOfRoundsPerMatch = ROUND
        roundAudio!.stop()
        // segue to the final results page
        performSegueWithIdentifier("GameOver", sender: self)
    }
    @IBAction func QuitButtonBottom(sender: AnyObject) {
        quitGame()
    }
    
    @IBAction func QuitButtonTop(sender: AnyObject) {
        quitGame()
    }
    
    
    
    func setAudioVolume(){
        tapRaceAudio?.volume = settings.getVolume()
        triviaAudio?.volume = settings.getVolume()
        simonSaysAudio?.volume = settings.getVolume()
        changeGameAudio?.volume = settings.getVolume()
        roundAudio?.volume = settings.getVolume()
    }
    
    func switchMute(){
        if(settings.isMute() == false){
            settings.setVolumePre(settings.getVolume())
            settings.setVolume(0.0)
            muteBtnBottom.setImage(UIImage(named: "sound_off"), forState: .Normal)
            muteBtnTop.setImage(UIImage(named: "sound_off"), forState: .Normal)
        }
        else{
            settings.setVolume(settings.getVolumePre())
            muteBtnBottom.setImage(UIImage(named: "sound_on"), forState: .Normal)
            muteBtnTop.setImage(UIImage(named: "sound_on"), forState: .Normal)
        }
        setAudioVolume()
    }
    
    @IBAction func muteBtnPressedBottom(sender: AnyObject) {
        switchMute()
    }
    
    @IBAction func muteBtnPressedTop(sender: AnyObject) {
        switchMute()
    }
    
    
    func changeGame(){
        // allow user to change the next game
        
        // make sure the game isnt the same as the one they had before they pressed change game
        rand = (rand+1) % segues.count
        
        displayLabelBottom.text = "\(segues[rand])"
        displayLabelTop.text = "\(segues[rand])"
        
        changeGameAudio!.play()
    }
    @IBAction func ChangeGameButtonBottom(sender: AnyObject) {
        changeGame()
    }
    
    @IBAction func ChangeGameButtonTop(sender: AnyObject) {
        changeGame()
    }
    
    
    func ContinueToNextGame(){
        var segueDelay = 0.0
        
        //continue playing the game
        ROUND++
        
        //Play sound effect for TapRace
        if(segues[rand] == "TapRace" && (settings.isMute() == false)){
            segueDelay = 5.0
            tapRaceAudio!.play()
        }else if(segues[rand] == "Trivia" && (settings.isMute() == false)){
            segueDelay = 3.0
            triviaAudio!.play()
        }else if(segues[rand] == "SimonSays" && (settings.isMute() == false)){
            segueDelay = 3.0
            simonSaysAudio!.play()
        }
        
        // Disable the change game button
        ChangeGameButtonBottom.enabled = false
        ChangeGameButtonTop.enabled = false
        muteBtnBottom.enabled = false
        muteBtnTop.enabled = false
        
        roundAudio!.stop()
        
        // perform segue with delay for the audio to play
        _ = NSTimer.scheduledTimerWithTimeInterval(segueDelay, target: self, selector: "segueToNextGame",
            userInfo: nil, repeats: false)
    }
    
    @IBAction func ContinueButtonTop(sender: AnyObject) {
        ContinueToNextGame()
    }
    
    @IBAction func ContinueButtonBottom(sender: AnyObject) {
        ContinueToNextGame()
    }
    
    
    // MARK: ViewControler functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get random game type
        rand = Int(arc4random_uniform(UInt32(segues.count)))
        
        // style the page
        style()
        
        //account for volume settings
        setAudioVolume()
        roundAudio!.play()
        
        //reset triviaGameCount to 0
        triviaGameCount = 0
        // intially everything should be hidden
        ContinueButtonBottom.alpha = 0
        ContinueButtonTop.alpha = 0
        ChangeGameButtonBottom.alpha = 0
        ChangeGameButtonTop.alpha = 0
        P1ScoreTop.alpha = 0
        P2ScoreTop.alpha = 0
        P1ScoreBottom.alpha = 0
        P2ScoreBottom.alpha = 0
        displayLabelBottom.alpha = 0
        displayLabelTop.alpha = 0
        QuitButtonTop.alpha = 0
        QuitButtonBottom.alpha = 0
        
        //load the score
        displayScore()
        
    }
    override func viewDidAppear(animated: Bool) {
        
        //fade in to display score
        P1ScoreTop.fadeIn()
        P2ScoreTop.fadeIn()
        P1ScoreBottom.fadeIn()
        P2ScoreBottom.fadeIn()
        displayLabelBottom.fadeIn()
        displayLabelTop.fadeIn()
        ContinueButtonBottom.blinkingButton()
        
        // show the score for 4 seconds then show the change game and continue buttons
        _ = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: "buttons",
            userInfo: nil, repeats: false)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Helper Functions
    func segueToNextGame(){
        
        // segue to the random next game
        performSegueWithIdentifier(segues[rand], sender: self)
    }
    
    func style(){
        // sets the styling of the view to match the rest of the app
        
        view.backgroundColor = UIColor(netHex:0x2c3e50)
        
        // set text view styling
        P1ScoreTop.selectable = true
        P1ScoreTop.editable = true
        P2ScoreTop.selectable = true
        P2ScoreTop.editable = true
        P1ScoreBottom.selectable = true
        P1ScoreBottom.editable = true
        P2ScoreBottom.selectable = true
        P2ScoreBottom.editable = true
        
        P1ScoreTop.font = UIFont(name: "Kankin", size: 25)
        P1ScoreTop.textColor = UIColor(netHex: 0xeeeeee)
        P1ScoreTop.textAlignment = NSTextAlignment.Center
        P1ScoreTop.backgroundColor = UIColor(netHex:0x2c3e50)
        
        P2ScoreTop.font = UIFont(name: "Kankin", size: 25)
        P2ScoreTop.textColor = UIColor(netHex: 0xeeeeee)
        P2ScoreTop.textAlignment = NSTextAlignment.Center
        P2ScoreTop.backgroundColor = UIColor(netHex:0x2c3e50)
        
        P1ScoreBottom.font = UIFont(name: "Kankin", size: 25)
        P1ScoreBottom.textColor = UIColor(netHex: 0xeeeeee)
        P1ScoreBottom.textAlignment = NSTextAlignment.Center
        P1ScoreBottom.backgroundColor = UIColor(netHex:0x2c3e50)
        
        P2ScoreBottom.font = UIFont(name: "Kankin", size: 25)
        P2ScoreBottom.textColor = UIColor(netHex: 0xeeeeee)
        P2ScoreBottom.textAlignment = NSTextAlignment.Center
        P2ScoreBottom.backgroundColor = UIColor(netHex:0x2c3e50)
        
        P1ScoreTop.selectable = false
        P1ScoreTop.editable = false
        P2ScoreTop.selectable = false
        P2ScoreTop.editable = false
        P1ScoreBottom.selectable = false
        P1ScoreBottom.editable = false
        P2ScoreBottom.selectable = false
        P2ScoreBottom.editable = false
        
        // set label styling
        displayLabelBottom.font = UIFont(name: "Kankin", size: 40)
        displayLabelBottom.textColor = UIColor(netHex: 0xf1c40f)
        displayLabelBottom.textAlignment = NSTextAlignment.Center
        displayLabelBottom.text = "Round \(ROUND)"
        
        displayLabelTop.font = UIFont(name: "Kankin", size: 40)
        displayLabelTop.textColor = UIColor(netHex: 0xf1c40f)
        displayLabelTop.textAlignment = NSTextAlignment.Center
        displayLabelTop.text = "Round \(ROUND)"
        
        // set button styling
        ContinueButtonBottom.titleLabel!.font = UIFont(name: "Kankin", size: 25)!
        ContinueButtonBottom.setTitleColor(UIColor(netHex: 0xeeeeee), forState: UIControlState.Normal)
        ContinueButtonBottom.titleLabel!.text = "Continue"
        
        ContinueButtonTop.titleLabel!.font = UIFont(name: "Kankin", size: 25)!
        ContinueButtonTop.setTitleColor(UIColor(netHex: 0xeeeeee), forState: UIControlState.Normal)
        ContinueButtonTop.titleLabel!.text = "Continue"
        
        ChangeGameButtonBottom.titleLabel!.font = UIFont(name: "Kankin", size: 25)!
        ChangeGameButtonBottom.setTitleColor(UIColor(netHex: 0xeeeeee), forState: UIControlState.Normal)
        ChangeGameButtonBottom.titleLabel!.text = "Random game)"
        
        ChangeGameButtonTop.titleLabel!.font = UIFont(name: "Kankin", size: 25)!
        ChangeGameButtonTop.setTitleColor(UIColor(netHex: 0xeeeeee), forState: UIControlState.Normal)
        ChangeGameButtonTop.titleLabel!.text = "Random game"
        
        
        QuitButtonBottom.titleLabel!.font = UIFont(name: "Kankin", size: 20)!
        QuitButtonBottom.setTitleColor(UIColor(netHex: 0xeeeeee), forState: UIControlState.Normal)
        QuitButtonBottom.titleLabel!.text = "Quit"
        
        QuitButtonTop.titleLabel!.font = UIFont(name: "Kankin", size: 20)!
        QuitButtonTop.setTitleColor(UIColor(netHex: 0xeeeeee), forState: UIControlState.Normal)
        QuitButtonTop.titleLabel!.text = "Quit"
        
       
        
        // flip the buttons and labels that need to be flipped
        displayLabelTop.flipUpSideDown()
        P1ScoreTop.flipUpSideDown()
        ContinueButtonTop.flipUpSideDown()
        ChangeGameButtonTop.flipUpSideDown()
        P2ScoreTop.flipUpSideDown()
        P1ScoreTop.flipUpSideDown()
        QuitButtonTop.flipUpSideDown()
        muteBtnTop.flipUpSideDown()
        
        
        if(settings.isMute() == false){
            settings.setVolumePre(settings.getVolume())
            muteBtnBottom.setImage(UIImage(named: "sound_on"), forState: .Normal)
            muteBtnTop.setImage(UIImage(named: "sound_on"), forState: .Normal)
        }
        else{
            muteBtnBottom.setImage(UIImage(named: "sound_off"), forState: .Normal)
            muteBtnTop.setImage(UIImage(named: "sound_off"), forState: .Normal)
        }
    }
    
    func displayScore(){
        // displays the current score of the match
        
        P1ScoreBottom.text = "Red's Score:\n\(Player1.getTotalPlayerScore())"
        P1ScoreTop.text = "Red's Score:\n\(Player1.getTotalPlayerScore())"
        P2ScoreBottom.text = "Blue's Score:\n\(Player2.getTotalPlayerScore())"
        P2ScoreTop.text = "Blue's Score:\n\(Player2.getTotalPlayerScore())"
    }
    
    func buttons(){
        //segue to the gameover view when the number of rounds are reached
        if(ROUND >= numberOfRoundsPerMatch){
            roundAudio!.stop()
            performSegueWithIdentifier("GameOver", sender: self)
        }
        
        // make the  buttons blink
        ContinueButtonBottom.blinkingButton()
        ContinueButtonTop.blinkingButton()
        
        // do some fading animations
        displayLabelBottom.fadeOut(1, delay: 0, completion: {_ in
            self.displayLabelBottom.text = "\(self.segues[self.rand])"
            self.displayLabelBottom.fadeIn()
        })
        displayLabelTop.fadeOut(1, delay: 0, completion: {_ in
            self.displayLabelTop.text = "\(self.segues[self.rand])"
            self.displayLabelTop.fadeIn()
        })
        
        //fade out score displays and fade in buttons
        P1ScoreTop.fadeOut(1, delay: 0, completion: {_ in
            self.ContinueButtonBottom.fadeIn()
            self.ContinueButtonTop.fadeIn()
            self.ChangeGameButtonBottom.fadeIn()
            self.ChangeGameButtonTop.fadeIn()
            self.QuitButtonTop.fadeIn()
            self.QuitButtonBottom.fadeIn()
        })
        
        P2ScoreTop.fadeOut()
        P1ScoreBottom.fadeOut()
        P2ScoreBottom.fadeOut()
    }
    
    
    
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
