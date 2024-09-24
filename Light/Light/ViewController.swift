//
//  ViewController.swift
//  Light
//
//  Created by Stella on 9/19/24.
//

import UIKit

class ViewController: UIViewController {
    
    var lightOn = true
    var animationLayer: CAShapeLayer?
    var snakeLayers: [CAShapeLayer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        lightOn = !lightOn
        updateUI()
        animateFlare()
        animateSnakes()
    }
    
    func updateUI(){
        view.backgroundColor = lightOn ? .white : .black
    }
    
    func animateFlare() {
        // Remove previous animation layer if it exists
        animationLayer?.removeFromSuperlayer()
        
        // Create a new CAShapeLayer
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = (lightOn ? UIColor.black : UIColor.white).cgColor
        shapeLayer.opacity = 0.5
        
        // Create a circular path
        let center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        let startPath = UIBezierPath(arcCenter: center, radius: 0, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        let endPath = UIBezierPath(arcCenter: center, radius: max(view.bounds.width, view.bounds.height), startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        
        shapeLayer.path = startPath.cgPath
        
        // Add the shape layer to the view
        view.layer.addSublayer(shapeLayer)
        animationLayer = shapeLayer
        
        // Create the animation
        let animation = CABasicAnimation(keyPath: "path")
        animation.fromValue = startPath.cgPath
        animation.toValue = endPath.cgPath
        animation.duration = 0.5
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        
        // Add fade out animation
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.5
        opacityAnimation.toValue = 0
        opacityAnimation.duration = 0.5
        
        // Combine animations
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [animation, opacityAnimation]
        animationGroup.duration = 0.5
        animationGroup.fillMode = .forwards
        animationGroup.isRemovedOnCompletion = false
        
        // Add the animation to the layer
        shapeLayer.add(animationGroup, forKey: "flareAnimation")
    }
    
    
    func animateSnakes() {
            // Remove previous snake layers
            for layer in snakeLayers {
                layer.removeFromSuperlayer()
            }
            snakeLayers.removeAll()
            
            // Create new snakes
            let numberOfSnakes = 7
            for _ in 0..<numberOfSnakes {
                let snakeLayer = CAShapeLayer()
                snakeLayer.fillColor = nil
                snakeLayer.strokeColor = (lightOn ? UIColor.black : UIColor.white).cgColor
                snakeLayer.lineWidth = 7
                snakeLayer.lineCap = .round
                snakeLayer.lineJoin = .round
                
                view.layer.addSublayer(snakeLayer)
                snakeLayers.append(snakeLayer)
                
                animateSnake(snakeLayer)
            }
        }
        
        func animateSnake(_ snakeLayer: CAShapeLayer) {
            let centerX = view.bounds.midX
            let centerY = view.bounds.midY
            let maxDistance = max(view.bounds.width, view.bounds.height) / 2
            let snakeLength: CGFloat = 200  // Length of the snake
            let segmentLength: CGFloat = 5
            let oscillationFrequency: CGFloat = 0.1
            let oscillationAmplitude: CGFloat = 20
            
            var angle = CGFloat.random(in: 0...(2 * .pi))
            var points: [CGPoint] = []
            
            for i in 0...Int(maxDistance / segmentLength) {
                let distance = CGFloat(i) * segmentLength
                let oscillation = oscillationAmplitude * sin(oscillationFrequency * distance)
                
                let point = CGPoint(
                    x: centerX + distance * cos(angle) + oscillation * sin(angle),
                    y: centerY + distance * sin(angle) - oscillation * cos(angle)
                )
                
                points.append(point)
                angle += CGFloat.random(in: -0.1...0.1)
            }
            
            let path = UIBezierPath()
            path.move(to: points[0])
            for point in points.dropFirst() {
                path.addLine(to: point)
            }
            
            let totalLength = points.indices.dropFirst().reduce(0) { (result, index) in
                    return result + distanceBetween(points[index], points[index - 1])
                }
            
            snakeLayer.path = path.cgPath
            
            let drawAnimation = CAKeyframeAnimation(keyPath: "strokeEnd")
            drawAnimation.values = [0, snakeLength / totalLength, 1]
            drawAnimation.keyTimes = [0, 0.8, 1]
            drawAnimation.duration = 1.5
                
            let startAnimation = CAKeyframeAnimation(keyPath: "strokeStart")
            startAnimation.values = [0, 0, (totalLength - snakeLength) / totalLength]
            startAnimation.keyTimes = [0, 0.8, 1]
            startAnimation.duration = 1.5
                
            let fadeAnimation = CAKeyframeAnimation(keyPath: "opacity")
            fadeAnimation.values = [1, 1, 0]
            fadeAnimation.keyTimes = [0, 0.8, 1]
            fadeAnimation.duration = 1.5
                
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [drawAnimation, startAnimation, fadeAnimation]
            animationGroup.duration = 1.5
            animationGroup.fillMode = .forwards
            animationGroup.isRemovedOnCompletion = false
            
            snakeLayer.add(animationGroup, forKey: "snakeAnimation")
        }
    
    func distanceBetween(_ point1: CGPoint, _ point2: CGPoint) -> CGFloat {
        let dx = point2.x - point1.x
        let dy = point2.y - point1.y
        return sqrt(dx*dx + dy*dy)
    }
}

