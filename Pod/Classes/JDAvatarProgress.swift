//
//  JDAvatarProgress.swift
//  JDAvatarProgress
//
//  Created by David López Carrascal on 17/10/15.
//  Copyright © 2015 David López Carrascal. All rights reserved.
//

import UIKit
import QuartzCore

public let JDAvatarDefaultProgressBarLineWidth = 10.0
public let JDAvatarDefaultBorderWidth = 5.0


public class JDAvatarProgress: UIImageView, URLSessionTaskDelegate, URLSessionDownloadDelegate {
    
    public typealias JDAvatarCompletionBlock = (_ image: UIImage?, _ error: Error?) -> Void
    
    public var placeholderImage : UIImage!{
        
        didSet{
            
            self.image = self.placeholderImage
        }
    }
    
    public var urlSession : URLSession?
    public var downloadTask : URLSessionDownloadTask!
    public var spinLayer : CAShapeLayer?
    public var progress : Double!
    public var tickness : Double!
    public var completionBlock : JDAvatarCompletionBlock!
    
    // -----------------------------
    // Customization Progress
    // -----------------------------
    
    public var progressBarColor : UIColor?{
        
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    public var progressBarLineWidth : Double!{
        
        didSet{
            if self.borderWidth != nil {
                
                self.progressBarLineWidth = self.progressBarLineWidth! + self.borderWidth!
                self.setNeedsDisplay()
            }
        }
    }
    
    // -----------------------------
    // Customization Border
    // -----------------------------
    
    public var borderColor : UIColor?{
        
        didSet{
            self._drawBorder()
        }
    }
    
    public var borderWidth : Double!{
        
        didSet{
            self._drawBorder()
        }
    }
    
    override public func awakeFromNib() {
        self._commonInit()
    }
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        let bounds : CGRect = self.bounds
        let outer : CGRect = self.bounds.insetBy(dx: CGFloat(self.tickness/2.0), dy: CGFloat(self.tickness/2.0))
        
        let outerPath: UIBezierPath = UIBezierPath(arcCenter: CGPoint(x: outer.midY, y: outer.midY), radius: self._radius(), startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(2.0 * M_PI - M_PI_2), clockwise: true)
        
        self.spinLayer?.path = outerPath.cgPath
        self.spinLayer?.frame = bounds
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        UIGraphicsEndImageContext()
        
        
    }
    
    public func addBorderWithColor(color: UIColor?, width: Double){
        
        if(color != nil){
            
            self.borderColor = color
        }
        
        self.borderWidth = width
    }
    
    // MARK: Setters
    
    public func setImageWithURLString(urlString : String){
        
        let url = NSURL(string: urlString)
        
        self.setImageWithURL(urlImage: url!, placeholder: nil, progressBarColor: nil, progressBarLineWidth: self.progressBarLineWidth, borderColor:nil, borderWidth: self.borderWidth, completion: nil)
    }
    
    public func setImageWithURL(urlImage : NSURL){
        
        self.setImageWithURL(urlImage: urlImage, placeholder: nil, progressBarColor: nil, progressBarLineWidth: self.progressBarLineWidth, borderColor: nil, borderWidth: self.borderWidth, completion: nil)
    }
    
    public func setImageWithURL(urlImage : NSURL, placeholder : UIImage){
        
        self.setImageWithURL(urlImage: urlImage, placeholder: placeholder, progressBarColor: nil, progressBarLineWidth: self.progressBarLineWidth, borderColor: nil, borderWidth: self.borderWidth, completion: nil)
        
    }
    
    public func setImageWithURL(urlImage : NSURL, placeholder : UIImage, completion : @escaping JDAvatarCompletionBlock ){
        
        self.setImageWithURL(urlImage: urlImage, placeholder: placeholder, progressBarColor: nil, progressBarLineWidth: self.progressBarLineWidth, borderColor: nil, borderWidth: self.borderWidth, completion: completion)
        
    }
    
    public func setImageWithURL(urlImage : NSURL, placeholder : UIImage?, progressBarColor: UIColor?, progressBarLineWidth: Double, completion : JDAvatarCompletionBlock? ){
        
        self.setImageWithURL(urlImage: urlImage, placeholder: placeholder, progressBarColor: progressBarColor, progressBarLineWidth: progressBarLineWidth, borderColor: nil, borderWidth: self.borderWidth, completion: completion)
    }
    
