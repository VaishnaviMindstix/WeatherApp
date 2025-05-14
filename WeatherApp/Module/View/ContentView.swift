//
//  ContentView.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 09/05/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var presenter: WeatherPresenter
    @State private var isNight: Bool = false
    
    var body: some View {
        ZStack{
            BackgroundView(topColor: isNight ? Color("BlackColor") : Color("BlueColor"),
                           midColor: isNight ? Color("GreyColor") : Color("LightBlueColor"),
                           bottommColor: isNight ? Color("LightGreyColor") : Color("WhiteBlueColor"))
            VStack{
                Spacer()
                CityNameView(cityName: "Pune, MH")
                
                VStack(spacing: 4){
                    MainWeatherStatusView(imageName: presenter.symbolNameText,
                                          temp: presenter.tempText)
                    Spacer()
                    HStack(spacing: 20){
                        ForEach(isNight ? presenter.forecastNight : presenter.forecastDay) { day in
                            WeatherDayView(dayOfWeek: day.day,
                                           imageName: day.symbolName,
                                           temp: day.temp, isNight: $isNight)
                        }
//                        WeatherDayView(dayOfWeek: "SAT",
//                                       imageName: isNight ? "cloud.moon.rain.fill" : "cloud.sun.rain.fill",
//                                       temp: isNight ? 18 : 26, isNight: $isNight)
//                        WeatherDayView(dayOfWeek: "SUN",
//                                       imageName: isNight ? "cloud.bolt.rain.fill" : "cloud.bolt.rain.fill",
//                                       temp: isNight ? 14 : 26, isNight: $isNight)
//                        WeatherDayView(dayOfWeek: "MON",
//                                       imageName: isNight ? "cloud.rain.fill" : "cloud.rain.fill",
//                                       temp: isNight ? 18 : 28, isNight: $isNight)
//                        WeatherDayView(dayOfWeek: "TUES",
//                                       imageName: isNight ? "moon.fill" : "sun.max.fill",
//                                       temp: isNight ? 22 : 30, isNight: $isNight)
                        
                    }
                    Spacer()
                    Button{
                        isNight.toggle()
                        print("Button Pressed")
                    } label: {
                        WeatherButton(title: "Change Day Time", backgroundColor: isNight ? Color("BlackColor") : Color("BlueColor"), textColor: Color.white)
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            presenter.interactor?.fetchWeather()
            isNight = presenter.isNight
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(presenter: WeatherPresenter())
    }
}

struct WeatherDayView: View{
    var dayOfWeek: String
    var imageName: String
    var temp: String
    @Binding var isNight:Bool
    var body: some View{
        VStack{
            Text(dayOfWeek)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.white)
            Image(systemName: imageName)
//                .renderingMode(.original)
                .symbolRenderingMode(.multicolor)
                .resizable()
//                .foregroundStyle(isNight ? .pink : .yellow) //.hierarchical // .monochrome
//                .foregroundStyle(isNight ? .white : .white, isNight ? .gray : .yellow, isNight ? .yellow : .blue)  //.pallete
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
            Text(temp)
                .font(.system(size: 28, weight: .medium, design: .default))
                .foregroundColor(.white)
        }
    }
}

struct BackgroundView: View{
    var topColor:Color
    var midColor:Color
    var bottommColor:Color
    
    var body: some View{
        LinearGradient(colors: [topColor, midColor, bottommColor], startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}

struct CityNameView: View{
    var cityName:String
    
    var body: some View{
        Text(cityName)
            .font(.system(size: 40, weight: .medium, design: .default))
            .foregroundColor(.white)
            .padding()
    }
}

struct MainWeatherStatusView: View{
    var imageName: String
    var temp: String
    
    var body: some View{
        Image(systemName: imageName)
            .renderingMode(.original)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 180, height: 180)
        Text(temp)
            .font(.system(size: 70, weight: .medium, design: .default))
            .foregroundColor(.white)
    }
}



