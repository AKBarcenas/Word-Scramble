//
//  MasterViewController.swift
//  Word Scramble
//
//  Created by Alex on 12/25/15.
//  Copyright © 2015 Alex Barcenas. All rights reserved.
//

import UIKit
import GameplayKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    
    // Stores the answers the player has already given.
    var objects = [String]()
    
    // Stores all possible words that can be used.
    var allWords = [String]()

    /*
     * Function Name: viewDidLoad
     * Parameters: None
     * Purpose: This method loads the word list if it can be found and then it starts the game.
     * Return Value: None
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "promptForAnswer")
        // Do any additional setup after loading the view, typically from a nib.
        if let startWordsPath = NSBundle.mainBundle().pathForResource("start", ofType: "txt") {
            if let startWords = try? String(contentsOfFile: startWordsPath, usedEncoding: nil) {
                allWords = startWords.componentsSeparatedByString("\n")
            }
        }
        
        else {
            allWords = ["silkworm"]
        }
        
        startGame()

    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = objects[indexPath.row]
        cell.textLabel!.text = object
        return cell
    }
    
    /*
     * Function Name: startGame
     * Parameters: None
     * Purpose: This method chooses a random word from the word list that will be used for the game.
     * Return Value: None
     */
    
    func startGame() {
        allWords = GKRandomSource.sharedRandom().arrayByShufflingObjectsInArray(allWords) as! [String]
        title = allWords[0]
        objects.removeAll(keepCapacity: true)
        tableView.reloadData()
    }
    
    /*
     * Function Name: promptForAnswer
     * Parameters: None
     * Purpose: This method creates an alert controller that allows the player to enter an answer
     *   for the game.
     * Return Value: None
     */
    
    func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler(nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .Default) { [unowned self, ac] (action: UIAlertAction!) in
            let answer = ac.textFields![0]
            self.submitAnswer(answer.text!)
        }
        
        ac.addAction(submitAction)
        
        presentViewController(ac, animated: true, completion: nil)
    }
    
    /*
     * Function Name: submitAnswer
     * Parameters: answer - the answer the player enetered for the game.
     * Purpose: This method checks if the answer the user entered is valid and an error message be shown
     *   if it is not valid.
     * Return Value: None
     */
    
    func submitAnswer(answer: String)  {
        let lowerAnswer = answer.lowercaseString
        
        let errorTitle: String
        let errorMessage: String
        
        if wordIsPossible(lowerAnswer) {
            if wordIsOriginal(lowerAnswer) {
                if wordIsReal(lowerAnswer) {
                    objects.insert(answer, atIndex: 0)
                    
                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                    
                    return
                }
                else {
                    errorTitle = "Word not recognised"
                    errorMessage = "You can't just make them up, you know!"
                }
            }
            
            else {
                errorTitle = "Word used already"
                errorMessage = "Be more original!"
            }
        }
        
        else {
            errorTitle = "Word not possible"
            errorMessage = "You can't spell that word from '\(title!.lowercaseString)'!"
        }
        
        let ac = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .Alert)
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(ac, animated: true, completion: nil)
    }
    
    /*
     * Function Name: wordIsPossible
     * Parameters: word - the word we are checking.
     * Purpose: This method checks if a word can be made from the one chosen for the game.
     * Return Value: bool
     */
    
    func wordIsPossible(word: String) -> Bool {
        var tempWord = title!.lowercaseString
        
        for letter in word.characters {
            if let pos = tempWord.rangeOfString(String(letter)) {
                tempWord.removeAtIndex(pos.startIndex)
            }
            
            else {
                return false
            }
        }
        
        return true
    }
    
    /*
     * Function Name: wordIsOriginal
     * Parameters: word - the word we are checking.
     * Purpose: This method checks if the word has not already been entered.
     * Return Value: bool
     */
    
    func wordIsOriginal(word: String) -> Bool {
        return !objects.contains(word)
    }
    
    /*
     * Function Name: wordIsReal
     * Parameters: word - the word we are checking.
     * Purpose: This method checks if the word entered is a real word.
     * Return Value: None
     */
    
    func wordIsReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSMakeRange(0, word.characters.count)
        let misspelledRange = checker.rangeOfMisspelledWordInString(word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }

}

