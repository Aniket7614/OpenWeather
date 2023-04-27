//
//  CityViewViewModel.swift
//  OpenWeather
//
//  Created by Halcyon Tek on 26/04/23.
//

import SwiftUI
import CoreLocation

final class CityViewViewModel: ObservableObject {
    
    @Published var weather = WeatherResponse.empty()
    
    @Published var city: String = "San Francisco" {
        didSet {
            getLocation()
        }
    }
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    private lazy var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh a"
        return formatter
    }()
    
    init() {
        getLocation()
    }
    
    var date: String {
        return dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(weather.current.dt)))
    }
    
    var weatherIcon: String {
        if weather.current.weather.count > 0 {
            return weather.current.weather[0].icon
        }
        return "sun.max.fill"
    }
    
    var temperature: String {
        return getTempFor(temp: weather.current.temp)
    }
    
    var conditions: String {
        if weather.current.weather.count > 0 {
            return weather.current.weather[0].main
        }
        return ""
    }
    
    var windSpeed: String {
        return String(format: "%0.1f", weather.current.wind_speed)
    }
    
    var humidity: String {
        return String(format: "%d%%", weather.current.humidity)
    }
    
    var rainChances: String {
        return String(format: "%0.0f%%", weather.current.dew_point)
    }
    
    func getTimeFor(timestamp: Int) -> String {
        return timeFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
    }
    
    func getTempFor(temp: Double) -> String {
        return String(format: "%0.1f", temp)
    }
    
    func getDayFor(timestamp: Int) -> String {
        return dayFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(timestamp)))
    }
    
    private func getLocation() {
        CLGeocoder().geocodeAddressString(city) { (placemark, error) in
            if let places = placemark, let place = places.first {
                self.getWeather(coord: place.location?.coordinate)
            }
        }
    }
    
    private func getWeather(coord: CLLocationCoordinate2D?) {
        if let coord = coord {
            let urlString = API.getURLFor(lat: coord.latitude, lon: coord.longitude)
            getWeatherInternal(city: city, for: urlString)
        }else {
            let urlString = API.getURLFor(lat: 34.5486, lon: -121.9886)
            getWeatherInternal(city: city, for: urlString)

        }
    }
    
    private func getWeatherInternal(city: String, for urlString: String) {
        NetworkManager<WeatherResponse>.fetch(for: URL(string: urlString)!) { (result) in
            
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    self.weather = response
                }
                
            case .failure(let err):
                print(err)
            }
        }
        
        func getLottieAnimationsFor(icon: String) -> String {
            switch icon {
             case "01d":
                 return "dayClearSky"
             case "01n":
                 return "nightClearSky"
             case "02d":
                 return "dayFewClouds"
             case "02n":
                 return "nightFewClouds"
             case "03d":
                 return "dayScatteredClouds"
             case "03n":
                 return "nightScatteredClouds"
             case "04d":
                 return "dayBrokenClouds"
             case "04n":
                 return "nightBrokenClouds"
             case "09d":
                 return "dayShowerRains"
             case "09n":
                 return "nightShowerRains"
             case "10d":
                 return "dayRain"
             case "10n":
                 return "nightRain"
             case "11d":
                 return "dayThunderstorm"
             case "11n":
                 return "nightThunderstorm"
            case "13d":
                return "daySnow"
            case "13n":
                return "nightSnow"
            case "50d":
                return "dayMist"
             default:
                 return "dayClearSky"
             }
        }
        
        func getWeatherIconFor(icon: String) -> Image {
            let lottieAnimationName = getLottieAnimationsFor(icon: icon)
            
            switch icon {
            case "01d", "02d", "03d":
                return Image(systemName: "sun.max.fill")
            case "01n", "02n", "03n":
                return Image(systemName: "moon.fill")
            case "04d", "04n", "09d", "09n":
                return Image(systemName: "cloud.fill")
            case "10d", "10n":
                return Image(systemName: "cloud.sun.rain.fill")
            case "11d", "11n":
                return Image(systemName: "cloud.bolt.rain.fill")
            case "13d", "13n":
                return Image(systemName: "snow")
            case "50d":
                return Image(systemName: "cloud.fog.fill")
            default:
                return Image(systemName: "sun.max.fill")
            }
        }

        }
    }

