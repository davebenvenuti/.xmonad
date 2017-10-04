-- Pretty good resources:
--   http://beginners-guide-to-xmonad.readthedocs.org/en/latest/configure_xmonadhs.html
--   http://iaindunning.com/2013/experiences-with-xmonad-and-ubuntu-12.html
--   https://wiki.haskell.org/Xmonad/Config_archive/John_Goerzen's_Configuration
--   https://github.com/Emantor/configs/blob/master/xmonad/xmonad.hs
--   http://askubuntu.com/questions/403113/how-do-you-enable-tap-to-click-via-command-line-with-xmodmap
--   https://wiki.haskell.org/Xmonad/Using_xmonad_in_KDE

import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import Graphics.X11.ExtraTypes.XF86
import System.IO
import XMonad.Actions.CycleWS
import XMonad.Hooks.FadeInactive
import XMonad.Layout.PerWorkspace
import XMonad.Layout.SimplestFloat
import XMonad.Hooks.SetWMName
import XMonad.Layout.Fullscreen
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.IM
import Data.Ratio ((%))
import XMonad.Layout.Spacing
import XMonad.Hooks.EwmhDesktops

fadeLogHook :: X ()
fadeLogHook = fadeInactiveLogHook fadeAmount
  where fadeAmount = 0.8

pidginTall = Tall 1 0.02  0.5
pidginLayout = withIM (1%7) (Role "buddy_list") pidginTall

management :: [ManageHook]
management = [
    resource =? "stalonetray" --> doIgnore,
    -- to get window classNames:
    --   (from https://wiki.haskell.org/Xmonad/Using_xmonad_in_KDE)
    --   - Open the application.
    --   - Enter the command xprop | grep WM_CLASS in a terminal window on the same desktop.
    --   - Click on the application window.
    --   - Read the class name in the terminal window. The class name is the second of the two quoted strings displayed, usually capitalized. The first one is resource, usually lower case.
    className =? "Civ5XP" --> doFullFloat,
    className =? "Diablo III.exe" --> doFullFloat,
    className =? "SC2.exe" --> doFullFloat,
    className =? "VirtualBox" --> doFullFloat,
    appName =? "This War of Mine" --> doFullFloat,
    appName =? "Tabletop Simulator" --> doFullFloat,
    className =? "SupremeCommander.exe" --> doFullFloat,
    className =? "Pidgin" --> doShift "3",
    className =? "Google-chrome" --> doShift "2",
    className =? "brave" --> doShift "2",
    className =? "Firefox" --> doShift "2",
    className =? "java-lang-Thread" --> doShift "5",
    className =? "Battle.net.exe" --> doShift "4",
    className =? "Hearthstone.exe" --> doShift "4"
  ]

layout = avoidStruts
         $ onWorkspace "float" simplestFloat
         $ onWorkspace "3" pidginLayout
         $ layoutHook defaultConfig

main = do
  xmproc <- spawnPipe "PATH=~/.xmonad/scripts:$PATH xmobar"

  spawn "~/.xmonad/startup"
  -- spawnOn appears to be broken, but since we want to start gnome-terminal on
  -- our first workspace anyway, this hackishly works for now
  spawn "gnome-terminal"

  xmonad $ defaultConfig
    {
      modMask = mod4Mask, -- rebind mod to special
      manageHook = manageDocks <+> manageHook defaultConfig <+> composeAll management,
      layoutHook = layout,
      handleEventHook = handleEventHook defaultConfig <+> XMonad.Layout.Fullscreen.fullscreenEventHook <+> ewmhDesktopsEventHook,
      logHook = ewmhDesktopsLogHook <+> fadeLogHook <+> dynamicLogWithPP xmobarPP {
        ppOutput = hPutStrLn xmproc,
        ppTitle = xmobarColor "green" "" . shorten 50
        },
      startupHook = setWMName "LG3D" -- for java
    } `additionalKeys`

    [
      ((mod1Mask .|. controlMask, xK_Right), nextWS),
      ((mod1Mask .|. controlMask, xK_Left), prevWS),
      ((mod1Mask .|. controlMask, xK_l), spawn "gnome-screensaver-command -l && xset dpms force off"),
      ((0 , xF86XK_AudioLowerVolume), spawn "~/.xmonad-pulsevolume/pulse-volume.sh decrease"),
      ((0 , xF86XK_AudioRaiseVolume), spawn "~/.xmonad-pulsevolume/pulse-volume.sh increase")
    ]
