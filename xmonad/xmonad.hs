import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Layout.Gaps
import XMonad.Layout.IndependentScreens
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO
import Data.Monoid
import System.Exit
import System.Environment
import System.FilePath
import XMonad.Actions.Navigation2D
import XMonad.Actions.SwapWorkspaces
import XMonad.Actions.WithAll
import XMonad.Hooks.SetWMName
import XMonad.Hooks.ServerMode
import XMonad.Hooks.EwmhDesktops

import XMonad.Layout.ThreeColumns
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.Fullscreen (fullscreenFull, fullscreenSupport)
import XMonad.Layout.Grid (Grid(..))
import XMonad.Layout.TwoPane (TwoPane(..))
import XMonad.Layout.Tabbed
import XMonad.Layout.ResizableTile
import Graphics.X11.ExtraTypes.XF86

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

import  GHC.IO.Handle ( hDuplicateTo )

redirectStdHandles :: IO ()
redirectStdHandles = do
  home <- getEnv "HOME"
  let xmonadDir = home </> ".xmonad"
  hClose stdout
  hClose stderr
  stdout' <- openFile (xmonadDir </> "xmonad-stdout.log") AppendMode
  stderr' <- openFile (xmonadDir </> "xmonad-stderr.log") AppendMode
  hDuplicateTo stdout' stdout
  hDuplicateTo stderr' stderr
  hSetBuffering stdout NoBuffering
  hSetBuffering stderr NoBuffering

myManageHook = composeAll
    [ className =? "Gimp"      --> doFloat
    , className =? "Vncviewer" --> doFloat
    ]

-- list of workspaces
myWorkspaces = ["A","S","D","F","Q","W","E","R","1","2","3","4"]

altMask = mod1Mask

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $
    -- launch a terminal
    [ ((controlMask .|. shiftMask, xK_t), spawn $ XMonad.terminal conf)
    
    -- launch google-chrome
    , ((controlMask .|. shiftMask, xK_f), spawn "google-chrome --new-window https://www.google.com")

    -- launch dmenu
    --, ((modm,               xK_p     ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")
    , ((controlMask .|. shiftMask, xK_r), spawn "exe=`dmenu_path | dmenu -nb '#000000' -fn 'JetBrainsMono:pixelsize=24'` && eval \"exec $exe\"")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window
    , ((modm .|. shiftMask, xK_x     ), killAll)
    -- , ((modm .|. controlMask, xK_x ), killOthers)
    , ((modm              , xK_x     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    -- , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_n   ), windows W.focusDown)
    -- Move focus to the previous window
    , ((modm,               xK_p     ), windows W.focusUp)

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

   -- Switch between layers
   , ((modm,                 xK_semicolon), switchLayer)

   -- Directional navigation of windows
   , ((modm,                 xK_l), windowGo R False)
   , ((modm,                 xK_h), windowGo L False)
   , ((modm,                 xK_k), windowGo U False)
   , ((modm,                 xK_j), windowGo D False)

   -- Swap adjacent windows
   , ((modm .|. shiftMask, xK_l), windowSwap R False)
   , ((modm .|. shiftMask, xK_h), windowSwap L False)
   , ((modm .|. shiftMask, xK_k), windowSwap U False)
   , ((modm .|. shiftMask, xK_j), windowSwap D False)

   -- Directional navigation of screens
   , ((modm .|. controlMask, xK_l), screenGo R False)
   , ((modm .|. controlMask, xK_h), screenGo L False)
   , ((modm .|. controlMask, xK_k), screenGo U False)
   , ((modm .|. controlMask, xK_j), screenGo D False)

   -- -- Swap workspaces on adjacent screens
   -- , ((modm .|. controlMask .|. shiftMask, xK_l), screenSwap R False)
   -- , ((modm .|. controlMask .|. shiftMask, xK_h), screenSwap L False)
   -- , ((modm .|. controlMask .|. shiftMask, xK_k), screenSwap U False)
   -- , ((modm .|. controlMask .|. shiftMask, xK_j), screenSwap D False)

   -- Send window to adjacent screen
   , ((modm .|. controlMask .|. shiftMask, xK_l), windowToScreen R False)
   , ((modm .|. controlMask .|. shiftMask, xK_h), windowToScreen L False)
   , ((modm .|. controlMask .|. shiftMask, xK_k), windowToScreen U False)
   , ((modm .|. controlMask .|. shiftMask, xK_j), windowToScreen D False)

    ---- Swap the focused window with the next window
    --, ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    ---- Swap the focused window with the previous window
    --, ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    ---- Shrink the master area
    , ((modm,               xK_minus ), sendMessage Shrink)
    ---- Expand the master area
    , ((modm,               xK_equal ), sendMessage Expand)
    ---- Shrink the master area
    , ((modm .|. shiftMask, xK_minus ), sendMessage MirrorExpand)
    ---- Expand the master area
    , ((modm .|. shiftMask, xK_equal ), sendMessage MirrorShrink)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN (-1)))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN 1))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    , ((modm, xK_o), sendMessage ToggleStruts)

    , ((modm, xK_z), spawn "xsecurelock")

    -- Quit xmonad
    , ((modm .|. controlMask, xK_z), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm .|. shiftMask, xK_z), spawn "xmonad --recompile; xmonad --restart")

    , ((0, xF86XK_AudioLowerVolume   ), spawn "amixer -q -D pulse sset Master 2%-")
    , ((0, xF86XK_AudioRaiseVolume   ), spawn "amixer -q -D pulse sset Master 2%+")
    , ((0, xF86XK_AudioMute          ), spawn "amixer -q -D pulse sset Master toggle")
    , ((0, xF86XK_AudioNext), spawn "playerctl next")
    , ((0, xF86XK_AudioPrev), spawn "playerctl previous")
    , ((0, xF86XK_AudioPlay), spawn "playerctl play-pause")
    , ((0, xF86XK_MonBrightnessUp), spawn "lux -a 2%")
    , ((0, xF86XK_MonBrightnessDown), spawn "lux -s 2%")
    ]
    ++

    -- mod-[..], Switch to workspace N
    -- mod-shift-[..], Move client to workspace N
    -- mod-control-[..], Swap current workspace with workspace N
    --
    -- [((m .|. modm, k), windows $ f i)
    --     | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
    --     , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    -- ++
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_a, xK_s, xK_d, xK_f, xK_q, xK_w, xK_e, xK_r, xK_1, xK_2, xK_3, xK_4]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++


    [((modm .|. controlMask, k), windows $ swapWithCurrent i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_a, xK_s, xK_d, xK_f, xK_q, xK_w, xK_e, xK_r, xK_1, xK_2, xK_3, xK_4]]
    ++
    
    [((modm .|. altMask, k), windows $ swapWithCurrent i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_a, xK_s, xK_d, xK_f, xK_q, xK_w, xK_e, xK_r, xK_1, xK_2, xK_3, xK_4]]

    ++
    [ ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s -e 'xclip -selection clipboard -t image/png -i $f && rm -f $f'")
    , ((0, xK_Print), spawn "sleep 0.2; scrot -s -e 'xclip -selection clipboard -t image/png -i $f && rm -f $f'")
    ]


    -- --
    -- -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    -- --
    -- [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
    --     | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
    --     , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]
    --

