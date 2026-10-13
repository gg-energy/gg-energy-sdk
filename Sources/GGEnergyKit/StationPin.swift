import UIKit

/// The two colours the station markers are built from. They swap with the map
/// style: a dark pin reads on the light style and vanishes into the dark one.
struct MarkerPalette {
    let fill: UIColor
    let content: UIColor

    static func forStyle(_ style: UIUserInterfaceStyle) -> MarkerPalette {
        let ink = UIColor(red: 38 / 255, green: 38 / 255, blue: 38 / 255, alpha: 1)
        return style == .dark
            ? MarkerPalette(fill: .white, content: ink)
            : MarkerPalette(fill: ink, content: .white)
    }
}

func userLocationPin() -> UIImage {
    UIGraphicsImageRenderer(size: CGSize(width: 36, height: 36)).image { _ in
        UIColor(red: 46 / 255, green: 141 / 255, blue: 245 / 255, alpha: 0.2).setFill()
        UIBezierPath(ovalIn: CGRect(x: 2, y: 2, width: 32, height: 32)).fill()
        UIColor.white.setFill()
        UIBezierPath(ovalIn: CGRect(x: 9, y: 9, width: 18, height: 18)).fill()
        UIColor(red: 46 / 255, green: 141 / 255, blue: 245 / 255, alpha: 1).setFill()
        UIBezierPath(ovalIn: CGRect(x: 12, y: 12, width: 12, height: 12)).fill()
    }
}