    public func setImageWithURL(urlImage : NSURL, placeholder : UIImage?, progressBarColor: UIColor?, progressBarLineWidth: Double, borderColor: UIColor?, borderWidth: Double, completion : JDAvatarCompletionBlock? ){
        
        if (self.downloadTask != nil && self.downloadTask.state == URLSessionTask.State.running ){
            
            self._dismissProgressBar()
            
            self.downloadTask.cancel(byProducingResumeData: { (data) -> Void in
                
                self.downloadTask = nil
                
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    self.setImageWithURL(urlImage: urlImage, placeholder: placeholder, progressBarColor: progressBarColor, progressBarLineWidth: progressBarLineWidth, borderColor: borderColor, borderWidth: borderWidth, completion: completion)
                    
                })
            })
            
        } else {
            
            if (placeholder != nil) {
                self.placeholderImage = placeholder
            }
            
            if (completion != nil) {
                self.completionBlock = completion
            }
            
            if (progressBarColor != nil){
                self.progressBarColor = progressBarColor
            }
            
            if (borderColor != nil) {
                
                self.borderColor = borderColor
            }
            
            self.progressBarLineWidth = progressBarLineWidth
            self.borderWidth = borderWidth
            
            self.progress = 0.0
            self._initalizateProgressBar()
            
            self.downloadTask = self.urlSession!.downloadTask(with: urlImage as URL)
            self.downloadTask.resume()
        }
    }
    
    
    // MARK: NSURLSession Delegate Methods
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        
        
        if (error != nil) {
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                if task.state != URLSessionTask.State.completed {
                    
                    self._dismissProgressBar()
                }
                
                if (self.completionBlock != nil ) {
                    
                    self.completionBlock(nil, error)
                }
            })
        }
        
        
    }
    
    
    
    public
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        
        DispatchQueue.main.async() { () -> Void in
            
            let value : Double = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            
            self._setProgress(progress: value, animated:true)
            
        }
        
    }
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let data : NSData = NSData(contentsOf: location as URL)!
        let imageObtained : UIImage = UIImage(data: data as Data)!
        
        DispatchQueue.main.async() { () -> Void in
            
            self._setProgress(progress: 1.0, animated: false)
            self._dismissProgressBar()
            
            UIView.transition(with: self, duration: 0.3, options: UIViewAnimationOptions.transitionCrossDissolve,
                              animations: { () -> Void in
                                
                                self.image = imageObtained
                                
                },
                              completion: { (finished) -> Void in })
            
            if (self.completionBlock != nil) {
                
                self.completionBlock(imageObtained, nil)
            }
        }
    }
    
    
    // MARK: Private Methods
    
    
    func _setProgress(progress:Double, animated:Bool){
        
        let currentProgress : Double = self.progress
        self.progress = Double(progress)
        
        CATransaction.begin()
        
        if (animated) {
            
            let delta : Double = fabs(self.progress - currentProgress)
            
            CATransaction.setAnimationDuration(max(0.2, delta * 1.0))
            
        } else {
            
            CATransaction.setDisableActions(true)
            
        }
        
        //Añadido
        if self.spinLayer == nil{
            
            self._initalizateProgressBar()
        }
        
        self.spinLayer?.strokeEnd = CGFloat(self.progress)
        CATransaction.commit()
        
    }
    
    func _dismissProgressBar(){
        
        self.spinLayer?.removeFromSuperlayer()
        self.spinLayer = nil
    }
    
    func _commonInit(){
        
        self.layer.cornerRadius = self.frame.width/2;
        self.layer.masksToBounds = true
        
        //Default values
        self.progressBarColor = UIColor.blue
        self.progressBarLineWidth = JDAvatarDefaultProgressBarLineWidth
        self.tickness = 1.0
        self.borderColor = UIColor(white: 0.9, alpha: 1.0)
        self.borderWidth = JDAvatarDefaultBorderWidth
        self.urlSession = URLSession(configuration: URLSessionConfiguration.default,
                                     delegate: self,
                                     delegateQueue: OperationQueue.main)
        
    }
    
    func _radius() -> CGFloat{
        
        let r : CGRect = self.bounds.insetBy(dx: CGFloat(self.tickness/2.0), dy: CGFloat(self.tickness/2.0))
        let w = r.size.width
        let h = r.size.height
        
        if (w > h) {
            
            return h / 2.0
        }
        
        return w / 2.0
        
    }
    
    func _initalizateProgressBar(){
        
        if (self.spinLayer != nil){
            
            self._dismissProgressBar()
        }
        
        self.spinLayer = CAShapeLayer(layer: layer)
        self.spinLayer!.lineCap = "round"
        self.spinLayer!.strokeColor = self.progressBarColor!.cgColor
        self.spinLayer!.fillColor    = UIColor.clear.cgColor
        self.spinLayer!.lineWidth    = CGFloat(self.progressBarLineWidth!)
        self.spinLayer!.strokeEnd    = CGFloat(self.progress)
        
        self.layer.addSublayer(self.spinLayer!)
    }
    
    func _drawBorder(){
        
        if (self.borderWidth != nil && self.borderColor != nil) {
            
            self.layer.borderColor = self.borderColor!.cgColor
            self.layer.borderWidth = CGFloat(self.borderWidth)
        }
        
        self.setNeedsDisplay()
    }
    
    
}
