//
//  SMAudioRecorderViewController.swift
//  AudioRecoder
//
//  Created by softman on 16/3/9.
//  Copyright © 2016年 softman. All rights reserved.
//
//  Contact me: softman123g@126.com
//  Or Star me: https://github.com/softman123g/SMAudioRecorder
//
//  1.支持录音
//  2.支持上滑取消录音
//  3.支持下滑继续录音
//


import UIKit
import AVFoundation

/*
    用于AudioRecorderViewController完成录音时的回调
*/
protocol SMAudioRecorderViewControllerDelegate: class {
    /*
        完成record时的回调
    */
    func audioRecorderFinishRecord(withFileURL fileURL: NSURL?)
}

class SMAudioRecorderViewController: UIViewController, AVAudioRecorderDelegate{
    
    // MARK: Properties
    //颜色
    let color1 = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)//#cccccc
    let color2 = UIColor(red: 55/255, green: 178/255, blue: 240/255, alpha: 1.0) //#37b2f0
    let color3 = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1) //#FFFFFF
    let color4 = UIColor(red: 32/255, green: 36/255, blue: 36/255, alpha: 1)//#202424
    let color5 = UIColor(red: 102/255, green: 102/255, blue: 102/255, alpha: 1)//#666666
    // 1+4个圆环
    private var circleViewUnrecord:UIImageView!//未录音时的第1个圆环
    private var circleView1:UIImageView!//录音时的第1个圆环
    private var circleView2:UIImageView!//录音时的第2个圆环
    private var circleView3:UIImageView!
    private var circleView4:UIImageView!
    
    // 中间图片
    private var unRecordCenterView:UIImageView!//无录音时
    private var recordingCenterView:UIImageView!//正在录音时
    //计时Label
    var timerLabel:UILabel!//计时
    //长按录音按钮
    var longPressSpeakButton: UIButton!
    
    internal var delegate:SMAudioRecorderViewControllerDelegate?
    private var longPressRec:UILongPressGestureRecognizer!
    private var recorder: AVAudioRecorder!
    private var avRecordSession:AVAudioSession!
    var outputRecordURL: NSURL!
    private var timeTimer:NSTimer?
    private var milliSeconds:Int = 0 //计时
    private var circleViewCount:Int = 0 //用于动态显示图片时的计数用
    private var recording:Bool = false //true:正在录音
    
    // MARK: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initUI()
        //录音后文件路径
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
            .UserDomainMask, true)[0] as NSString
        let outputPath = documentsPath
            .stringByAppendingPathComponent("\(NSUUID().UUIDString).m4a")
        outputRecordURL = NSURL(fileURLWithPath: outputPath)
        print(outputRecordURL.description)
        //长按手势
        longPressSpeakButton.addTarget(self, action: "longPressTouchDown:", forControlEvents: .TouchDown)
        longPressSpeakButton.addTarget(self, action: "longPressTouchUpInside:", forControlEvents: .TouchUpInside)
        longPressSpeakButton.addTarget(self, action: "longPressTouchDragExit:", forControlEvents: .TouchDragExit)
        longPressSpeakButton.addTarget(self, action: "longPressTouchUpOutside:", forControlEvents: .TouchUpOutside)
        longPressSpeakButton.addTarget(self, action: "longPressTouchDragEnter:", forControlEvents: .TouchDragEnter)
        
        //录音设置
        let recordSettings =
        [AVFormatIDKey: NSNumber(unsignedInt: kAudioFormatMPEG4AAC),
            AVSampleRateKey: NSNumber(integer: 44100),
            AVNumberOfChannelsKey: NSNumber(integer: 2)]
        try! recorder = AVAudioRecorder(URL: outputRecordURL, settings: recordSettings)
        recorder.prepareToRecord()
        //录音会话开启，否则会出现顶部红色的status bar闪动
        avRecordSession = AVAudioSession.sharedInstance()
        try! avRecordSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        try! avRecordSession.setActive(true)
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }

    func updateUI(recordState:RecordState){
        switch recordState {
        case .Unrecord:
            milliSeconds = 0
            circleViewCount = 0
            circleViewUnrecord.alpha = 1
            circleView1.alpha = 0
            circleView2.alpha = 0
            circleView3.alpha = 0
            circleView4.alpha = 0
            unRecordCenterView.alpha = 1
            recordingCenterView.alpha = 0
            timerLabel.textColor = color1
            longPressSpeakButton.backgroundColor = color2
            longPressSpeakButton.setTitle("按住 录音", forState: .Normal)
            longPressSpeakButton.setTitleColor(color3, forState: .Normal) //#FFFFFF
        case .RecordCircle1:
            circleViewUnrecord.alpha = 0
            circleView1.alpha = 1
            circleView2.alpha = 0
            circleView3.alpha = 0
            circleView4.alpha = 0
            unRecordCenterView.alpha = 0
            recordingCenterView.alpha = 1
            timerLabel.textColor = color2
            longPressSpeakButton.backgroundColor = color4
            longPressSpeakButton.setTitle("松开 结束", forState: .Normal)
            longPressSpeakButton.setTitleColor(color5, forState: .Normal)//#666666
        case .RecordCircle2:
            circleViewUnrecord.alpha = 0
            circleView1.alpha = 1
            circleView2.alpha = 1
            circleView3.alpha = 0
            circleView4.alpha = 0
            unRecordCenterView.alpha = 0
            recordingCenterView.alpha = 1
            timerLabel.textColor = color2
            longPressSpeakButton.backgroundColor = color4//#202424
        case .RecordCircle3:
            circleViewUnrecord.alpha = 0
            circleView1.alpha = 1
            circleView2.alpha = 1
            circleView3.alpha = 1
            circleView4.alpha = 0
            unRecordCenterView.alpha = 0
            recordingCenterView.alpha = 1
            timerLabel.textColor = color2
            longPressSpeakButton.backgroundColor = color4//#202424
        case .RecordCircle4:
            circleViewUnrecord.alpha = 0
            circleView1.alpha = 1
            circleView2.alpha = 1
            circleView3.alpha = 1
            circleView4.alpha = 1
            unRecordCenterView.alpha = 0
            recordingCenterView.alpha = 1
            timerLabel.textColor = color2
            longPressSpeakButton.backgroundColor = color4//#202424
        }
    }
    
    func initUI(){
        //navigation bar
//        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .Done, target: self, action: "returnAction:")
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: color3]
        self.navigationItem.title = "录音"

        self.view.backgroundColor = UIColor(red: 46/255, green: 49/255, blue: 50/255, alpha: 1.0) //#2e3132
        //中间图片
        unRecordCenterView = UIImageView(image: UIImage(named: "ic_record"))
        unRecordCenterView.contentMode = .ScaleAspectFit
        self.view.addSubview(unRecordCenterView)
        constrain(unRecordCenterView) { (unRecordCenterView) -> () in
            unRecordCenterView.centerX == unRecordCenterView.superview!.centerX
            unRecordCenterView.centerY == unRecordCenterView.superview!.top + 188
        }
        recordingCenterView = UIImageView(image: UIImage(named: "ic_record_ing"))
        recordingCenterView.contentMode = .ScaleAspectFit
        self.view.addSubview(recordingCenterView)
        constrain(recordingCenterView) { (recordingCenterView) -> () in
            recordingCenterView.centerX == recordingCenterView.superview!.centerX
            recordingCenterView.centerY == recordingCenterView.superview!.top + 188
        }
        //正在录音效果图标，1+4个圆环
        circleViewUnrecord = UIImageView(image: UIImage(named: "img_circle_unrecord"))
        self.view.addSubview(circleViewUnrecord)
        constrain(unRecordCenterView, circleViewUnrecord) { (unRecordCenterView, circleViewUnrecord) -> () in
            circleViewUnrecord.centerX == unRecordCenterView.centerX
            circleViewUnrecord.centerY == unRecordCenterView.centerY
        }
        circleView1 = UIImageView(image: UIImage(named: "img_circle1"))
        circleView2 = UIImageView(image: UIImage(named: "img_circle2"))
        circleView3 = UIImageView(image: UIImage(named: "img_circle3"))
        circleView4 = UIImageView(image: UIImage(named: "img_circle4"))
        self.view.addSubview(circleView1)
        self.view.addSubview(circleView2)
        self.view.addSubview(circleView3)
        self.view.addSubview(circleView4)
        constrain(unRecordCenterView, circleView1, circleView2, circleView3, circleView4) { (unRecordCenterView, circleView1, circleView2, circleView3, circleView4) -> () in
            circleView1.centerX == unRecordCenterView.centerX
            circleView2.centerX == unRecordCenterView.centerX
            circleView3.centerX == unRecordCenterView.centerX
            circleView4.centerX == unRecordCenterView.centerX
            circleView1.centerY == unRecordCenterView.centerY
            circleView2.centerY == unRecordCenterView.centerY
            circleView3.centerY == unRecordCenterView.centerY
            circleView4.centerY == unRecordCenterView.centerY
        }
        //录音计时器
        timerLabel = UILabel()
        timerLabel.text = "00:00:00"
        timerLabel.font = UIFont.systemFontOfSize(24)
        timerLabel.textColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)//#cccccc
        self.view.addSubview(timerLabel)
        constrain(timerLabel, circleViewUnrecord) { (timerLabel, circleViewUnrecord) -> () in
            timerLabel.centerX == timerLabel.superview!.centerX
            timerLabel.top == circleViewUnrecord.bottom + 102
        }
        //录音按钮
        longPressSpeakButton = UIButton()
        longPressSpeakButton.layer.cornerRadius = 4
        longPressSpeakButton.titleLabel?.font = UIFont.systemFontOfSize(16)
        self.view.addSubview(longPressSpeakButton)
        constrain(longPressSpeakButton) { (longPressSpeakButton) -> () in
            longPressSpeakButton.centerX == longPressSpeakButton.superview!.centerX
            longPressSpeakButton.bottom == longPressSpeakButton.superview!.bottom - 30
            longPressSpeakButton.width == 270
            longPressSpeakButton.height == 45
        }
        updateUI(.Unrecord)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions

    func longPressTouchDown(sender:UIButton){//点下去开始录音
//        print("speak began")
        startRecord()
    }
    func longPressTouchUpInside(sender:UIButton){//抬起手指，保存录音
//        print("speak ended")
        if milliSeconds <= 30 {// 录音时间太短，取消录音
            SMToast.showText("时间太短，请重新录音", duration: 1)
            updateUI(.Unrecord)
            cleanUp()
            return
        }
        finishRecord()
        closeControllerView()
        delegate?.audioRecorderFinishRecord(withFileURL: outputRecordURL)
        SMToast.showText("录音完成", duration: 1)
    }
    func longPressTouchDragExit(sender:UIButton){//往上滑，提示取消录音
        SMToast.showText("上滑录音取消", duration: 1)
    }
    func longPressTouchUpOutside(sender:UIButton){//往上滑后，抬起手指，取消录音
        print("speak cancelled")
        updateUI(.Unrecord)
        cleanUp()
        SMToast.showText("录音取消", duration: 1)
    }
    func longPressTouchDragEnter(sender:UIButton){//往上滑后，又往下滑回来，继续录音
        SMToast.showText("下滑继续录音", duration: 1)
    }
    
    
    func returnAction(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: Self func
    func startRecord(){
        timeTimer?.invalidate()
        milliSeconds = 0
        timeTimer = NSTimer.scheduledTimerWithTimeInterval(0.0167,
            target: self, selector: "updateTimeLabel:",
            userInfo: nil, repeats: true)
        do{
          try avRecordSession.setActive(true)
        } catch {
            
        }
        recorder.record()
    }

    
    func finishRecord(){
        if recorder.recording {
            recorder.stop()
        }
        timeTimer?.invalidate()
    }
    
    func cleanUp(){
        if recorder.recording {
            recorder.stop()
            recorder.deleteRecording()
        }
        timeTimer?.invalidate()
    }
    /*
        更新计时
    */
    func updateTimeLabel(timer: NSTimer){
        milliSeconds++
        let milliSecond = (milliSeconds % 100)
        let second = (milliSeconds / 60) % 60
        let minute = milliSeconds / 3600
        timerLabel.text = NSString(format: "%02d:%02d.%02d",
            minute, second, milliSecond) as String
        
        circleViewCount++
        if circleViewCount == 1 {
            updateUI(.RecordCircle1)
        } else if circleViewCount == 20 {
            updateUI(.RecordCircle2)
        } else if circleViewCount == 40 {
            updateUI(.RecordCircle3)
        } else if circleViewCount == 60 {
            updateUI(.RecordCircle4)
            circleViewCount = 0
        }
    }
    /*
        关闭当前的ViewController
    */
    func closeControllerView(){
        navigationController?.popViewControllerAnimated(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
enum RecordState{
    case Unrecord //未录音状态
    case RecordCircle1 //录音状态，第1个圈亮
    case RecordCircle2 //第2个圈亮
    case RecordCircle3 //第3个圈亮
    case RecordCircle4 //第4个圈亮
}

