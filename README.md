# Neurofeedback (NFB) task

**Design**
* 4 runs
  * Run1 = 10.8 minutes (648 seconds)
  * Run2 = 10.8 minutes (648 seconds)
  * Run3 = 10.8 minutes (648 seconds)
  * Run4 = 10.8 minutes (648 seconds)
  * TotalTime = 43.2 minutes
  * 32 Blocks per run 
    * 4 conditions
      * Protocol 196KJ  (A; 8 signals, 1 baseline)
      * Protocol 564D   (B, 3 signals, 6 baseline)
      * Calibration I   (C; 8 signals, 1 baseline)
      * Calibration II  (D; 3 signals, 6 baseline)
    * 9 trials for each condition
    * 8 unique feedback signals for each run
      * B and D show signals that are subset of A and C signals
    * 6 unique feedback baselines for each run
      * A and C show baselines that are subset of B and D baselines
    * Each condition has a different fill color
      * Colors are counterbalanced across 4 different versions
    * 1 Block:
      * 4 seconds infusion:
        * 4 stages: 0, 33, 66, 100, 100
        * Each stage displays for 1 second
      * 2 seconds will improve
        * Keyboard responses are restricted to 1, 2, 3, 4, 5, 6, 7, 8, 9, 0
          * 1,2,3,4,5 = left value
          * 6,7,8,9,0 = right value
      * Random jitter
        * Jitter duration is the remaining time of will improve after participant has responded
      * 10 seconds feedback
        * 3 stages
          * 0.25-2 seconds baseline (excluding the initial baseline screen)
          * 1.5-3.33 seconds ramp
          * rest at max
        * Feedback consists of Gaussian noise2
        * For stages 2,3 two sine waves are added to signal
      * 2 seconds improved
        * Keyboard responses restricted to 1, 2, 3, 4, 5, 6, 7, 8, 9, 0
          * 1,2,3,4,5 = left value
          * 6,7,8,9,0 = right value
      * Random jitter
        * Jitter duration is the remaining time of improved after participant has responded
      
**Design Options**
* Scan
  * 1 = Yes, this will make the presentations opaque
  * 2 = No, this will make the presentations translucent which is useful for debugging. If an error occurs in this mode, enter "sca" without quotes in the Matlab terminal to close the experiement.
* Participant ID: self explanatory; a directory Responses/[ID] will be created to store participant output
* StartRun: run to start
* EndRun: run to end
 * Odd runs (1,3) display rates as YES/NO, even runs (2,4) display rates as NO/YES
* Testing
  * 1 = Yes, this will use NfbTestOrder.csv as the design which is signficiantly shorter for testing purposes
  * 2 = No, this will use NfbDesign.csv as the design which is what you want to use in the scanner
* Version controls the color scheme
  * 1
    * Protocol 196KJ = red
    * Protocol 564D = light blue
    * Calibration I = green
    * Calibration II = yellow
  * 2
    * Protocol 196KJ = light blue
    * Protocol 564D = red
    * Calibration I = yellow
    * Calibration II = green
  * 3
    * Protocol 196Kj = green
    * Protocol 564D = yellow
    * Calibration I = red
    * Calibration II = light blue
  * 4
    * Protocol 196Kj = yellow
    * Protocol 564D = green
    * Calibration I = light blue
    * Calibration II = red
    
**File/Directory Descriptions**
* NfbTask.m - matlab script to run the social cognition task
* NfbDebug/Development/NfbDesign.csv - csv file listing the trials used in the experiment. Manually edit this file if you want to use a specific trial order, but make sure you keep the same format; otherwise, the task will not run.
* Fonts - directory containing the necessary fonts (not needed any more)
* NfbDebug/Development/CreateDesign.m - matlab script to create NfbDesign.csv file
* NfbDebug/Development/CreateWaveforms.m - matlab script to create feedback signals
* NfbDebug/Development/Waveforms.mat - mat file saving the feedback signals
* NfbResponses - participant response files are saved in this directory

