# Set volume
set $refresh_i3status killall -SIGUSR1 i3status
bindsym XF86AudioRaiseVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status
bindsym XF86AudioLowerVolume exec --no-startup-id pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status
bindsym XF86AudioMute exec --no-startup-id pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status
bindsym XF86AudioMicMute exec --no-startup-id pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status

# Set brightness
bindsym XF86MonBrightnessDown exec --no-startup-id light -U 5
bindsym XF86MonBrightnessUp exec --no-startup-id light -A 5
bindsym Mod4+minus exec --no-startup-id light -U 5
bindsym Mod4+equal exec --no-startup-id light -A 5

# Terminal and neovim
bindsym Mod4+Return exec kitty
bindsym Mod4+Shift+Return exec kitty -e nvim

# Kill focused window
bindsym Mod4+Shift+q kill

# Menu
bindsym Mod4+p exec --no-startup-id rofi -show run -theme solarized -font 'Mono 15'
bindsym Mod4+semicolon exec --no-startup-id rofi -show window -font 'Mono 15' -theme solarized

# Focus windows
bindsym Mod4+h focus left
bindsym Mod4+j focus down
bindsym Mod4+k focus up
bindsym Mod4+l focus right

# Move windows
bindsym Mod4+Shift+Left move left
bindsym Mod4+Shift+Down move down
bindsym Mod4+Shift+Up move up
bindsym Mod4+Shift+Right move right

# Split windows
bindsym Mod4+b split h
bindsym Mod4+v split v

# Window layouts
bindsym Mod4+f fullscreen toggle
bindsym Mod4+s layout stacking
bindsym Mod4+w layout tabbed
bindsym Mod4+e layout toggle split

# Toggle tiling/floating
bindsym Mod4+Shift+space floating toggle
bindsym Mod4+space focus mode_toggle

# Focus parent/child
bindsym Mod4+a focus parent
bindsym Mod4+c focus child

# Reload config
bindsym Mod4+Shift+c reload

# Quit i3
bindsym Mod4+Shift+e exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"

# Restart i3
bindsym Mod4+Shift+r restart

# Workspace management
#+Workspace names
set $ws1 "1"
set $ws2 "2"
set $ws3 "3"
set $ws4 "4"
set $ws5 "5"
set $ws6 "6"
set $ws7 "7"
set $ws8 "8"
set $ws9 "9"
set $ws10 "10"

#+Workspace switching
bindsym Mod4+1 workspace number $ws1
bindsym Mod4+2 workspace number $ws2
bindsym Mod4+3 workspace number $ws3
bindsym Mod4+4 workspace number $ws4
bindsym Mod4+5 workspace number $ws5
bindsym Mod4+6 workspace number $ws6
bindsym Mod4+7 workspace number $ws7
bindsym Mod4+8 workspace number $ws8
bindsym Mod4+9 workspace number $ws9
bindsym Mod4+0 workspace number $ws10

#+Move focused containers
bindsym Mod4+Shift+1 move container to workspace number $ws1
bindsym Mod4+Shift+2 move container to workspace number $ws2
bindsym Mod4+Shift+3 move container to workspace number $ws3
bindsym Mod4+Shift+4 move container to workspace number $ws4
bindsym Mod4+Shift+5 move container to workspace number $ws5
bindsym Mod4+Shift+6 move container to workspace number $ws6
bindsym Mod4+Shift+7 move container to workspace number $ws7
bindsym Mod4+Shift+8 move container to workspace number $ws8
bindsym Mod4+Shift+9 move container to workspace number $ws9
bindsym Mod4+Shift+0 move container to workspace number $ws10
