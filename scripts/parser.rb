require_relative 'defaults'

module Parser
  include Defaults

  VARS_H = {}
  VARS_LOADED = false

  def expand_vars(s)
    if !VARS_LOADED
      for i in (0...VARS.length).step(2).to_a do
        k, v = VARS[i], VARS[i+1]
        reg = Regexp.compile("$#{v}")
        v = v =~ reg ? (VARS_H[k] || '')  : v.sub(reg, VARS_H[k] || '') 
        VARS_H[k] = v
      end
    end

    if s.is_a? Symbol 
      VARS_H[s] || ''
    else
      s = s.to_s
      vars = s.scan(/([$][a-zA-Z0-9_!]+)/).flatten
      vars.each {|var| 
        s = s.gsub(var, VARS_H[var.sub('$', '').to_sym] || '')
      }
      s
    end
  end

  def check_color(c)
    c !~ /^#?[0-9a-fA-F]{6}/ and raise "Invalid hex: #{c}"
  end

  def parse(conf, s:[], d:0, tr: false, default: false)
    tr = tr || {}
    default = default || {}
    conf = default.merge conf
    spaces = d > 0 ? '    ' * d : ''

    conf.each { |k,v| 
      _k = k
      k = tr.has_key?(k) ? tr[k] : k
      default_v = default[k] || []

      if block_given?
        k, v = yield [k, v]
      end

      if k.is_a? Hash
        s.push "#{spaces}#{_k} {\n"
        parse(v, s: s, d:d+1, tr: k)
        s.push "#{spaces}}"
      else
        k = k.to_s
        if v.is_a? Array
          v = v + (default_v.slice(v.length, default_v.length) || [])
          v = v.map {|c| 
            c.strip!
            check_color c
            c !~ /^#/ ? '#' + c : c 
          }
          s.push "#{spaces}#{k} #{v.join ' '}" 
        else
          v = expand_vars v
          s.push "#{spaces}#{k} #{v}"
        end
      end
    }

    s
  end

  def parse_options(opts={})
    parse(opts, default: OPTIONS).join "\n"
  end

  def parse_exec(cmds=[])
    (EXEC + cmds).map {|c| expand_vars c}.join "\n"
  end

  def parse_i3bar(conf={})
    s = parse(conf, tr: I3BAR_TR, d:1, default: I3BAR_DEFAULTS)
    s[0] = "bar {\n#{s[0]}"
    s.push "\n}"
    s.join "\n"
  end

  def parse_window_colors(conf={})
    parse(conf, tr: WINDOW_TR, default: WINDOW_DEFAULTS)
  end

  def parse_keybindings(conf={}, default: KBD)
    # M = Super
    # C = Control
    # S = Shift
    # A = Alt/Meta
    # spec: {Modifier}:{keys}
    s = []
    conf.merge(KBD).each do |keys, cmd|
      keys = keys.strip
      mod = ''
      ks = ''
      no_mod = false

      if keys =~ /^XF86/ 
        no_mod = true
        ks = keys 
      else
        mod, ks = keys.split ':'
      end

      !no_mod and mod.length == 0 or !ks or ks.length == 0 and raise 'Key specification is wrong. spec: [MCSA]+:[:ascii:]+'

      tr = {
        'M' => 'Mod4',
        'C' => 'Control',
        'S' => 'Shift',
        'A' => 'Alt',
      }
      keybinding = []
      mod.split(//).each {|c| 
        !tr.has_key?(c) and raise "Invalid modifier provided in #{keys}" 
        keybinding.push(tr[c])
      }

      if cmd.is_a? Array
        interpreter, path = cmd
        interpreter = expand_vars interpreter
        path = expand_vars path
        !File.exist?(path) and raise "Invalid path provided: #{path}"
        cmd = "#{interpreter} #{path}"
      else
        cmd = expand_vars cmd
      end

      keybinding = !no_mod ? keybinding.join('+') + '+' : ''
      s.push(keybinding + "#{ks} exec --no-startup-id #{cmd}")  
    end

    s.join "\n"
  end

  def parse_binding_modes(conf={})
    binding_modes = []
    desc = {}
    conf = MODES.merge conf
    conf.each {|k,v| 
      desc[k] = conf[k][:desc] if conf[k][:desc]
      conf.delete :desc
    }

    conf.each do |mode, cmd|
      str = [false]
      mode_s = []
      s = []
      desc_given = desc[mode]

      if desc_given
        mode_s = cmd[:desc]
      end

      default = [%Q(    bindsym Escape mode "default"), %Q(    bindsym Return mode "default")]

      if !desc_given
        cmd.each { |k,app|
          mode_s.push app.sub(Regexp.compile("^(#{k})"), '[\1]')
        }
        desc_given = true
        str[0] = %Q(set $#{mode} #{mode_s.join ' '}\nmode "$#{mode}" {) 
      else
        str[0] = %Q(set $#{mode} #{mode_s}\nmode "$#{mode}" {)
      end

      s = cmd.map {|k,app| 
        app = expand_vars app

        if k[0] == '!'
          app = 'exec --no-startup-id ' + expand_vars(app)
          k = k.sub('!', '')
        end

        "    bindsym #{k} #{app}"
      }
      s = s + default
      str.push s.join "\n"
      str.push "}"
      binding_modes.push str.join "\n"
    end

    binding_modes.join "\n"
  end

  def parse_includes(paths=[])
    (paths + INCLUDE).map {|p| 
      "include " + File.join(I3_CONFIG_DIR, 'i3', p + '.conf')
    }.join "\n"
  end
end

include Parser
puts parse_binding_modes
