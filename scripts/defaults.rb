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
    :"ipc-socket" => "~/.config/i3/i3.socket",
    default_border: 'pixel 3',
    default_floating_border: 'pixel 3',
    hide_edge_borders: 'smart',
  }

  KBD = {
    'M:Return' => 'exec --no-startup-id xfce4-terminal',
    'MC:f' => 'exec --no-startup-id firefox',
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
end

