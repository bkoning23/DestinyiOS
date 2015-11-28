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
    
    var statCache = [String: [String: AnyObject]]()
    
    var primaryGuardianId: String = ""
    
    func setMemberType(memberType: Int){
        self.memberType = memberType
    }
    
    func setMemberId(memberId: String){
        self.memberId = memberId
    }
    
    func setPrimaryGuardian(){
        self.primaryGuardianId = self.memberId
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
                //print("GotData")
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
                
                //print(parsedObject)
                
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
        
        //This is set to 1 if the data is 'expired', or more than 5 minutes old
        //Defaults to 1 so if there is nothing in the cache it will call API
        var expiredFlag = 1
        
        if let val = statCache[memberId]{
            print("cache hit")
            if let savedTime = val["timestamp"] as? NSDate{
                //This difference is in seconds
                if (NSDate().timeIntervalSinceDate(savedTime) < 300){
                    expiredFlag = 0
                    print("not expired")
                    if let data = val["data"] as? Dictionary<String, AnyObject>{
                        completion(allCharacterStats: data)
                    }
                }
            }
        }
        if(expiredFlag == 1){
            let url = NSURL(string: "http://www.bungie.net/Platform/Destiny/Stats/Account/\(membershipType)/\(memberId)/")
            print("APICALL getcharstats")
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
                        let tempDict = ["timestamp": NSDate(), "data": topLevelObj]
                        self.statCache[memberId] = tempDict
                        completion(allCharacterStats: topLevelObj)
                        
                    }
                    
                }
                    
                else if let error = error{
                    print("FoundError")
                    print(error.description)
                }
            })
            
            task.resume()
        }}
    
    
    
    
    
    
}
