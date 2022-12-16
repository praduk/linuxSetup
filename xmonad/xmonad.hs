import XMonad
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Layout.NoBorders
import XMonad.Layout.Gaps
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.EZConfig(additionalKeys)
import System.IO
import Data.Monoid
import System.Exit
import XMonad.Actions.Navigation2D
import XMonad.Actions.SwapWorkspaces

import XMonad.Layout.ThreeColumns
import XMonad.Layout.NoBorders (noBorders, smartBorders)
import XMonad.Layout.Fullscreen (fullscreenFull, fullscreenSupport)
import XMonad.Layout.Grid (Grid(..))
import XMonad.Layout.TwoPane (TwoPane(..))

import qualified XMonad.StackSet as W
import qualified Data.Map        as M

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
    , ((controlMask .|. shiftMask, xK_r), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")

    -- launch gmrun
    , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window
    , ((modm .|. shiftMask, xK_x     ), kill)
    , ((modm              , xK_x     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)
    -- Move focus to the next window
    , ((modm .|. shiftMask, xK_Tab   ), windows W.focusUp)

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

   -- Swap workspaces on adjacent screens
   , ((modm .|. controlMask .|. shiftMask, xK_l), screenSwap R False)
   , ((modm .|. controlMask .|. shiftMask, xK_h), screenSwap L False)
   , ((modm .|. controlMask .|. shiftMask, xK_k), screenSwap U False)
   , ((modm .|. controlMask .|. shiftMask, xK_j), screenSwap D False)

   -- Send window to adjacent screen
   , ((controlMask .|. shiftMask, xK_l), windowToScreen R False)
   , ((controlMask .|. shiftMask, xK_h), windowToScreen L False)
   , ((controlMask .|. shiftMask, xK_k), windowToScreen U False)
   , ((controlMask .|. shiftMask, xK_j), windowToScreen D False)

    ---- Swap the focused window with the next window
    --, ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    ---- Swap the focused window with the previous window
    --, ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    ---- Shrink the master area
    , ((modm,               xK_minus ), sendMessage Shrink)

    ---- Expand the master area
    , ((modm,               xK_equal ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN (-1)))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN 1))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    , ((modm, xK_p), sendMessage ToggleStruts)

    , ((modm, xK_z), spawn "xsecurelock")

    -- Quit xmonad
    , ((modm .|. controlMask, xK_z), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm .|. shiftMask, xK_z), spawn "xmonad --recompile; xmonad --restart")

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
myLayout = smartBorders $ tiled ||| Mirror tiled ||| ThreeColMid 1 (3/100) (1/3) ||| Grid ||| noBorders Full
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled   = Tall nmaster delta ratio

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio   = 1/2

    -- Percent of screen to increment by when resizing panes
    delta   = 3/100


main = do
  xmproc <- spawnPipe "/usr/bin/xmobar ~/.xmobarrc"
  xmonad $ withNavigation2DConfig def $ docks def {
    modMask = mod4Mask, 
    terminal = "x-terminal-emulator",
    normalBorderColor = "#550000",
    focusedBorderColor = "#aa0000",
    focusFollowsMouse = False,
    workspaces = myWorkspaces,
    manageHook = myManageHook <+> manageDocks <+> manageHook def,
    layoutHook = avoidStruts $ myLayout,
    logHook = dynamicLogWithPP $ xmobarPP
                        { ppOutput = hPutStrLn xmproc,
                          ppTitle = xmobarColor "red" "" . shorten 100
                        },
    keys = myKeys
    } `additionalKeys`
    [ ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s -e 'xclip -selection clipboard -t image/png -i $f && rm -f $f'")
    , ((0, xK_Print), spawn "scrot")
    ]
