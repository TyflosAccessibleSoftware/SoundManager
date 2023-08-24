//  SoundManager.swift
//
//  Copyright (c) 2021-2023 Jonathan Chacón
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import AVFoundation

//MARK: SoundEvent enum declaration
extension SystemSoundEngine {
#if os(watchOS)
#elseif os(macOS)
    public enum SoundEvent: String {
        case basso = "Basso"
        case blow = "Blow"
        case bottle = "Bottle"
        case frog = "Frog"
        case funk = "Funk"
        case glass = "Glass"
        case hero = "Hero"
        case morse = "Morse"
        case ping = "Ping"
        case pop = "Pop"
        case purr = "Purr"
        case sosumi = "Sosumi"
        case submarine = "Submarine"
        case tink = "Tink"
    }
    
#else
    
    public enum SoundEvent: SystemSoundID {
        case MailReceived = 1000
        case MailSent = 1001
        case VoicemailReceived = 1002
        case SMSReceived = 1003
        case SMSSent = 1004
        case CalendarAlert = 1005
        case LowPower = 1006
        case SMSReceivedAlert = 1007
        case SMSReceivedAlert2 = 1008
        case SMSReceivedAlert3 = 1009
        case SMSReceivedAlert4 = 1010
        case SMSReceivedAlert5 = 1012
        case SMSReceivedAlert6 = 1013
        case SMSReceivedAlert7 = 1014
        case SMSReceivedAlertVibrate = 1011
        case VoiceMail = 1015
        case Anticipate = 1020
        case Bloom = 1021
        case Calypso = 1022
        case Choo_Choo = 1023
        case Descent = 1024
        case Fanfare = 1025
        case Ladder = 1026
        case Minuet = 1027
        case NewsFlash = 1028
        case Noir = 1029
        case SherwoodForest = 1030
        case Spell = 1031
        case Suspense = 1032
        case Telegraph = 1033
        case Tiptoes = 1034
        case Typewriters = 1035
        case Update = 1036
        case USSDAlert = 1050
        case SIMToolkitCallDropped = 1051
        case SIMToolkitGeneralBeep = 1052
        case SIMToolkitNegativeACK = 1053
        case SIMToolkitPositiveACK = 1054
        case SIMToolkitSMS = 1055
        case Tink = 1057
        case AudioToneBusy = 1070
        case AudioToneCongestion = 1071
        case AudioTonePathAcknowledge = 1072
        case AudioToneError = 1073
        case AudioToneCallWaiting = 1074
        case AudioToneKey = 1075
        case ScreenLocked = 1100
        case ScreenUnlocked = 1101
        case FailedScreenUnlock = 1102
        case KeyPressed = 1103
        case KeyPressed2 = 1104
        case KeyPressed3 = 1105
        case ConnectedToPower = 1106
        case RingerSwitchIndication = 1107
        case CameraShutter = 1108
        case ShakeToShuffle = 1109
        case JBL_Begin = 1110
        case JBL_Confirm = 1111
        case JBL_Cancel = 1112
        case BeginRecording = 1113
        case EndRecording = 1114
        case JBL_Ambiguous = 1115
        case JBL_NoMatch = 1116
        case begin_video_record = 1117
        case EndVideoRecording = 1118
        case VCInvitationAccepted = 1150
        case VCRinging = 1151
        case VCEnded = 1152
        case VCCallWaiting = 1153
        case VCCallUpgrade = 1154
        case TouchTone0 = 1200
        case TouchTone1 = 1201
        case TouchTone2 = 1202
        case TouchTone3 = 1203
        case TouchTone4 = 1204
        case TouchTone5 = 1205
        case TouchTone6 = 1206
        case TouchTone7 = 1207
        case TouchTone8 = 1208
        case TouchTone9 = 1209
        case TouchToneStar = 1210
        case TouchTonePound = 1211
        case Headset_StartCall = 1254
        case Headset_Redial = 1255
        case Headset_AnswerCall = 1256
        case Headset_EndCall = 1257
        case Headset_CallWaitingActions = 1258
        case Headset_TransitionEnd = 1259
        case SystemSoundPreviewVoicemail = 1300
        case SystemSoundPreviewReceivedMessage = 1301
        case SystemSoundPreviewNewMail = 1302
        case SystemSoundPreviewMailSent = 1303
        case SystemSoundPreviewAlarm = 1304
        case SystemSoundPreviewLock = 1305
        case KeyPressClickPreview = 1306
        case SystemSoundPreviewReceivedSms1 = 1307
        case SystemSoundPreviewReceivedSms2 = 1308
        case SystemSoundPreviewReceivedSms3 = 1309
        case SystemSoundPreviewReceivedSms4 = 1310
        case SystemSoundPreviewReceivedSms5 = 1312
        case SystemSoundPreviewReceivedSms6 = 1313
        case SystemSoundPreviewReceivedSms7 = 1314
        case SystemSoundPreviewVoiceMail = 1315
        case SMSReceived_Vibrate = 1311
        case TweetSent = 1016
        case RingerVibeChanged = 1350
        case SilentVibeChanged = 1351
        case Vibrate = 4095
    }
    
#endif
    
}