# Social Cognition (SC) Task
**Design**
* 2 runs selected from 5 different versions of the run
 * Run1 = 9.8 minutes (590 seconds)
 * Run2 = 9.9 minutes (597 seconds)
 * Run3 = 9.9 minutes (592 seconds)
 * Run4 = 9.9 minutes (596 seconds)
 * Run5 = 9.9 minutes (592 seconds)
 * Each version was generated using this script: http://www.bobspunt.com/easy-optimize-x/ which maximizes efficiency.
 * 72 trials per run
   * 6 Conditions
      * 1: Pleasant - Happy (Congruent)
      * 2: Pleasant - Fearful (Incongruent)
      * 3: Pleasant - Neutral (Neutral)
      * 4: Unpleasant - Happy (Incongruent)
      * 5: Unpleasant - Fearful (Congruent)
      * 6: Unpleasant - Neutral (Neutral)
   * 12 trials for each condition in 1 run
   * appropriate images were randomly selected for each trial with sample
     * for example all Happy images including all genders were pooled together and then randomly assigned to conditions 1 and 4
   * 1 trial:
     * 3 seconds contextual picture
       * 72 unique pictures per run (144 total)
          * 36 pleasant per run
          * 36 unpleasant per run
     * 2 seconds face and rating
       * Keyboard responses are restricted to 1, 2, 3, 4, 5, 6, 7, 8, 9, 0
          * 1,2,3,4,5 = left response
          * 6,7,8,9,0 = right response
       * 36 male face per run (72 total)
         * 24 individuals
            * happy, fearful, neutral
            * 3 * 24 = 72
       * 36 female faces per run (72 total)
         * 18 individuals
            * happy, fearful, neutral
            * 3 * 18 = 54
            * some images are repeated
     * 2 - 6 seconds jittered inter-stimulus interval (ISI) sampled from an exponential distribution
        * Average of 3 seconds
        * min = 2 seconds
        * max = 5.59 seconds
  
**Design Options**
* Scan
  * 1 = Yes, this will make the presentations opaque
  * 2 = No, this will make the presentations translucent which is usefull for debugging. If an error occurs in this mode, enter "sca" without quotes in the Matlab terminal to close the experiemehnt.
* Participant ID: self explanatory; a directory Responses/[ID] will be created to store participant output
* Run1: selects what version to display for the first run (1-5)
* Run1 Order: determines the subset of images displayed. Typically this value should always be set at 1. There are 2 subset of images, one for each run. Order also controls the rating display screen locations. 1 = positive/negative, 2 = negative/positive
* Run2: selects what version to display for the second run (1-5). If this field is left blank, then only Run1 will be displayed.
* Run2 Order: determines the subsect of images displayed. Typically this value should always bet set at 2.
* Testing
  * 1 = Yes, this will use ScTestOrder.csv as the design which is signficiantly shorter for testing purposes
  * 2 = No, this will use ScDesign.csv as the design which is what you want to use in the scanner
  
**File/Directory Descriptions**
* ScTask.m - matlab script to run the social cognition task
* ScDebug/Development/FaceList.csv - csv file listing the images used in each order (run)
* ScDebug/Development/ScDesign.R - creates ScDesign.csv
* GetDevice.m - matlab file to list connected devices to computer. Use this to identify the DeviceIndex value for SocialCognitionTask. This is useless for Windows machines (confirm this statement).
* ScImages/Pleasant - directory containing pleasant contextual images
* ScImages/Unpleasant - directory containing unpleasant contextual images
* ScImages/Backgrounds - directory containing task background images
* ScImages/Faces - directory containing all face images
* ScResponses - participant response files are saved in this directory

# Queries
* Queries/QueryDevices.m - matlab file to list connected devices to computer. Use this to identify the DeviceIndex value for SocialCognitionTask. This is useless for Windows machines (confirm this statement).
* Queries/QueryClose1.m - examines window close behavior with "sca"
* Queries/QueryClose2.m - examines window close behavior with "Screen('CloseAll');"
* Queries/QueryClose3.m - examines window close behavior with "Screen('Close');"
* Queries/QueryFeedback.m - examines feedback closely with manual movement
* Queries/QueryFont.m - queries if fonts properly display after being installed
* Queries/QueryKbInput.m - queries input from devices; displays the input on screen
* Queries/QueryLineLength.m - looks at line length relative to feedback background
* Queries/QueryScreen.m - queries display information
* Queries/QueryTiming.m - queries difference between actual and expected flip times
* Queries/QueryTrigger.m - queries trigger functionality
* Quereis/QueryWindowLength.m - queries window length by drawing a line

# Scanner info
* screen reslution is 1024 x 768 (Will this be the in scanner display resolution?)
* operating system is Windows 7
* Response collection device: [PST BRU 5 Buttons](http://www.psychology-software-tools.mybigcommerce.com/celeritas-fiber-optic-response-unit-right-hand-5-buttons/)
 * keys are probably mapped to home row not number pad, you can check matlab command prompt response outputs to confirm this
