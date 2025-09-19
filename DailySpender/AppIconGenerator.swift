//
//  AppIconGenerator.swift
//  DailySpender
//
//  Created by Khang Lam on 7/29/25.
//

import SwiftUI
import UIKit

struct AppIconGenerator: View {
    var body: some View {
        VStack {
            // Generate app icon
            Button("Generate App Icon") {
                generateAppIcon()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
    
    func generateAppIcon() {
        // Create a 1024x1024 app icon
        let size = CGSize(width: 1024, height: 1024)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Background gradient
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                    colors: [UIColor.systemBlue.cgColor, UIColor.systemPurple.cgColor] as CFArray,
                                    locations: [0.0, 1.0])!
            
            context.cgContext.drawLinearGradient(gradient,
                                               start: CGPoint(x: 0, y: 0),
                                               end: CGPoint(x: size.width, y: size.height),
                                               options: [])
            
            // Add a subtle overlay
            UIColor.black.withAlphaComponent(0.1).setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            
            // Create the main icon - Dollar sign with chart
            let iconSize: CGFloat = 400
            let iconRect = CGRect(x: (size.width - iconSize) / 2,
                                y: (size.height - iconSize) / 2,
                                width: iconSize,
                                height: iconSize)
            
            // Draw dollar sign
            UIColor.white.setFill()
            let dollarFont = UIFont.systemFont(ofSize: iconSize * 0.6, weight: .bold)
            let dollarAttributes: [NSAttributedString.Key: Any] = [
                .font: dollarFont,
                .foregroundColor: UIColor.white
            ]
            
            let dollarString = NSAttributedString(string: "$", attributes: dollarAttributes)
            let dollarSize = dollarString.size()
            let dollarRect = CGRect(x: iconRect.midX - dollarSize.width / 2,
                                  y: iconRect.midY - dollarSize.height / 2,
                                  width: dollarSize.width,
                                  height: dollarSize.height)
            
            dollarString.draw(in: dollarRect)
            
            // Add small chart lines
            UIColor.white.withAlphaComponent(0.8).setStroke()
            let lineWidth: CGFloat = 8
            context.cgContext.setLineWidth(lineWidth)
            context.cgContext.setLineCap(.round)
            
            // Draw ascending chart lines
            let chartStartX = iconRect.minX + 50
            let chartEndX = iconRect.maxX - 50
            let chartStartY = iconRect.maxY - 80
            let chartEndY = iconRect.minY + 80
            
            // Line 1
            context.cgContext.move(to: CGPoint(x: chartStartX, y: chartStartY))
            context.cgContext.addLine(to: CGPoint(x: chartStartX + 100, y: chartStartY - 60))
            context.cgContext.strokePath()
            
            // Line 2
            context.cgContext.move(to: CGPoint(x: chartStartX + 100, y: chartStartY - 60))
            context.cgContext.addLine(to: CGPoint(x: chartStartX + 200, y: chartStartY - 120))
            context.cgContext.strokePath()
            
            // Line 3
            context.cgContext.move(to: CGPoint(x: chartStartX + 200, y: chartStartY - 120))
            context.cgContext.addLine(to: CGPoint(x: chartEndX, y: chartEndY))
            context.cgContext.strokePath()
        }
        
        // Save the image
        if let imageData = image.pngData() {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            let imageURL = documentsPath.appendingPathComponent("DailySpender_AppIcon_1024x1024.png")
            
            do {
                try imageData.write(to: imageURL)
                print("✅ App icon generated successfully!")
                print("📁 Saved to: \(imageURL.path)")
                print("📋 Instructions:")
                print("1. Open the generated image in Preview or any image editor")
                print("2. Copy the image")
                print("3. In Xcode, go to Assets.xcassets > AppIcon")
                print("4. Drag and drop the image to the 1024x1024 slot")
            } catch {
                print("❌ Error saving app icon: \(error)")
            }
        }
    }
}

#Preview {
    AppIconGenerator()
}
