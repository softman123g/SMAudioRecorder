# SMAudioRecorder
Audio Recorder by Swift. 使用Swift开发的录音工具

##Features/功能
1. 支持录音
2. 支持上滑取消录音
3. 支持下滑继续录音

效果图：
![SMAudioRecorder](/SMAudioRecorder.gif)


##How to Use?
1. Implement 'SMAudioRecorderViewControllerDelegate'.

		func audioRecorderFinishRecord(withFileURL fileURL: NSURL?){
			...
		}
		
2. Present the view controller.
		
		let audioRecorder = SMAudioRecorderViewController()
        audioRecorder.delegate = self
        presentViewController(audioRecorder, animated: true, completion: nil)

##About me
Contact me: softman123g@126.com

or Star me: https://github.com/softman123g/SMAudioRecorder


