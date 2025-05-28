//
//  WeatherButton.swift
//  WeatherApp
//
//  Created by Vaishnavi Deshmukh on 12/05/25.
//

import SwiftUI

@available(iOS 14.0, *)
public struct WeatherButton: View{
    public var title: String
    public var backgroundColor: Color
    public var textColor: Color
    public var height: CGFloat = 60
    
    public init(title: String, backgroundColor: Color, textColor: Color, height: CGFloat) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.height = height
    }
    
    public var body: some View{
        if #available(iOS 16.0, *) {
            Text(title)
                .frame(width: 260, height: height)
                .background(backgroundColor.gradient)
                .foregroundColor(textColor)
                .font(.system(size: 24, weight: .bold, design: .default))
                .cornerRadius(height/2)
        } else {
            Text(title)
                .frame(width: 260, height: height)
                .background(backgroundColor)
                .foregroundColor(textColor)
                .font(.system(size: 24, weight: .bold, design: .default))
                .cornerRadius(height/2)
        }
    }
    
}
