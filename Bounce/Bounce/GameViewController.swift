//
//  GameViewController.swift
//  Bounce
//
//  Created by Stanislav Tereshchenko on 26.12.2023.
//

import UIKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var bnc_circleView: UIImageView!
    @IBOutlet weak var bnc_startGameButton: UIButton!
    @IBOutlet weak var bnc_blurView: UIView!
    @IBOutlet weak var bnc_minusBtnView: UIView!
    @IBOutlet weak var bnc_plusBtnView: UIView!
    @IBOutlet weak var bnc_downView: UIView!
    
    @IBOutlet weak var bnc_lifesLabel: UILabel!
    var obstacles: [UIView] = []
    var timers: [Timer] = []
    var passedObstaclesCount = 0
    var obstacleSpacing: CGFloat = 50.0
    var lifeCounter = 5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setPulseAnimation_gt()
        setUpDownView()
        setUpBtn()
    }
    
    func setUpCircle() {
        bnc_circleView.transform = .identity
        bnc_circleView.frame = CGRect(x: (UIScreen.main.bounds.width - 70) / 2, y: (UIScreen.main.bounds.height - 70) / 2, width: 70, height: 70)
        bnc_circleView.layer.masksToBounds = false
        bnc_circleView.layer.zPosition = -1
    }
    
    func setUpBtn() {
        bnc_minusBtnView.layer.cornerRadius = bnc_minusBtnView.bounds.height / 2
        bnc_minusBtnView.setShadow()
        let downViewGesture = UITapGestureRecognizer(target: self, action: #selector(downShift))
        self.bnc_minusBtnView.addGestureRecognizer(downViewGesture)
        
        bnc_plusBtnView.layer.cornerRadius = bnc_plusBtnView.bounds.height / 2
        bnc_plusBtnView.setShadow()
        let upViewGesture = UITapGestureRecognizer(target: self, action: #selector(upShift))
        self.bnc_plusBtnView.addGestureRecognizer(upViewGesture)
    }
    @objc func downShift(_ sender:UITapGestureRecognizer) {
        self.bnc_circleView.transform = .identity
        bnc_circleView.frame.origin.y += 10
    }
    @objc func upShift(_ sender:UITapGestureRecognizer) {
        self.bnc_circleView.transform = .identity
        bnc_circleView.frame.origin.y -= 10
    }
    
    
    @IBAction func startGame(_ sender: Any) {
        bnc_blurView.isHidden = true
        bnc_lifesLabel.text = "Lives: \(lifeCounter)"
        startGame()
    }
    
    
    func setPulseAnimation_gt(){
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.duration = 1
        pulseAnimation.toValue = 1.0
        pulseAnimation.fromValue = 0.79
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = Float.infinity
        bnc_startGameButton.layer.add(pulseAnimation, forKey: "pulse")
    }
    
    func setUpDownView() {
        let maskPath = UIBezierPath(roundedRect: bnc_downView.bounds,
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 20, height: 20))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        bnc_downView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        bnc_downView.layer.mask = maskLayer
    }
    
    @objc func createObstacle() {
        let obstacleWidth: CGFloat = 40.0
        
        let obstacleSpacing = max(100, CGFloat.random(in: 100...200))
        
        let lastObstacle = obstacles.last
        let obstacleX = lastObstacle?.frame.maxX ?? view.frame.width
        
        let obstacleHeightTop: CGFloat = CGFloat.random(in: 25...370)
        
        let minVerticalSpacing: CGFloat = 150.0
        let obstacleHeightBottom = max(25, view.frame.height - obstacleHeightTop - minVerticalSpacing)
        
        let obstacleTop = UIView(frame: CGRect(x: obstacleX + obstacleSpacing, y: 0, width: obstacleWidth, height: obstacleHeightTop))
        obstacleTop.backgroundColor = UIColor.red
        view.addSubview(obstacleTop)
        obstacleTop.layer.zPosition = -1
        obstacles.append(obstacleTop)
        
        let obstacleBottom = UIView(frame: CGRect(x: obstacleX + obstacleSpacing, y: view.frame.height - obstacleHeightBottom, width: obstacleWidth, height: obstacleHeightBottom))
        obstacleBottom.backgroundColor = UIColor.red
        view.addSubview(obstacleBottom)
        obstacleBottom.layer.zPosition = -1
        obstacles.append(obstacleBottom)
    }
    @objc func moveObstacles() {
        var obstaclesToRemove: [UIView] = []
        
        for obstacle in obstacles {
            obstacle.frame.origin.x -= 5
            if obstacle.frame.maxX < 0 {
                obstacle.removeFromSuperview()
                obstaclesToRemove.append(obstacle)
            }
            
            if bnc_circleView.frame.intersects(obstacle.frame) {
                endGame()
                return
            }
        }
        
        obstacles = obstacles.filter { !obstaclesToRemove.contains($0) }
        
        createObstacle()
    }
    
    func endGame() {
        stopAllTimers()
        for obstacle in obstacles {
            obstacle.removeFromSuperview()
        }
        obstacles.removeAll()
        
        lifeCounter -= 1

        if lifeCounter <= 0 {
            showGameOverAlert()
            lifeCounter = 5
        } else {
            updateLifeCounterLabel()
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        
        let alertController = UIAlertController(title: "Game Over", message: "You hit an obstacle!", preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
            self?.restartGame()
        }
        alertController.addAction(restartAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func showGameOverAlert() {
            let alertController = UIAlertController(title: "Game Over", message: "You ran out of lives!", preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart", style: .default) { [weak self] _ in
//                self?.restartGame()
                self?.bnc_blurView.isHidden = false
            }
            alertController.addAction(restartAction)

            present(alertController, animated: true, completion: nil)
        }
    
    func updateLifeCounterLabel() {
             bnc_lifesLabel.text = "Lives: \(lifeCounter)"
        }
    
    func restartGame() {
        startGame()
    }
    func stopAllTimers() {
        for timer in timers {
            timer.invalidate()
        }
        timers.removeAll()
    }
    
    @objc func rotateCircle() {
        bnc_circleView.transform = bnc_circleView.transform.rotated(by: .pi / 180)
    }
    
    
    func startGame() {
        setUpCircle()
        let pulseTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(rotateCircle), userInfo: nil, repeats: true)
        let obstacleCreationTimer = Timer.scheduledTimer(timeInterval: 7.0, target: self, selector: #selector(createObstacle), userInfo: nil, repeats: true)
        let obstacleMoveTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(moveObstacles), userInfo: nil, repeats: true)
        
        timers = [pulseTimer, obstacleCreationTimer, obstacleMoveTimer]
        
    }
    
}
