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
    
    
    

}
