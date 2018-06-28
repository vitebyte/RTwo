//
//  TrainingVideoViewController.swift
//  DigitalEcoSystem
//
//  Created by Narender Kumar on 07/04/17.
//  Copyright © 2017 Dean and Deluca. All rights reserved.
//

import Foundation
import UIKit
import CTVideoPlayerView

class TrainingVideoViewController: BaseViewController {

    //MARK: - Variables
    public var trainingInfo: Training?

    fileprivate var isNetworkFailure: Bool = false
    fileprivate var currentInterval: CGFloat! = 0.0
    fileprivate var totalInterval: CGFloat! = 0.0
    fileprivate var videoView: CTVideoView = CTVideoView()
    fileprivate var progress: Float = 0.0 {
        didSet {
            self.progressView.setProgress(progress, animated: true)
        }
    }

    // MARK: - IBOutlets
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var playerBg: UIView!
    @IBOutlet weak var progressView: UIProgressView!

    //MARK: - View life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.isNavigationBarHidden = true

        // Update 'trainingInfo.playbackInterval' object with db training object base on trainingId
        let traingPlayback = CoreDataManager.getTrainingPlaybackTime(forTraining: (trainingInfo?.trainingId)!)
        trainingInfo?.playbackInterval = traingPlayback

        // setup video player and play the video
        playVideoIfNetwork()

