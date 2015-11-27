//
//  DestinyModel.swift
//  DestinyCompanion
//
//  Created by Brendan Koning on 11/27/15.
//  Copyright © 2015 Brendan Koning. All rights reserved.
//

import UIKit

public class DestinyModel{
    
    var memberType: Int = 0
    var memberId: String = ""

    var wantedStats: [String] = ["killsDeathsRatio", "winLossRatio", "bestSingleGameScore", "precisionKills", "longestKillSpree"]
    var displayText: [String] = ["K/D", "Win/Loss", "Best Single Game Score", "Precision Kills", "Longest Kill Spree"]
    var stats: [String] = []
    
    var characterStats = [String: AnyObject]()
    
    var apiKey: String = "5e78813d2af641428d781d921ad9a1c2"
    
    
    func setMemberType(memberType: Int){
        self.memberType = memberType
    }
    
    func setMemberId(memberId: String){
        self.memberId = memberId
    }
    
    func findMergedStats(statDict: Dictionary<String, AnyObject>) -> Dictionary<String, AnyObject>{
        var pvpStats = [String: AnyObject]()
        if let response = statDict["Response"] as? Dictionary<String,AnyObject> {
            if let mergedAllCharacters = response["mergedAllCharacters"] as? Dictionary<String,AnyObject>{
                if let mergedResults = mergedAllCharacters["results"] as? Dictionary<String, AnyObject>{
                    if let allPvP = mergedResults["allPvP"] as? Dictionary<String, AnyObject>{
                        if let allTime = allPvP["allTime"] as? Dictionary<String, AnyObject>{
                            pvpStats = allTime
                        }
                    }
                }
            }
        }
        return(pvpStats)
    }
    
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
    
    func getCharacterStats(memberId: String, membershipType: Int, completion: (allCharacterStats: Dictionary<String, AnyObject>)->Void){
        
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
                    completion(allCharacterStats: topLevelObj)

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
