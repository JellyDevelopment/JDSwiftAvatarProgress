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


public class JDAvatarProgress: UIImageView, NSURLSessionTaskDelegate, NSURLSessionDownloadDelegate {

    public typealias JDAvatarCompletionBlock = (image: UIImage?, error: NSError?) -> Void
    
    public var placeholderImage : UIImage!{
        
        didSet{
            
            self.image = self.placeholderImage
        }
    }

    public var urlSession : NSURLSession?
    
    public var downloadTask : NSURLSessionDownloadTask!
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
        let outer : CGRect = CGRectInset(self.bounds, CGFloat(self.tickness/2.0), CGFloat(self.tickness/2.0))
        
        let outerPath: UIBezierPath = UIBezierPath(arcCenter: CGPointMake(CGRectGetMidX(outer), CGRectGetMidY(outer)), radius: self._radius(), startAngle: CGFloat(-M_PI_2), endAngle: CGFloat(2.0 * M_PI - M_PI_2), clockwise: true)
        
        self.spinLayer?.path = outerPath.CGPath
        self.spinLayer?.frame = bounds
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.mainScreen().scale)
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
        
        self.setImageWithURL(url!, placeholder: nil, progressBarColor: nil, progressBarLineWidth: self.progressBarLineWidth, borderColor:nil, borderWidth: self.borderWidth, completion: nil)
    }
    
    public func setImageWithURL(urlImage : NSURL){
        
        self.setImageWithURL(urlImage, placeholder: nil, progressBarColor: nil, progressBarLineWidth: self.progressBarLineWidth, borderColor: nil, borderWidth: self.borderWidth, completion: nil)
    }
    
    public func setImageWithURL(urlImage : NSURL, placeholder : UIImage){
     
        self.setImageWithURL(urlImage, placeholder: placeholder, progressBarColor: nil, progressBarLineWidth: self.progressBarLineWidth, borderColor: nil, borderWidth: self.borderWidth, completion: nil)

    }
    
    public func setImageWithURL(urlImage : NSURL, placeholder : UIImage, completion : JDAvatarCompletionBlock ){
        
        self.setImageWithURL(urlImage, placeholder: placeholder, progressBarColor: nil, progressBarLineWidth: self.progressBarLineWidth, borderColor: nil, borderWidth: self.borderWidth, completion: completion)

    }

    public func setImageWithURL(urlImage : NSURL, placeholder : UIImage?, progressBarColor: UIColor?, progressBarLineWidth: Double, completion : JDAvatarCompletionBlock? ){
        
        self.setImageWithURL(urlImage, placeholder: placeholder, progressBarColor: progressBarColor, progressBarLineWidth: progressBarLineWidth, borderColor: nil, borderWidth: self.borderWidth, completion: completion)
    }
    
    public func setImageWithURL(urlImage : NSURL, placeholder : UIImage?, progressBarColor: UIColor?, progressBarLineWidth: Double, borderColor: UIColor?, borderWidth: Double, completion : JDAvatarCompletionBlock? ){
        
        if (self.downloadTask != nil && self.downloadTask.state == NSURLSessionTaskState.Running ){
            
            self._dismissProgressBar()
            
            self.downloadTask.cancelByProducingResumeData({ (data) -> Void in
                
                self.downloadTask = nil
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in

                    self.setImageWithURL(urlImage, placeholder: placeholder, progressBarColor: progressBarColor, progressBarLineWidth: progressBarLineWidth, borderColor: borderColor, borderWidth: borderWidth, completion: completion)
                    
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
            
            self.downloadTask = self.urlSession!.downloadTaskWithURL(urlImage)
            self.downloadTask.resume()
        }
    }
    

    // MARK: NSURLSession Delegate Methods
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        if (error != nil) {
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if task.state != NSURLSessionTaskState.Completed {
                    
                    self._dismissProgressBar()
                }
                
                if (self.completionBlock != nil ) {
                    
                    self.completionBlock(image: nil, error: error)
                }
            })
        }

        
    }
  public   
    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            let value : Double = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
           
            self._setProgress(value, animated:true)
        
        }
        
    }
    
    public func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
    
        let data : NSData = NSData(contentsOfURL: location)!
        let imageObtained : UIImage = UIImage(data: data)!
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            
            self._setProgress(1.0, animated: false)
            self._dismissProgressBar()
            
            UIView.transitionWithView(self, duration: 0.3, options: UIViewAnimationOptions.TransitionCrossDissolve,
                animations: { () -> Void in
                    
                    self.image = imageObtained
                
                },
                completion: { (finished) -> Void in })
            
            if (self.completionBlock != nil) {
                
                self.completionBlock(image:imageObtained, error: nil)
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

        //self.placeholderImage = UIImage(named: "empty_avatar")!
        
        self.layer.cornerRadius = CGRectGetWidth(self.frame)/2;
        self.layer.masksToBounds = true
        
        //Default values
        self.progressBarColor = UIColor.blueColor()
        self.progressBarLineWidth = JDAvatarDefaultProgressBarLineWidth
        self.tickness = 1.0
        self.borderColor = UIColor(white: 0.9, alpha: 1.0)
        self.borderWidth = JDAvatarDefaultBorderWidth
        
        self.urlSession =  NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: self,
            delegateQueue: NSOperationQueue.mainQueue())
        
    }
    
    func _radius() -> CGFloat{
        
        let r : CGRect = CGRectInset(self.bounds, CGFloat(self.tickness/2.0), CGFloat(self.tickness/2.0))
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
        self.spinLayer!.strokeColor = self.progressBarColor!.CGColor
        self.spinLayer!.fillColor    = UIColor.clearColor().CGColor
        self.spinLayer!.lineWidth    = CGFloat(self.progressBarLineWidth!)
        self.spinLayer!.strokeEnd    = CGFloat(self.progress)
        
        self.layer.addSublayer(self.spinLayer!)
    }
    
    func _drawBorder(){
        
        if (self.borderWidth != nil && self.borderColor != nil) {
            
            self.layer.borderColor = self.borderColor!.CGColor
            self.layer.borderWidth = CGFloat(self.borderWidth)
        }
        
        self.setNeedsDisplay()
    }

    
}
