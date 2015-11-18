//
//  RequestDelegate.swift
//  DestinyCompanion
//
//  Created by Brendan Koning on 10/18/15.
//  Copyright © 2015 Brendan Koning. All rights reserved.
//

import Foundation

public class apiRequests{
    
    
    
    class func getUserId(userName: String, completion: (userId: String)->Void){
        
        let apiKey = "5e78813d2af641428d781d921ad9a1c2"
        
        // Get ready to fetch the list of dog videos from YouTube V3 Data API.
        let url = NSURL(string: "http://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/all/\(userName)/")
        var request = NSMutableURLRequest(URL: url!)
        request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            if let data = data{
                print("GotData")
                let datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
                print(datastring)
                
                let parsedObject: AnyObject?
                do {
                    parsedObject = try NSJSONSerialization.JSONObjectWithData(data,
                        options: NSJSONReadingOptions.AllowFragments)
                } catch let error as NSError {
                    print(error)
                    return
                } catch {
                    fatalError()
                }
                
                print(parsedObject)
                
                if let topLevelObj = parsedObject as? Dictionary<String,AnyObject> {
                    if let items = topLevelObj["Response"] as? Array<Dictionary<String,AnyObject>> {
                        let memberId = (items[0]["membershipId"]) as! String
                        completion(userId: memberId)
                    }
                }
                
                }
            
            else if let error = error{
                print("FoundError")
                print(error.description)
            }
        })
        
        task.resume()

        
    }
}