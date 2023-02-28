bar {
  status_command i3status
  binding_mode_indicator on
  position bottom
  strip_workspace_numbers no
  workspace_min_width 20
  workspace_buttons yes
  font pango: sans 13
#  font -xos4-terminus-bold-*-*-*-*-140-*-*-*-*-*-*
  colors {
    background #002b36
    statusline #abbcbc
    focused_workspace  #aac400 #627100 #ffffff
    active_workspace   #333333 #5f676a #ffffff
    inactive_workspace #004d60 #002b36 #ffffff
    urgent_workspace   #2f343a #900000 #ffffff
    binding_mode       #004d60 #002b36 #ffffff
  }
}
