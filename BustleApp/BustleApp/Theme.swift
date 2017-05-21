/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation
import UIKit

enum Theme: String {
    
    case light, dark, Dark, Light

    static let allValues = [light, dark]

    var mainColor: UIColor {
        switch self {
        case .light: return UIColor.white
        case .dark : return UIColor(red: 47, green: 73, blue: 98, opacity: 1)
        default: return UIColor(red: 47, green: 73, blue: 98, opacity: 1)
        }
    }

    var secondaryColor: UIColor {
        switch self {
        case .light: return UIColor.white
        case .dark: return UIColor(red: 21, green: 35, blue: 51, opacity: 1)
        default: return UIColor(red: 21, green: 35, blue: 51, opacity: 1)
        }
    }

    var fontColor: UIColor {
        switch self {
        case .light: return UIColor.black
        case .dark : return UIColor.white
        default: return UIColor.white
        }
    }

    var navBarColor: UIColor {
        switch self {
        case .light: return UIColor(red: 247, green: 247, blue: 247, opacity: 0.82)
        case .dark : return UIColor(red: 18, green: 38, blue: 57, opacity: 1)
        default: return UIColor(red: 18, green: 38, blue: 57, opacity: 1)
        }
    }

    var navBarTitleColor: UIColor {
        switch self {
        case .light: return UIColor.black
        case .dark : return UIColor(red: 15, green: 155, blue: 228, opacity: 1)
        default: return UIColor(red: 15, green: 155, blue: 228, opacity: 1)
        }
    }
}

let selectedTheme = "Selected Theme"

struct ThemeManager {

    static let accessoryColor = UIColor(red: 15, green: 155, blue: 228, opacity: 1)

    static let placeHolderColor = UIColor(red: 189, green: 189, blue: 189, opacity: 0.5)

    static func currentTheme() -> Theme {
        return .dark
    }

    static func switchTheme() {
        applyTheme(theme: .dark)
    }

    static func setupStyling() {
        UIView.appearance().backgroundColor = UIColor.clear
        UITableView.appearance().backgroundColor = UIColor.clear
        UITableViewCell.appearance().backgroundColor = UIColor.clear
        CustomButton.appearance().backgroundColor = accessoryColor
    }
    
    static func applyTheme(theme: Theme) {
        UserDefaults.standard.set("dark", forKey: selectedTheme)
        UserDefaults.standard.synchronize()

        // Setup Navigation Bar
        UINavigationBar.appearance().barTintColor = theme.navBarColor
        UINavigationBar.appearance().tintColor = accessoryColor
        UINavigationBar.appearance().titleTextAttributes =
            [ NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 17)!,
              NSForegroundColorAttributeName: ThemeManager.currentTheme().navBarTitleColor]

        UITableViewCell.appearance().textLabel?.textColor = ThemeManager.currentTheme().fontColor

        resetViews()
    }

    static func replaceGradient(inView: UIView) {

        for layer in inView.layer.sublayers! {
            if layer is CAGradientLayer {
                (layer as? CAGradientLayer)!.removeFromSuperlayer()
                break
            }
        }
        // Set Background Theme
        let gradientLayer = CAGradientLayer()

        gradientLayer.frame = inView.bounds
        gradientLayer.locations = [0.0, 1]
        gradientLayer.colors = [ ThemeManager.currentTheme().mainColor.cgColor,
                                 ThemeManager.currentTheme().secondaryColor.cgColor]

        inView.backgroundColor = UIColor.clear
        let backgroundLayer = gradientLayer
        backgroundLayer.frame = inView.frame
        inView.layer.insertSublayer(backgroundLayer, at: 0)
    }

    static func resetViews() {
        let windows = UIApplication.shared.windows as [UIWindow]
        for window in windows {
            let subviews = window.subviews as [UIView]
            for v in subviews {
                v.removeFromSuperview()
                window.addSubview(v)
            }
        }
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, opacity: Double) {
        self.init(red  : CGFloat(red)/255,
                  green: CGFloat(green)/255,
                  blue : CGFloat(blue)/255,
                  alpha: CGFloat(opacity))
    }
}

class CustomButton: UIButton {}
