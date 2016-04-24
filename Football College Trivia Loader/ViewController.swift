//
//  ViewController.swift
//  mac-demo
//
//  Created by Brandon Jenniges on 4/21/16.
//  Copyright © 2016 Brandon Jenniges. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var input: NSScrollView!
    @IBOutlet weak var output: NSScrollView!
    
    @IBOutlet weak var versionTextField: NSTextField!
    @IBOutlet weak var typeButton: NSPopUpButton!
    
    let dateFormatter = NSDateFormatter()
    
    var headers = [AnyObject]()
    var rows = [[AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        input.documentView!.textContainer!?.textView?.richText = false // rich text is most likely the paste option in this field
        input.documentView!.textContainer!?.textView?.verticallyResizable = false
        
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.dateFormat = "MM-dd-yyyy"
        
        self.typeButton.removeAllItems()
        self.typeButton.addItemsWithTitles(["Player", "College"])
    }

    @IBAction func typeSelection(sender: AnyObject) {
        
    }

    @IBAction func convert(sender: AnyObject) {
        rows.removeAll()
        
        let inputString = input.documentView!.textStorage!!.string
        splitInput(inputString)
        let dic = createDictionary()  // The dictionary key has to be a String for JSON encoding

        do {
            let jsonData = try NSJSONSerialization.dataWithJSONObject(dic, options: NSJSONWritingOptions.PrettyPrinted)
            let string = NSString(data: jsonData,
                                  encoding: NSUTF8StringEncoding)
            output.documentView!.textStorage!!.mutableString.setString(string! as String)
            // here "jsonData" is the dictionary encoded in JSON data
        } catch let error as NSError {
            print(error)
        }
    }
    
    func splitInput(string: String) {
        let splitString = string.characters.split{$0 == "\n"}.map(String.init)
        
        for row in splitString {
            let splitRow = row.characters.split{$0 == "\t"}.map(String.init)
            rows.append(splitRow)
        }
        
        headers = rows[0]
        rows.removeFirst()
    }
    
    func createDictionary() -> [String: AnyObject] {
        let versionNumber = self.versionTextField.stringValue
        let dateString = self.dateFormatter.stringFromDate(NSDate())
        let itemsString = self.typeButton.title == "Player" ? "players" : "colleges"
        
        var items = [[String : AnyObject]]()
        for row in rows {
            items.append(self.jsonForItem(row))
        }
        return ["version": versionNumber, "created": dateString, itemsString : items]
    }
    
    func jsonForItem(row : [AnyObject]) -> [ String: AnyObject ] {
        if self.typeButton.title == "Player" {
            return jsonForPlayer(row)
        } else {
            return jsonForCollege(row)
        }
    }
    
    func jsonForPlayer(row : [AnyObject]) -> [ String: AnyObject ] {
        return [
            "lastName": row[0],
            "firstName": row[1],
            "position": row[2],
            "jerseyNumber": row[3].integerValue,
            "proTeam": row[4],
            "college": row[5],
            "overall": row[6].integerValue,
            "tier": row[7].integerValue
        ]
    }
    
    func jsonForCollege(row : [AnyObject]) -> [ String: AnyObject ] {
        return [
            "college": row[0],
            "tier": row[1].integerValue
        ]
    }
    
    
    
    
}