// Vector paths from the customer iOS Energy marker asset.
func stationPin(palette: MarkerPalette) -> UIImage {
    UIGraphicsImageRenderer(size: CGSize(width: 25, height: 36)).image { _ in
        let path0 = UIBezierPath()
        path0.move(to: CGPoint(x: 25, y: 13.3162))
        path0.addCurve(to: CGPoint(x: 12.5, y: 35.5), controlPoint1: CGPoint(x: 25, y: 20.6706), controlPoint2: CGPoint(x: 12.5, y: 35.5))
        path0.addCurve(to: CGPoint(x: 0, y: 13.3162), controlPoint1: CGPoint(x: 12.5, y: 35.5), controlPoint2: CGPoint(x: 0, y: 20.6706))
        path0.addCurve(to: CGPoint(x: 12.5, y: 0), controlPoint1: CGPoint(x: 0, y: 5.96188), controlPoint2: CGPoint(x: 5.59644, y: 0))
        path0.addCurve(to: CGPoint(x: 25, y: 13.3162), controlPoint1: CGPoint(x: 19.4036, y: 0), controlPoint2: CGPoint(x: 25, y: 5.96188))
        path0.close()
        palette.fill.setFill()
        path0.fill()
        let path1 = UIBezierPath()
        path1.move(to: CGPoint(x: 14.9383, y: 7.05133))
        path1.addCurve(to: CGPoint(x: 15.0994, y: 7.23908), controlPoint1: CGPoint(x: 15.0117, y: 7.09389), controlPoint2: CGPoint(x: 15.0685, y: 7.16007))
        path1.addCurve(to: CGPoint(x: 15.1085, y: 7.48633), controlPoint1: CGPoint(x: 15.1303, y: 7.3181), controlPoint2: CGPoint(x: 15.1335, y: 7.40526))
        path1.addLine(to: CGPoint(x: 13.7578, y: 11.8753))
        path1.addLine(to: CGPoint(x: 16.25, y: 11.8753))
        path1.addCurve(to: CGPoint(x: 16.4561, y: 11.9369), controlPoint1: CGPoint(x: 16.3233, y: 11.8753), controlPoint2: CGPoint(x: 16.3949, y: 11.8967))
        path1.addCurve(to: CGPoint(x: 16.5945, y: 12.1017), controlPoint1: CGPoint(x: 16.5173, y: 11.9772), controlPoint2: CGPoint(x: 16.5654, y: 12.0344))
        path1.addCurve(to: CGPoint(x: 16.6195, y: 12.3153), controlPoint1: CGPoint(x: 16.6235, y: 12.1689), controlPoint2: CGPoint(x: 16.6322, y: 12.2432))
        path1.addCurve(to: CGPoint(x: 16.523, y: 12.5076), controlPoint1: CGPoint(x: 16.6068, y: 12.3875), controlPoint2: CGPoint(x: 16.5733, y: 12.4543))
        path1.addLine(to: CGPoint(x: 10.523, y: 18.8826))
        path1.addCurve(to: CGPoint(x: 10.3039, y: 18.9968), controlPoint1: CGPoint(x: 10.465, y: 18.9443), controlPoint2: CGPoint(x: 10.3877, y: 18.9846))
        path1.addCurve(to: CGPoint(x: 10.0612, y: 18.9498), controlPoint1: CGPoint(x: 10.22, y: 19.009), controlPoint2: CGPoint(x: 10.1345, y: 18.9924))
        path1.addCurve(to: CGPoint(x: 9.90052, y: 18.7621), controlPoint1: CGPoint(x: 9.98799, y: 18.9072), controlPoint2: CGPoint(x: 9.93134, y: 18.841))
        path1.addCurve(to: CGPoint(x: 9.89153, y: 18.5151), controlPoint1: CGPoint(x: 9.8697, y: 18.6831), controlPoint2: CGPoint(x: 9.86653, y: 18.5961))
        path1.addLine(to: CGPoint(x: 11.2423, y: 14.1253))
        path1.addLine(to: CGPoint(x: 8.75003, y: 14.1253))
        path1.addCurve(to: CGPoint(x: 8.54393, y: 14.0637), controlPoint1: CGPoint(x: 8.67679, y: 14.1254), controlPoint2: CGPoint(x: 8.60514, y: 14.1039))
        path1.addCurve(to: CGPoint(x: 8.4056, y: 13.899), controlPoint1: CGPoint(x: 8.48272, y: 14.0235), controlPoint2: CGPoint(x: 8.43464, y: 13.9662))
        path1.addCurve(to: CGPoint(x: 8.38055, y: 13.6853), controlPoint1: CGPoint(x: 8.37657, y: 13.8317), controlPoint2: CGPoint(x: 8.36786, y: 13.7575))
        path1.addCurve(to: CGPoint(x: 8.47703, y: 13.4931), controlPoint1: CGPoint(x: 8.39325, y: 13.6132), controlPoint2: CGPoint(x: 8.42678, y: 13.5464))
        path1.addLine(to: CGPoint(x: 14.477, y: 7.11808))
        path1.addCurve(to: CGPoint(x: 14.6959, y: 7.00395), controlPoint1: CGPoint(x: 14.535, y: 7.05643), controlPoint2: CGPoint(x: 14.6121, y: 7.01621))
        path1.addCurve(to: CGPoint(x: 14.9383, y: 7.05058), controlPoint1: CGPoint(x: 14.7796, y: 6.9917), controlPoint2: CGPoint(x: 14.8651, y: 7.00813))
        path1.addLine(to: CGPoint(x: 14.9383, y: 7.05133))
        path1.close()
        palette.content.setFill()
        path1.fill()
    }
}

/// The neutral pin used for AC stations. Its geometry matches the Figma marker.
func standardStationPin(palette: MarkerPalette) -> UIImage {
    UIGraphicsImageRenderer(size: CGSize(width: 25, height: 36)).image { _ in
        let pin = UIBezierPath()
        pin.move(to: CGPoint(x: 25, y: 13.3162))
        pin.addCurve(to: CGPoint(x: 12.5, y: 35.5), controlPoint1: CGPoint(x: 25, y: 20.6706), controlPoint2: CGPoint(x: 12.5, y: 35.5))
        pin.addCurve(to: CGPoint(x: 0, y: 13.3162), controlPoint1: CGPoint(x: 12.5, y: 35.5), controlPoint2: CGPoint(x: 0, y: 20.6706))
        pin.addCurve(to: CGPoint(x: 12.5, y: 0), controlPoint1: CGPoint(x: 0, y: 5.96188), controlPoint2: CGPoint(x: 5.59644, y: 0))
        pin.addCurve(to: CGPoint(x: 25, y: 13.3162), controlPoint1: CGPoint(x: 19.4036, y: 0), controlPoint2: CGPoint(x: 25, y: 5.96188))
        pin.close()
        palette.fill.setFill()
        pin.fill()
        palette.content.setFill()
        UIBezierPath(ovalIn: CGRect(x: 9, y: 8.5, width: 7, height: 7)).fill()
    }
}
