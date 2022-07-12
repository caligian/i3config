module Defaults
  I3_CONFIG_DIR = File.join(ENV['HOME'], '.config', 'i3')
  RB_SCRIPTS_DIR = File.join(I3_CONFIG_DIR, 'scripts') 
  YAML_PATH = File.join(I3_CONFIG_DIR, 'config.yaml')
  THEMES_DIR = File.join(I3_CONFIG_DIR, 'themes')

  I3BAR_DEFAULTS = { 
    cmd: 'i3bar',
    status_cmd: 'i3status --config ~/.config/i3/status_config',
    mode: 'hide',
    hidden: 'hide',
    mod: 'Mod1',
    pos: 'top',
    out: 'primary',
    font: 'pango: Noto Mono 12',
    sep: '',
    w_width: '1',
    bind: 'yes',
    colors: {
      bg: ['#002b36'],
      fg: ['#839496'],
      sep: ['#073642'],

      # param n = 3 <border> <bg> <fg>
      f_w: ['#073642', '#002b36', '#839496'],
      a_w: ['#839496', '#839496', '#002b36'],
      i_w: ['#073642', '#073642', '#839496'],
      u_w: ['#dc322f', '#dc322f', '#93a1a1'],
      bind: ['#b58900', '#b58900', '#002b36'],
    },
  }

  I3BAR_TR = { 
    cmd: 'i3bar_command',
    status_cmd: 'status_command',
    mode: 'mode',
    hidden: 'hidden_state',
    mod: 'modifier',
    pos: 'position',
    out: 'output',
    tray: "tray_output",
    font: "font",
    sep: 'separator_symbol',
    w_width: 'workspace_min_width',
    bind: 'binding_mode_indicator',
    colors: { 
      bg: 'background',
      fg: 'statusline',
      sep: 'separator',

      # param n = 3 <border> <bg> <fg>
      f_w: 'focused_workspace',
      a_w: 'active_workspace',
      i_w: 'inactive_workspace',
      u_w: 'urgent_workspace',
      bind: 'binding_mode'
    },
  }

  OPTIONS = { 
    focus_follows_mouse: 'no',
    mouse_warping: 'output',
    focus_wrapping: 'yes',
    workspace_auto_back_and_forth: 'yes',
    focus_on_window_activation: 'none',
    show_marks: 'yes',
    "ipc-socket" => "~/.config/i3/i3.socket",
    default_border: 'pixel 3',
    default_floating_border: 'pixel 3',
    hide_edge_borders: 'smart',
    floating_modifier: '$mod',
    font: 'pango:Monospace 12',
  }

  VARS = [ 
    :! , 'exec',
    :"!!" , '$! --no-startup-id',
    :refresh_i3status, '$!! killall -SIGUSR1 i3status',
    :raise_volume, '$!! pactl set-sink-volume @DEFAULT_SINK@ +10% && $refresh_i3status',
    :lower_volume, '$!! pactl set-sink-volume @DEFAULT_SINK@ -10% && $refresh_i3status',
    :mute_volume, '$!! pactl set-sink-mute @DEFAULT_SINK@ toggle && $refresh_i3status',
    :mute_mic, '$!! pactl set-source-mute @DEFAULT_SOURCE@ toggle && $refresh_i3status',
    :mod, 'Mod4',
    :ws1, '1',  
    :ws2, '2',
    :ws3, '3',
    :ws4, '4',
    :ws5, '5',
    :ws6, '6',
    :ws7, '7',
    :ws8, '8',
    :ws9, '9',
    :ws10,'10',
  ]

  KBD = {
    'M:Return' => '$! xfce4-terminal',
    'MC:f' => '$! firefox',
    'MC:Return' => '$! nvim-qt',
    'XF86AudioRaiseVolume' => :raise_volume,
    'XF86AudioLowerVolume' => :lower_volume,
    'XF86AudioMute' => :mute_volume,
    'XF86AudioMicMute' => :mute_mic,
    'MS:q' => 'kill',
    'M:d' => '$!! dmenu_run',
    'MS:h' => 'move left',
    'MS:j' => 'move down',
    'MS:k' => 'move up',
    'MS:l' => 'move right',
    'M:h' => 'focus left',
    'M:j' => 'focus down',
    'M:k' => 'focus up',
    'M:l' => 'focus right',
    'M:v' => 'split v',
    'M:b' => 'split h',
    'M:s' => 'layout stacking',
    'M:w' => 'layout tabbed',
    'M:e' => 'layout toggle split',
    'MS:e' => 'floating toggle',
    'M:space' => 'focus mode_toggle',
    'M:a' => 'focus parent',
    'M:1' => 'workspace number $ws1',
    'MS:1' => 'move container to workspace number $ws1',
    'M:2' => 'workspace number $ws2',
    'MS:2' => 'move container to workspace number $ws2',
    'M:3' => 'workspace number $ws3',
    'MS:3' => 'move container to workspace number $ws3',
    'M:4' => 'workspace number $ws4',
    'MS:4' => 'move container to workspace number $ws4',
    'M:5' => 'workspace number $ws5',
    'MS:5' => 'move container to workspace number $ws5',
    'M:6' => 'workspace number $ws6',
    'MS:6' => 'move container to workspace number $ws6',
    'M:7' => 'workspace number $ws7',
    'MS:7' => 'move container to workspace number $ws7',
    'M:8' => 'workspace number $ws8',
    'MS:8' => 'move container to workspace number $ws8',
    'M:9' => 'workspace number $ws9',
    'MS:9' => 'move container to workspace number $ws9',
    'M:10' => 'workspace number $ws10',
    'MS:10' => 'move container to workspace number $ws10',
    'MS:c' => 'reload',
    'MS:r' => 'restart',
    'M:r' => 'mode "resize"',
  }

  EXEC = [ 
    'dex -ae i3 -s ~/.config/autostart',
  ]

  WINDOW_TR = {
    f_c: 'client.focused',
    i_c: 'client.focused_inactive',
    u_c: 'client.unfocused',
    urg_c: 'client.urgent',
    bg_c: 'client.background'
  }

  WINDOW_DEFAULTS = { 
    # <border> <bg> <fg> <indicator> <child_border>
    f_c: ['#dc322f', '#002b36', '#b58900', '#268bd2', '#002b36'],
    i_c: ['#073642', '#073642', '#93a1a1', '#073642', '#073642'],
    u_c: ['#073642', '#073642', '#657b83', '#073642', '#073642'],
    urg_c: ['#d33682', '#d33682', '#002b36', '#d33682', '#d33682'],
    bg_c: ['#002b36'],
  }

  INCLUDE = [
    'vars',
    'window',
    'status',
    'binding_modes',
    'keybindings',
    'exec',
  ]

  MODES = {
    launcher: {
      '!f' => 'firefox',
      '!n' => 'nvim-qt',
      '!t' => 'thunar',
      '!e' => 'emacs',
    },
    resize: {
      desc: 'Resize: [j]:shrink width [k]: grow height [h]:shrink height [l]:grow width',
      'j' => 'resize shrink width 10 px or 10 ppt' ,
      'k' => 'resize grow height 10 px or 10 ppt',
      'h' => 'resize shrink height 10 px or 10 ppt',
      'l' => 'resize grow width 10 px or 10 ppt',
    }
  }
end

