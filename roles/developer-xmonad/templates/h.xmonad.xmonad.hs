import XMonad
import Data.Monoid
import System.Exit
import XMonad.Layout.Spacing
import XMonad.Layout.Minimize
import XMonad.Layout.Maximize
import qualified XMonad.StackSet as W
import qualified Data.Map        as M

-- System Stuff
import           System.IO
import           System.Environment -- get Environment Variables

-- WorkSpaces Switch
import XMonad.Actions.CycleWS -- nextWS, prevWS
-- import XMonad.Hooks.ManageDocks (avoidStruts, manageDocks)
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Util.SpawnOnce
import XMonad.Util.Run (spawnPipe)
import XMonad.Layout.IndependentScreens (countScreens)
import Control.Monad (Monad (..), unless, when, liftM)
import XMonad.Actions.WorkspaceNames
import XMonad.Layout.NoBorders
import XMonad.Hooks.ManageHelpers

-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "kitty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = False

-- Width of the window border in pixels.
myBorderWidth   = 4
myWindowSpacing = 10

-- "windows key" is usually mod4Mask.
myModMask       = mod4Mask
myWorkspaces    = [ "General", "Resarch", "Work", "Code", "Graphics", "Zoom", "Scretch"] ++ map show [7..9]

-- Border colors for unfocused and focused windows, respectively.
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#fff005"

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    -- , ((modm,               xK_p     ), spawn "exe=`dmenu_path | dmenu` && eval \"exec $exe\"")
    -- launch rofi
    , ((modm,               xK_p     ), spawn "rofi -show drun")
    , ((0,                  xK_Print ), spawn "scrot  -z -f -s -m '%y%m%d-%H%M%S.png' -e 'xclip -selection clipboard -target image/png -i $f && mv $f ~/Pictures/screenshots'")

    -- launch gmrun
    -- , ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
     -- , ((modm,               xK_space ), sendMessage NextLayout)
     -- , ((modm,               xK_space), spawn "~/.xmonad/scripts/change-lang-ibus.sh >> ~/.xmonad/scripts/change-lang-ibus.sh.log 2>&1")

 
    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    , ((modm,               xK_Right ), nextWS)
    , ((modm,               xK_Left ),  prevWS)
    , ((modm .|. shiftMask, xK_Right),  shiftToNext)
    , ((modm .|. shiftMask, xK_Left),   shiftToPrev)    


    -- Swap the focused window and the master window
    -- , ((modm,               xK_Return), windows W.swapMaster)
    , ((modm,               xK_Return), sendMessage NextLayout)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    -- , ((modm,               xK_l     ), sendMessage Expand)
    , ((modm,               xK_l     ), spawn "xscreensaver-command -lock")

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")
    ]
    ++

    --
    -- mod-[1..9], Switch to workspace N
    --
    -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- * NOTE: XMonad.Hooks.EwmhDesktops users must remove the obsolete
-- ewmhDesktopsLayout modifier from layoutHook. It no longer exists.
-- Instead use the 'ewmh' function from that module to modify your
-- defaultConfig as a whole. (See also logHook, handleEventHook, and
-- startupHook ewmh notes.)
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = avoidStruts $ smartBorders $ (tiled ||| Mirror tiled ||| layoutFull)
  where
    -- default tiling algorithm partitions the screen into two panes
    tiled   = smartSpacing myWindowSpacing $ Tall nmaster delta ratio

    layoutFull = noBorders Full

    -- The default number of windows in the master pane
    nmaster = 1

    -- Default proportion of screen occupied by master pane
    ratio   = 1/2

    -- Percent of screen to increment by when resizing panes
    delta   = 3/100

------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = manageDocks <+> composeAll
    [ className =? "MPlayer"        --> doFloat
    , className =? "Gimp"           --> doFloat
    , resource  =? "desktop_window" --> doIgnore
    , resource  =? "kdesktop"       --> doIgnore]
     <+> composeOne [ transience
                      , isDialog -?> doCenterFloat                      
                      , resource =? "stalonetray" -?> doIgnore
                      , isFullscreen -?> doFullFloat
                    ]

------------------------------------------------------------------------
-- Event handling

-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add EWMH event handling to your custom event hooks by
-- combining them with ewmhDesktopsEventHook.
--
myEventHook = mempty

------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add EWMH logHook actions to your custom log hook by
-- combining it with ewmhDesktopsLogHook.
--
-- myLogHook = return ()
-- myLogHook = workspaceNamesPP xmobarPP
--      { ppOutput = hPutStrLn xmproc
--      , ppTitle = id
--      }
--      >>= dynamicLogWithPP
myLogHook h    = dynamicLogWithPP $ wsPP { ppOutput = hPutStrLn h }

