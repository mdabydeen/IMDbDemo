//
//  ViewController.swift
//  iMDBDemo
//
//  Created by Michael Dabydeen on 2014-10-06.
//  Copyright (c) 2014 Michael Dabydeen. All rights reserved.
//

import UIKit

class ViewController: UIViewController, IMDBAPIControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet var titleLabel        : UILabel?
    @IBOutlet var subtitleLabel     : UILabel?
    @IBOutlet var tomatoLabel       : UILabel?
    @IBOutlet var releasedLabel     : UILabel?
    @IBOutlet var ratingsLabel      : UILabel?
    @IBOutlet var plotLabel         : UILabel?
    @IBOutlet var posterImageView   : UIImageView?
    @IBOutlet var imdbSearchBar     : UISearchBar?
    
    lazy var apiController : IMDBAPIController = IMDBAPIController( delegate: self )

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.apiController.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: "userTappedInView:")
        
        self.view.addGestureRecognizer(tapGesture)
        
        self.formatLabels(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func didFinishIMDBSearch(result: Dictionary<String, String>) {
        
        
        self.formatLabels(false)
        
        if let foundTitle = result["Title"]{
            
            self.parseTitleFromSubtitle(foundTitle)
            
        }
        
        if let foundTomato = result["tomatoMeter"] {
            
            self.tomatoLabel!.text = foundTomato + "%"
            
        }
        
        if let foundReleased = result["Released"]{
            self.releasedLabel!.text    = "Released: " + foundReleased
        }
        
        if let foundRating = result["Rated"]{
            self.ratingsLabel!.text     = "Rated: " + foundRating

        }
        
        self.plotLabel!.text        = result["Plot"]
        
        if let foundPosterUrl = result["Poster"]?
        {
            self.formatImageFromPath(foundPosterUrl)
        }
    }
    
    func formatLabels(firstLaunch: Bool){
        
        var labelsArray = [self.titleLabel, self.subtitleLabel, self.tomatoLabel, self.releasedLabel, self.ratingsLabel, self.plotLabel]
        
        if (firstLaunch){
            for label in labelsArray {
                label?.text = ""
            }
        }
        
        for label in labelsArray {
            
            if let labelFound = label{
                
                labelFound.textAlignment = .Center
                
                switch labelFound {
                    
                case self.titleLabel!:
                    labelFound.font = UIFont(name: "Avenir Next", size: 24)
                    
                case self.subtitleLabel!:
                    labelFound.font = UIFont(name: "Avenir Next", size: 14)
                    
                case self.releasedLabel!:
                    labelFound.font = UIFont(name: "Avenir Next", size: 12)
                
                case self.ratingsLabel!:
                    labelFound.font = UIFont(name: "Avenir Next", size: 12)
                    
                case self.tomatoLabel!:
                    labelFound.font = UIFont(name: "AvenirNext-UltraLight", size: 48)
                    labelFound.textColor = UIColor(red: 0.984, green: 0.256, blue: 0.184, alpha: 1)
                    
                case self.plotLabel!:
                    labelFound.font = UIFont(name: "Avenir Next", size: 18)
                    
                default:
                    labelFound.font = UIFont(name: "Avenir Next", size: 14)
                    
                }

            }
            
        }
        
    }
    
    func parseTitleFromSubtitle(title: String){
        
        var index = title.findIndexOf(":")
        
        if let foundIndex = index? {
            
            var newTitle = title[0..<foundIndex]
            var subtitle = title[foundIndex + 2..<countElements(title)]
            
            self.titleLabel!.text = newTitle
            self.subtitleLabel!.text = subtitle
        }else{
            self.titleLabel!.text = title
            self.subtitleLabel!.text = ""
        }
    }
    
    func formatImageFromPath(path: String){
        
        var posterUrl                               = NSURL(string: path)
        var posterImageData                         = NSData(contentsOfURL: posterUrl)
        self.posterImageView?.layer.cornerRadius    = 100.0
        self.posterImageView!.clipsToBounds         = true
        self.posterImageView!.image                 = UIImage(data: posterImageData)
        
        if let imageToBlur = self.posterImageView!.image? {
            self.blurBackgroundUsingImage(imageToBlur)
        }
        
    }
    
    func blurBackgroundUsingImage(image: UIImage){
        
        var frame       = CGRectMake(0, 0, self.view.frame.width, self.view.frame.height)
        var imageView   = UIImageView(frame: frame)
        
        imageView.image         = image
        imageView.contentMode   = .ScaleAspectFill
        
        var blurEffect          = UIBlurEffect(style: .Light)
        var blurEffectView      = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame    = frame
        
        var transparentWhiteView = UIView(frame: frame)
        transparentWhiteView.backgroundColor = UIColor(white: 1.0, alpha: 0.30)
        
        var viewsArray = [imageView, blurEffectView, transparentWhiteView]
        
        for index in 0..<viewsArray.count {
            if let oldView = self.view.viewWithTag(index + 1){
                var oldView = self.view.viewWithTag(index + 1)
                oldView?.removeFromSuperview()
            }
            
            var viewToInsert = viewsArray[index]
            self.view.insertSubview(viewToInsert, atIndex: index + 1)
            viewToInsert.tag = index + 1
        }
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        //Search Imdb
        self.apiController.searchIMDB(searchBar.text)
        
        //Hide the keyboard after user search
        searchBar.resignFirstResponder()
        
        //Reset the search bar 
        searchBar.text = ""
        
    }
    
    func userTappedInView(recognizer: UITapGestureRecognizer){
        self.imdbSearchBar!.resignFirstResponder()
    }
    

}

