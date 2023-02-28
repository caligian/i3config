# Window resizing
mode "resize" {
  bindsym h resize shrink width 10 px or 10 ppt
  bindsym j resize grow height 10 px or 10 ppt
  bindsym k resize shrink height 10 px or 10 ppt
  bindsym l resize grow width 10 px or 10 ppt
  bindsym Return mode "default"
  bindsym Escape mode "default"
  bindsym Caps_Lock mode "default"
  bindsym Mod4+r mode "default"
}
bindsym Mod4+r mode "resize"
