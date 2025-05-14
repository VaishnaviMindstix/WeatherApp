//
//  WeatherButton.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 12/05/25.
//

import SwiftUI

struct WeatherButton: View{
    var title:String
    var backgroundColor:Color
    var textColor:Color
    
    var body: some View{
        Text(title)
            .frame(width: 260, height: 60)
            .background(backgroundColor.gradient)
            .foregroundColor(textColor)
            .font(.system(size: 24, weight: .bold, design: .default))
            .cornerRadius(30)
    }
    
}
