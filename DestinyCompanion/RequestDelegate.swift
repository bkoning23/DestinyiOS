//
//  RequestDelegate.swift
//  DestinyCompanion
//
//  Created by Brendan Koning on 10/18/15.
//  Copyright © 2015 Brendan Koning. All rights reserved.
//

import Foundation

public class apiRequests{
    
    lazy var apiKey: String = "5e78813d2af641428d781d921ad9a1c2"
    
    
    func getUserId(userName: String, membershipType: Int, completion: (userId: String, error: String)->Void){
                
        let url = NSURL(string: "http://www.bungie.net/Platform/Destiny/SearchDestinyPlayer/\(membershipType)/\(userName)/")
        let request = NSMutableURLRequest(URL: url!)
        request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            if let data = data{
                print("GotData")
                /* Debug Only
                let datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
                print(datastring)
                */
                
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
                        if(items.count == 0){
                            completion(userId:" ", error: "MemberName does not exist")
                        }
                        else{
                        let memberId = (items[0]["membershipId"]) as! String
                        completion(userId: memberId, error: "None")
                        }
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
    
    func getPvPStats(memberId: String, membershipType: Int, completion: (pvpStats: Dictionary<String, AnyObject>)->Void){
        
        // Get ready to fetch the list of dog videos from YouTube V3 Data API.
        let url = NSURL(string: "http://www.bungie.net/Platform/Destiny/Stats/Account/\(membershipType)/\(memberId)/")
        let request = NSMutableURLRequest(URL: url!)
        request.addValue(apiKey, forHTTPHeaderField: "X-API-KEY")
        request.HTTPMethod = "GET"
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            if let data = data{
                /* Debug only
                print("GotData")
                let datastring = NSString(data: data, encoding: NSUTF8StringEncoding)
                print(datastring)
                */
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
                
                //print(parsedObject)
                
                if let topLevelObj = parsedObject as? Dictionary<String,AnyObject> {
                    //print(topLevelObj)
                    if let response = topLevelObj["Response"] as? Dictionary<String,AnyObject> {
                        if let mergedAllCharacters = response["mergedAllCharacters"] as? Dictionary<String,AnyObject>{
                            if let mergedResults = mergedAllCharacters["results"] as? Dictionary<String, AnyObject>{
                                if let allPvP = mergedResults["allPvP"] as? Dictionary<String, AnyObject>{
                                    if let allTime = allPvP["allTime"] as? Dictionary<String, AnyObject>{
                                        completion(pvpStats: allTime)
                                    }
                                    
                                }
                            }
                        }
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