wsPP = xmobarPP { ppOrder               = \(ws:l:t:_)   -> [ws]
                }
-- 
-- myLogHook proc = dynamicLogWithPP $ xmobarPP
--   { ppOutput  = hPutStrLn proc
--   , ppCurrent = currentStyle
--   , ppVisible = visibleStyle
--   , ppTitle   = titleStyle
--   , ppLayout  = (\layout -> case layout of
--       "Tall"        -> "[|]"
--       "Mirror Tall" -> "[-]"
--       "ThreeCol"    -> "[||]"
--       "Tabbed"      -> "[_]"
--       "Gimp"        -> "[&]"
--       )
--   }
--   where
--     currentStyle = xmobarColor "yellow" "" . wrap "[" "]"
--     visibleStyle = wrap "(" ")"
--     titleStyle   = xmobarColor "cyan" "" . shorten 100 . filterCurly
--     filterCurly  = filter (not . isCurly)
--     isCurly x    = x == '{' || x == '}'
-- 
------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspae layout choices.
--
-- By default, do nothing.
--
-- * NOTE: EwmhDesktops users should use the 'ewmh' function from
-- XMonad.Hooks.EwmhDesktops to modify their defaultConfig as a whole.
-- It will add initialization of EWMH support to your custom startup
-- hook by combining it with ewmhDesktopsStartup.
--
myStartupHook = do
    spawn "xrdb -mereg $HOME/.Xresources"
    spawn "~/.xmonad/scripts/startup.sh >> ~/.xmonad/scripts/startup.log 2>&1" 
    return ()
{--
    -- liftM (dd==(2::Int)) countScreens >>= flip when (spawn "xrandr --output HDMI-2 --right-of DP-1 --auto")
    spawn "xrdb -merge .Xresources"
	spawnOnce "$HOME/.xmonad/scripts/random-bg.sh $HOME/Pictures/bg"
	spawnOnce "stalonetray"
    -- spawnOnce "xfce4-power-manager"
	return ()
--} 
--
--
--

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset


------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do
    xmproc <- spawnPipe "LC_CTYPE=en_US.utf8 xmobar"
    xmonad $ docks defaultConfig {
	      -- simple stuff
	        terminal           = myTerminal,
	        focusFollowsMouse  = myFocusFollowsMouse,
	        borderWidth        = myBorderWidth,
	        modMask            = myModMask,
	        workspaces         = myWorkspaces,
	        normalBorderColor  = myNormalBorderColor,
	        focusedBorderColor = myFocusedBorderColor,
	
	      -- key bindings
	        keys               = myKeys,
	        mouseBindings      = myMouseBindings,
	
	      -- hooks, layouts
	        layoutHook         = myLayout,
	        manageHook         = myManageHook,
--	        manageHook         = manageDocks <+> manageHook defaultConfig,
	        handleEventHook    = myEventHook,
--	        logHook            = myLogHook,
            logHook            = dynamicLogWithPP xmobarPP
                        { ppOutput = \x -> hPutStrLn xmproc x                -- >> hPutStrLn xmproc1 x  >> hPutStrLn xmproc2 x
                        , ppLayout = const ""
                        , ppCurrent = xmobarColor "#00cc99" "" . wrap "[" "]" -- Current workspace in xmobar
                        , ppVisible = xmobarColor "#c3e88d" ""                -- Visible but not current workspace
                        , ppHidden = xmobarColor "#82AAFF" "" . wrap "*" ""   -- Hidden workspaces in xmobar
                        , ppHiddenNoWindows = xmobarColor "#F07178" ""        -- Hidden workspaces (no windows)
                        , ppTitle = xmobarColor "#298080" "" . shorten 60     -- Title of active window in xmobar
                        , ppSep =  "<fc=#666666> | </fc>"                     -- Separators in xmobar
                        , ppUrgent = xmobarColor "#C45500" "" . wrap "!" "!"  -- Urgent workspace
                        , ppExtras  = [windowCount]                           -- # of windows current workspace
                        , ppOrder  = \(ws:l:t:ex) -> [ws,l]++ex++[t]
                        },
--	        logHook		   = dynamicLogWithPP xmobarPP
--                    { ppOutput = hPutStrLn xmproc
--                    , ppTitle = xmobarColor "green" "" . shorten 50
--                    },
	        startupHook        = myStartupHook
	    }
