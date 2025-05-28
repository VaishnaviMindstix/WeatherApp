//
//  WeatherLandingView.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 09/05/25.
//

import SwiftUI

@available(iOS 14.0, *)
public struct WeatherLandingView: View {
    @StateObject var presenter: WeatherPresenter
    @State private var isNight: Bool = false
    
    public var body: some View {
        NavigationView { // Step 2: Wrap in NavigationView
            ZStack{
                BackgroundView(topColor: isNight ? Color("BlackColor") : Color("BlueColor"),
                               midColor: isNight ? Color("GreyColor") : Color("LightBlueColor"),
                               bottommColor: isNight ? Color("LightGreyColor") : Color("WhiteBlueColor"))
                VStack{
                    CityNameView(cityName: presenter.cityNameText, countryName: presenter.countryNameText)
                    
                    VStack(spacing: 4){
                        Spacer()
                        MainWeatherStatusView(imageName: presenter.symbolNameText,
                                              condition: presenter.conditionText,
                                              temp: presenter.tempText,
                                              date: presenter.dateText)
                        Spacer()
                        HStack(){
                            if isNight{
                                if let forecastNight = presenter.forecastNight{
                                    ForEach(forecastNight) { night in
                                        WeatherDayView(dayOfWeek: night.day,
                                                       imageName: night.symbolName,
                                                       temp: night.temp, condition: night.condition, conditionId: night.conditionId, isNight: $isNight)
                                    }
                                }
                            }else{
                                if let forecastDay = presenter.forecastDay{
                                    ForEach(forecastDay) { day in
                                        WeatherDayView(dayOfWeek: day.day,
                                                       imageName: day.symbolName,
                                                       temp: day.temp, condition: day.condition, conditionId: day.conditionId, isNight: $isNight)
                                    }
                                    
                                }
                            }
                        }
                        .padding()
                        Spacer()
                        Button{
                            isNight.toggle()
                            print("Button Pressed")
                        } label: {
                            WeatherButton(title: "Change\nDay Time", backgroundColor: isNight ? Color("BlackColor") : Color("BlueColor"), textColor: Color.white, height: 80)
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
}

@available(iOS 14.0, *)
struct WeatherLandingView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherLandingView(presenter: WeatherPresenter())
    }
}

@available(iOS 14.0, *)
struct WeatherDayView: View{
    var dayOfWeek: String
    var imageName: String
    var temp: String
    var condition: String
    var conditionId: Int
    @Binding var isNight:Bool
    var body: some View{
        VStack{
            Text(dayOfWeek)
                .font(.system(size: 16, weight: .medium, design: .default))
                .foregroundColor(.white)
            if #available(iOS 15.0, *) {
                Image(systemName: imageName)
                    .symbolRenderingMode(.multicolor)
                    .resizable()
                //                .foregroundStyle(isNight ? .pink : .yellow) //.hierarchical // .monochrome
                //                .foregroundStyle(isNight ? .white : .white, isNight ? .gray : .yellow, isNight ? .yellow : .blue)  //.pallete
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            } else {
                Image(systemName: imageName)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40, height: 40)
            }
            Text(condition)
                .font(.system(size: 10, weight: .regular, design: .default))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            Spacer()
            Text(temp)
                .font(.system(size: 28, weight: .medium, design: .default))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding([.top,.bottom])
        .background(isNight ? Color("BlackColor").opacity(0.2) : Color("BlueColor").opacity(0.2))
        .cornerRadius(8)
    }
}

@available(iOS 14.0, *)
struct BackgroundView: View{
    var topColor:Color
    var midColor:Color
    var bottommColor:Color
    
    var body: some View{
        LinearGradient(colors: [topColor, midColor, bottommColor], startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
    }
}

@available(iOS 14.0, *)
struct CityNameView: View{
    var cityName:String
    var countryName:String
    
    var body: some View{
        Text("\(cityName) \(countryName)")
            .font(.system(size: 40, weight: .medium, design: .default))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
    }
}

@available(iOS 14.0, *)
struct MainWeatherStatusView: View{
    var imageName: String
    var condition: String
    var temp: String
    var date: String
    
    var body: some View{
        VStack{
            Text(date)
                .font(.system(size: 24, weight: .regular, design: .default))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            Image(systemName: imageName)
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160, height: 160)
            Text(condition.capitalized)
                .font(.system(size: 40, weight: .regular, design: .default))
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
            Text(temp)
                .font(.system(size: 60, weight: .medium, design: .default))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
    }
}




