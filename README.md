# nfb

**Design**
* 2 runs
  * Run1 = 24 minutes (1439.817 seconds)
  * Run2 = 24.16 minutes (1449.333 seconds)
  * 72 Blocks per run 
    * 4 conditions
      * Protocol 196KJ (A; 15 signals, 3 baseline)
      * Protocol 564D  (B, 10 signals, 8 baseline)
      * Protocol KJ    (C; 15 signals, 3 baseline)
      * Protocol D     (D; 10 signals, 8 baseline)
    * 18 trials for each condition
    * 15 unique feedback signals for each run
      * B and D show signals that are subset of A and C signals
    * 8 unique feedback baselines for each run
      * A and C show baselines that are subset of B and D baselines
    * Each condition has a different fill color
      * Colors are counterbalanced across 4 different versions
    * 1 Block:
      * 4 seconds infusion:
        * 4 stages: 0, 33, 66, 100, 100
        * Each stage displays for 1 second
      * 2 seconds will improve
        * Keyboard responses are restricted to 1, 2
          * 1 = Yes
          * 2 = No
      * 0 - 2 seconds random jitter
      * 10 seconds feedback
        * 3 stages
          * 1-3 seconds baseline (excluding the initial baseline screen)
          * 2-4 seconds ramp
          * rest at max
        * Feedback consists of Gaussian noise
        * For stages 2,3 two sine waves are added to signal
      * 2 seconds improved
        * Keyboard responses restricted to 1, 2
          * 1 = Yes
          * 2 = No
      * 0 - 2 seconds random jitter
      
**Design Options**
* some options are only available on *nix operating systems
* on windows options are displayed in a ui window
* InScan
  * 1 = Yes, this will make the presentations opaque
  * 2 = No, this will make the presentations translucent which is usefull for debugging. If an error occurs in this mode, enter "sca" without quotes in the Matlab terminal to close the experiemehnt.
* Participant ID: self explanatory; a directory Responses/[ID] will be created to store participant output
* StartRun: run to start
* EndRun: run to end
* Testing
  * 1 = Yes, this will use TestOrder.csv as the design which is signficiantly shorter for testing purposes
  * 2 = No, this will use Design.csv as the design which is what you want to use in the scanner
* Suppress
  * 1 = Yes, suprress all psychtoolbox output
  * 2 = No, do not suppress psychtoolobx output
* Version controls the color scheme
  * 1
    * Protocol 196KJ = red
    * Protocol 564D = light blue
    * Protocol C = green
    * Protocol KJ = yellow
  * 2
    * Protocol 196KJ = light blue
    * Protocol 564D = red
    * Protocol C = yellow
    * Protocol KJ = green
  * 3
    * Protocol 196Kj = green
    * Protocol 564D = yellow
    * Protocol C = red
    * Protocol KJ = light blue
  * 4
    * Protocol 196Kj = yellow
    * Protocol 564D = green
    * Protocol C = light blue
    * Protocol KJ = red
    
**File/Directory Descriptions**
* NeurofeedbackTask.m - matlab script to run the social cognition task
* Design.csv - csv file listing the trials used in the experiment. Manually edit this file if you want to use a specific trial order, but make sure you keep the same format; otherwise, the task will not run.
* GetDevice.m - matlab file to list connected devices to computer. Use this to identify the DeviceIndex value for SocialCognitionTask. This is useless for Windows machines (confirm this statement).
* TestFont.m - script to test fonts using drawtext
* Fonts - directory containing the necessary fonts
* DebugScripts/Development/CreateDesign.m - matlab script to create Design.csv file
* DebugScripts/Development/CreateWaveforms.m - matlab script to create feedback signals
* DedubScripts/Development/Waveforms.mat - mat file saving the feedback signals
* Responses - participant response files are saved in this directory
