import XMonad

import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers

import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig
import Graphics.X11.ExtraTypes.XF86
import System.IO
import Data.Monoid
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import XMonad.Actions.SinkAll
import XMonad.Layout.Tabbed
import XMonad.Layout.TabBarDecoration
import XMonad.Layout.Grid
import XMonad.Layout.LayoutHints
import XMonad.Layout.Dishes

import XMonad.Prompt
import XMonad.Prompt.Window

myManageHook = composeAll
    [ className =? "Gimp"      --> doFloat, -- do not run gimp in fullscreen mode
      className =? "Pidgin"    --> doFloat, 
      isDialog  -->                doCenterFloat,
      title =? "Firefox Preferences" --> doCenterFloat ]
    
    
-- alt-buttonleft: move window
-- alt-buttonright+buttonmiddle: resize window
mymouseBindings :: XConfig Layout -> M.Map (KeyMask, Button) (Window -> X ())
mymouseBindings (XConfig {XMonad.modMask = mod4Mask}) = M.fromList
    [ ((mod4Mask, button1), \w -> focus w >> mouseMoveWindow w
                                          >> windows W.shiftMaster)
    , ((mod4Mask, button2), \w -> focus w >> mouseResizeWindow w
                                         >> windows W.shiftMaster)
    , ((mod4Mask, button3), \w -> focus w >> mouseResizeWindow w
                                 >> windows W.shiftMaster)
    ]    
    
    -- default key definitions just for doc

    -- key: alt Q ........ Quit xmonad
myKeys x  = M.union (M.fromList (newKeys x)) (keys defaultConfig x)
newKeys conf@(XConfig {XMonad.modMask = modMask}) = [
    -- key: alt q ........ Quit current window
    ((modMask            , xK_q                   ), kill) -- close current window
    
    -- key: alt r ........ Reload xmonad
  , ((modMask            , xK_r                   ), spawn "xmonad --recompile; xmonad --restart")
  
  , ((0                  , xF86XK_AudioRaiseVolume), spawn "volume +")
  , ((0                  , xF86XK_AudioLowerVolume), spawn "volume -")
  , ((0                  , xF86XK_AudioMute), spawn "volume 0")
  , ((0                  , xF86XK_MonBrightnessDown), spawn "sudo /home/scip/bin/bright -")
  , ((0                  , xF86XK_MonBrightnessUp),   spawn "sudo /home/scip/bin/bright +")
    -- key: alt forward .. Turn headphone jack off (key is above <right>)
  , ((modMask            , xF86XK_Forward         ), spawn "sudo sysctl hw.snd.default_unit=0")
    
    -- key: alt back ..... Turn headphone jack on (key is above <left>)
  , ((modMask            , xF86XK_Back            ), spawn "sudo sysctl hw.snd.default_unit=1")
    
    -- key: alt m ........ Maximize all current floating windows on current workspace
  , ((modMask            , xK_m                   ), sinkAll)
    
    -- key: alt - ........ Shrink the master area
  , ((modMask            , xK_minus               ), sendMessage Shrink)
    
    -- key: alt + ........ Expand the master area
  , ((modMask            , xK_plus                ), sendMessage Expand)
    
    -- key: alt s ........ Display menu of window titles
  , ((modMask            , xK_s                   ), windowPromptGoto myPromptConfig)
    
    -- key: alt p ........ Display menu of shortcuts, shortcuts go to ~/.shortmenu/
  , ((modMask            , xK_p                   ), spawn  "/home/scip/bin/shortmenu")
    
    -- key: alt shift + .. Swap the focused window with the next window
  , ((modMask .|. shiftMask, xK_plus              ), windows W.swapDown  )
 
    -- key: alt shift - .. Swap the focused window with the previous window
  , ((modMask .|. shiftMask, xK_minus             ), windows W.swapUp    )
    
    
    -- key: alt z ........ Lock the screen
  , ((modMask            , xK_z                   ), spawn  "xscreensaver-command -lock")
    
    -- key: alt h ........ Display the key help popup
  , ((modMask            , xK_h                   ), spawn  "/home/scip/bin/keysxmonad")

  ]
  ++
    -- key: F1-F2 ........ Switch desktop
    -- key: alt shift 1..9 Move current window to desktop N
  [((m, k), windows $ f i)
     | (i, k) <- zip (XMonad.workspaces conf) [xK_F1 .. xK_F9]
     , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask  .|. modMask)]]


myPromptConfig :: XPConfig
myPromptConfig = defaultXPConfig
    { position          = Top
    , promptBorderWidth = 0
    , font              = "-*-terminus-*-*-*-*-12-*-*-*-*-*-iso10646-1"
    , height            = 14
    , bgColor           = "#2A2733"
    , fgColor           = "#AA9DCF"
    , bgHLight          = "#6B6382"
    , fgHLight          = "#4A4459"
    }



mylayout = avoidStruts $ Full ||| tabbed shrinkText defaultTheme ||| tiled ||| Mirror tiled ||| Grid ||| Dishes 2 (1/5)
  where
     -- default tiling algorithm partitions the screen into two panes
     tiled   = Tall nmaster delta ratio
 
     -- The default number of windows in the master pane
     nmaster = 1
 
     -- Default proportion of screen occupied by master pane
     ratio   = 2/3
 
     -- Percent of screen to increment by when resizing panes
     delta   = 3/100

                   
                   
main = do
   xmproc <- spawnPipe "/home/scip/bin/x /home/scip/.xmobarrc"
   xmonad $ defaultConfig
        { borderWidth        = 2,
          --terminal           = "gnome-terminal --hide-menubar",
          terminal           = "/home/scip/bin/terminal",
          normalBorderColor  = "#cccccc",
          focusedBorderColor = "#cd8b00",
          manageHook = manageDocks <+> myManageHook
                        <+> manageHook defaultConfig,
          --layoutHook = avoidStruts  $  layoutHook defaultConfig,
          layoutHook = mylayout,
          logHook = dynamicLogWithPP xmobarPP
                        { ppOutput = hPutStrLn xmproc
                        , ppTitle = xmobarColor "#9a9a9a" "" . shorten 90
                        },
          mouseBindings = mymouseBindings,
          keys          = myKeys
        }`removeKeys`
        [
          -- make M-Return available to emacs, I don't use it anyway
          ( mod1Mask , xK_Return )
          -- remove alt-1..9 so I can use those in screen
          -- use it w/o loop, because ++ doesn't work here
        , ( mod1Mask , xK_0 )
        , ( mod1Mask , xK_1 )
        , ( mod1Mask , xK_2 )
        , ( mod1Mask , xK_3 )
        , ( mod1Mask , xK_4 )
        , ( mod1Mask , xK_5 )
        , ( mod1Mask , xK_6 )
        , ( mod1Mask , xK_7 )
        , ( mod1Mask , xK_8 )
        , ( mod1Mask , xK_9 )
        ]