        // Update training Status if it is 'New'
        if trainingInfo?.status == TrainingStatus.New.hashValue {
            CoreDataManager.updateTrainingStatus(trainingInfo!, to: TrainingStatus.InProgress.hashValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        doneButton.setTitle(LocalizedString.shared.doneString, for: .normal)
    }

    override func viewWillDisappear(_: Bool) {
        super.viewDidAppear(true)

        navigationController?.isNavigationBarHidden = false

        if videoView.isPlaying {
            updateProgress()
        }
        
        self.updateVideoTime(Float(self.currentInterval))
    }

    // MARK: - Video various stages
    func playTraningVideo() {
        let videoUrl: String = Constants.ImageUrl.Video + trainingInfo!.videoUrl!
        playerBg.layoutIfNeeded()
        var frame: CGRect = playerBg.bounds
        frame.origin.x = 0
        frame.origin.y = 0
        videoView.frame = frame
        playerBg.addSubview(videoView)
        videoView.videoUrl = URL(string: videoUrl)
        videoView.play()
        videoView.timeDelegate = self
        videoView.playControlDelegate = self
        videoView.operationDelegate = self
        videoView.isSlideFastForwardDisabled = true
        videoView.shouldReplayWhenFinish = false
        videoView.isUserInteractionEnabled = false // do not allow user to play with gestures or other controls.
        videoView.setShouldObservePlayTime(true, withTimeGapToObserve: 100.0)
        doneButton.isHidden = true
    }

    func deallocVideoPlayer() {
        if videoView.isPlaying {
            videoView.isMuted = true
            videoView.deleteAndCancelDownloadTask()
            videoView.stop(withReleaseVideo: true)
            videoView.deallocTime()
        }
    }

    func playVideoIfNetwork() {
        if NetworkManager.isNetworkReachable() == false {
            isNetworkFailure = true
            showAlertViewWithMessageAndActionHandler(LocalizedString.shared.ERROR_TITLE, message: LocalizedString.shared.NO_NETWORK_TITLE, actionHandler: {
                _ = self.navigationController?.popViewController(animated: true)
            })
        } else {
            isNetworkFailure = false
            Helper.showLoader()
            playTraningVideo()
        }
    }

    // MARK: - Status for questions
    func showMessageForNoQuestions() {
        showAlertViewWithMessageAndActionHandler(LocalizedString.shared.INFORMATION_TITLE, message: LocalizedString.shared.noQuestionsString, actionHandler: {
            _ = self.navigationController?.popViewController(animated: true)
        })
    }

    func moveToQuestionsView(_ questionArray: [Question]) {
        deallocVideoPlayer()
        var isAlreadyPushed: Bool = false
        if let viewControllers = self.navigationController?.viewControllers {
            for viewController in viewControllers {
                if viewController.isKind(of: TrainingQuestionsViewController.self) {
                    isAlreadyPushed = true
                }
            }
        }

        if isAlreadyPushed == false {
            let storyBoard: UIStoryboard = UIStoryboard.trainingStoryboard()
            let trainingQuestionsViewController = storyBoard.instantiateViewController(withIdentifier: Constants.ViewControllerIdentifiers.TrainingQuestionsIdentifier) as! TrainingQuestionsViewController
            trainingQuestionsViewController.questionsArray = questionArray
            trainingQuestionsViewController.trainingDetail = trainingInfo
            navigationController?.pushViewController(trainingQuestionsViewController, animated: true)
        }
    }

    fileprivate func updateProgress() {
        let traingPlayback = trainingInfo?.completedPer
        let videoProgress = (Double(currentInterval / totalInterval * 100) * Double(Constants.TrainingWeightage.VideoPercent)) / 100.0
        if traingPlayback! <= Int(Constants.TrainingWeightage.VideoPercent) {
            CoreDataManager.updateTraining(trainingInfo!, withProgress: round(videoProgress), playback: Double(currentInterval))
        }
    }

    // MARK: - Check Video is complete or not
    func isVideoCompleted() -> Bool {
        if floor(currentInterval) == floor(totalInterval) {
            return true
        } else {
            return false
        }
    }

    // MARK: - IBActions
    @IBAction func doneButtonAction(_: UIButton) {
        // update training completion progress and playback interval
        updateProgress()

        // dealloc video player
        deallocVideoPlayer()

        if isVideoCompleted() {

            if trainingInfo?.status == TrainingStatus.Completed.hashValue { // take user back

                showAlertViewWithMessageAndActionHandler(LocalizedString.shared.INFORMATION_TITLE, message: LocalizedString.shared.trainingCompleted, actionHandler: {
                    _ = self.navigationController?.popViewController(animated: true)
                })

            } else if trainingInfo?.attemptLeft == 0 {

                showAlertViewWithMessage(LocalizedString.shared.INFORMATION_TITLE, message: LocalizedString.shared.NO_ATTEMPTS_LEFT)

            } else { // start quiz
                getQuestions()
            }

        } else {
            _ = navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: - CTVideoViewTimeDelegate, CTVideoViewPlayControlDelegate, CTVideoViewOperationDelegate
extension TrainingVideoViewController: CTVideoViewTimeDelegate, CTVideoViewPlayControlDelegate, CTVideoViewOperationDelegate {

    func videoViewDidLoadVideoDuration(_ videoView: CTVideoView!) {
        totalInterval = videoView.totalDurationSeconds

        if trainingInfo?.completedPer == Constants.TrainingWeightage.VideoPercent {
            // update local data source
            trainingInfo?.playbackInterval = Double(totalInterval)

            // update current interval to seek forward video to completion automatically
            currentInterval = totalInterval

            // update progress with total time in db
            updateProgress()
        }

        Helper.hideLoader()
        doneButton.setTitle(LocalizedString.shared.watchlater, for: .normal)
        if isVideoCompleted() {
            doneButton.setTitle(LocalizedString.shared.doneString, for: .normal)
        } else {
            doneButton.setTitle(LocalizedString.shared.watchlater, for: .normal)
        }
    }

    func videoViewDidFinishPrepare(_: CTVideoView!) {
        let playbackInterval: Double = Double((trainingInfo?.playbackInterval)!)
        self.videoView.move(toSecond: CGFloat(playbackInterval), shouldPlay: true)
    }

    func videoViewDidFailPrepare(_: CTVideoView!, error _: Error!) {
        Helper.hideLoader()
        showAlertViewWithMessageAndActionHandler(LocalizedString.shared.ERROR_TITLE, message: LocalizedString.shared.NO_NETWORK_TITLE, actionHandler: {
            self.doneButton.isHidden = false
            _ = self.navigationController?.popViewController(animated: true)
        })
    }

    func videoViewDidFinishPlaying(_: CTVideoView!) {
        doneButtonAction(UIButton())
    }

    func videoView(_ videoView: CTVideoView!, didPlayToSecond second: CGFloat) {
        doneButton.isHidden = false

        if isNetworkFailure == false {
            if NetworkManager.isNetworkReachable() == false {
                videoView.stop(withReleaseVideo: false)
                isNetworkFailure = true
                showAlertViewWithMessageAndActionHandler(LocalizedString.shared.ERROR_TITLE, message: LocalizedString.shared.NO_NETWORK_TITLE, actionHandler: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
            } else {
                isNetworkFailure = false
                currentInterval = second
                if second > 0 {
                    progress = Float(second / totalInterval)
                }
            }
        }
    }
}

// MARK: - API Calls
extension TrainingVideoViewController {

    func getQuestions() {
        Question.getTrainingQuestions(trainingInfo!) { success, _, questionArray in
            if success {
                if (questionArray?.count)! > 0 {
                    self.moveToQuestionsView(questionArray!)
                } else {
                    self.showMessageForNoQuestions()
                }
            } else {
                self.showAlertViewWithMessageAndActionHandler(LocalizedString.shared.INFORMATION_TITLE, message: LocalizedString.shared.noQuestionsString, actionHandler: {
                    _ = self.navigationController?.popViewController(animated: true)
                })
                self.showMessageForNoQuestions()
            }
        }
    }
    
    func updateVideoTime(_ videoTime:Float) {
        DispatchQueue.global(qos: .userInitiated).async {
            Training.syncTrainingVideoTime(self.trainingInfo?.trainingId as AnyObject, videoTime: videoTime) { (success, message) in
                //only api call is required silently
            }
        }
    }
}

/// syncTrainingVideo
