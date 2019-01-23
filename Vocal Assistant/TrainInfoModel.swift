//
//  TrainInfoModel.swift
//  Vocal Assistant
//
//  Created by Andrea Bacigalupo on 23/01/19.
//  Copyright © 2019 Andrea Bacigalupo. All rights reserved.
//

import Foundation

struct TrainInfoModel: Codable {
    var number: Int = 0
    
    var startStation: String = ""
    var endStation: String = ""
    
    var lastTime: TimeInterval = 0
    var lastStation: String = ""
    
    var delay: Int = 0
    
    init?(json: [String: Any]) {
        guard let number = json["numeroTreno"] as? Int,
            let startStation = json["origine"] as? String,
            let endStation = json["destinazione"] as? String,
            let lastWatch = json["oraUltimoRilevamento"] as? TimeInterval,
            let lastStationWatch = json["stazioneUltimoRilevamento"] as? String,
            let delay = json["ritardo"] as? Int else {
                return nil
        }
    }
}