-- 
-- Layouts
--
-- myLayout = smartBorders $ tiled ||| Mirror tiled ||| ThreeColMid 1 delta (1/3) ||| Grid ||| TwoPane delta (1/2) ||| simpleTabbed ||| noBorders Full
myLayout = smartBorders $ tiled ||| Mirror tiled ||| noBorders Full
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled   = ResizableTall nmaster delta ratio []

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio   = 1/2

    -- Percent of screen to increment by when resizing panes
    delta   = 3/100

-- bgred = magenta  = xmobarColor "#330000" ""

main = do
  n_screen <- countScreens
  xmprocs <- mapM (\i -> spawnPipe $ "xmobar -x " ++ show i) [0..n_screen-1]
  xmonad $ ewmh . withNavigation2DConfig def $ docks def {
    modMask = mod4Mask, 
    terminal = "x-terminal-emulator",
    normalBorderColor = "#330000",
    focusedBorderColor = "#aa0000",
    focusFollowsMouse = False,
    workspaces = myWorkspaces,
    manageHook = myManageHook <+> manageDocks <+> manageHook def,
    layoutHook = avoidStruts $ myLayout,
    logHook = mapM_ (\handle -> dynamicLogWithPP $ xmobarPP {
        ppOutput = System.IO.hPutStrLn handle,
        ppTitle = xmobarColor "red" "" . shorten 100,
        ppSep = xmobarColor "#770000" "" " | ",
        ppLayout = xmobarColor "#9A784F" ""
        }) xmprocs,
    --logHook = dynamicLogWithPP $ xmobarPP
    --                    { ppOutput = hPutStrLn xmprocs,
    --                      ppTitle = xmobarColor "red" "" . shorten 100
    --                    },
    -- startupHook = setWMName "LG3D" <+> io redirectStdHandles,
    startupHook = setWMName "LG3D",
    handleEventHook = serverModeEventHook
                      <+> serverModeEventHookCmd
                      <+> fullscreenEventHook,
    keys = myKeys
    }
