module Defaults
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
      bg: '#002b36',
      fg: '#839496',
      sep: '#073642',

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

  WINDOW_TR = {
  }
end
