//
//  API+Extensions.swift
//  OpenWeather
//
//  Created by Halcyon Tek on 26/04/23.
//

import Foundation

extension API {
    static let baseURLString = "https://api.openweathermap.org/data/2.5/"
    
    static func getURLFor(lat: Double, lon: Double) -> String {
        return "\(baseURLString)onecall?lat=\(lat)&lon=\(lon)&exclude=minutely&appid=\(key)&units=imp"
    }
}
