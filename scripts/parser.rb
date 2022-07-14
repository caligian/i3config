require 'yaml'

module Parser
  DEFAULTS = YAML.load(File.read('defaults.yaml'))
  VARS = DEFAULTS['vars']
  CONFIG_DIR = File.join(ENV['HOME'], '.config', 'i3')

  # #{ruby expression}
  # ${variable}
  # %{environment variable}
  # !{sh command}
  def expand_vars(s)
    s = s.to_s
    vars = s.scan(/[$#%!][{]?[^}]+}?/).flatten
    vars.each {|var| 
      varname = var[2...var.length-1]

      if var[0] == '#'
        s = s.gsub(var, eval(varname) || '')
      elsif var[0] == '!'
        s = s.gsub(var, `#{varname}`)
      elsif var[0] == '%'
        s = s.gsub(var, ENV[varname] || '')
      elsif var[0] == '$'
        s = s.gsub(var, VARS[varname] || '')
      end
    }
    s
  end

  def check_color(c)
    c !~ /^#?[0-9a-fA-F]{6}/ and raise "Invalid hex: #{c}"
  end

  def parse(conf, s:[], d:0, default: {})
    spaces = d > 0 ? '    ' * d : ''

    default.merge(conf).each { |k,v| 
      default_v = default[k]
      v = conf[k] || default_v

      if block_given?
        k, v = yield [k, v]
      end

      if v.is_a? Hash
        s.push "#{spaces}#{k} {"
        parse(v, s: s, d:d+1, default: v)
        s.push "#{spaces}}"
      else
        # Special case for checking number arrays
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

  def parse_options(opts)
    parse(opts, default: DEFAULTS['options']).join "\n"
  end

  def parse_autostart(cmds)
    (DEFAULTS['autostart'] + cmds).map {|c| 'exec --no-startup-id ' + expand_vars(c)}.join "\n"
  end

  def parse_bar(conf)
    s = parse(conf, d:1, default: DEFAULTS['bar'])
    s[0] = "bar {\n#{s[0]}"
    s.push "\n}"
    s.join "\n"
  end

  def parse_colors(conf)
    parse(conf, default: DEFAULTS['colors'])
  end

  def parse_keybindings(conf)
    # M = Super
    # C = Control
    # S = Shift
    # A = Alt/Meta
    # spec: {Modifier}:{keys}
    s = []

    DEFAULTS['keybindings'].merge(conf).each do |keys, cmd|
      keys = keys.strip
      mod = ''
      ks = ''
      no_mod = keys !~ /:/ 
      keybinding = []
      default_cmd = cmd
      cmd = conf[keys] || default_cmd
      tr = {
        'M' => 'Mod4',
        'C' => 'Control',
        'S' => 'Shift',
        'A' => 'Alt',
      }

      if keys[0] == '!'
        keys = keys.sub '!', ''
        cmd = "exec --no-startup-id #{cmd}"
      end

      if keys =~ /^XF86/ 
        no_mod = true
        ks = keys 
      else
        mod, ks = keys.split ':'
      end

      !no_mod and mod.length == 0 or !ks or ks.length == 0 and raise 'Key specification is wrong. spec: [MCSA]+:[:ascii:]+'

      mod.split('').each {|c| 
        !tr.has_key?(c) and raise "Invalid modifier provided in #{keys}" 
        keybinding.push(tr[c])
      }

      cmd = expand_vars cmd
      keybinding = !no_mod ? keybinding.join('+') + '+' : ''
      s.push("bindsym " + keybinding + "#{ks} #{cmd}")  
    end

    s.join "\n"
  end

  # No defaults exist for this yet
  def parse_modes(conf)
    binding_modes = []
    desc = {}

    DEFAULTS['modes'].merge(conf).each do |mode, cmd|
      str = [false]
      mode_s = desc[mode] || []
      s = []
      default = [%Q(    bindsym Escape mode "default"), %Q(    bindsym Return mode "default")]

      if mode_s.is_a? Array
        cmd.each { |k,app|
          mode_s.push app.sub(Regexp.compile("^(#{k.sub('!', '')})"), '[\1]')
        }
        str[0] = %Q(set $#{mode} #{mode.capitalize}: #{mode_s.join ' '}\nmode "$#{mode}" {) 
      else
        str[0] = %Q(set $#{mode} #{mode_s}\nmode "$#{mode}" {)
      end

      s = cmd.map {|k,app| 
        if !(k == :desc)
          app = expand_vars app

          if k[0] == '!'
            app = 'exec --no-startup-id ' + expand_vars(app)
            k = k.sub('!', '')
          end

          "    bindsym #{k} #{app}"
        else
          ''
        end
      }
      s = s.filter {|i| i.length != 0} 
      s = s + default
      str.push s.join "\n"
      str.push "}"
      binding_modes.push str.join "\n"
    end

    binding_modes.join "\n"
  end

  def parse_includes(paths)
    (paths + DEFAULTS['includes']).map {|p| 
      "include " + File.join(CONFIG_DIR, 'i3', p + '.conf')
    }.join "\n"
  end
 
  def parse_vars
    parse({}, default: VARS) { |k, v|
      "set $#{k} #{v}"
    }
  end

  def save(includes: [], modes: {}, keybindings: {}, options: {}, colors: {}, bar: {}, autostart: [])
    s = []
    s.push parse_vars
    s.push parse_keybindings(keybindings)
    s.push parse_autostart(autostart)
    s.push parse_options(options)
    s.push parse_colors(colors)
    s.push parse_bar(bar)
    dest = File.join(CONFIG_DIR, 'config')
    File.write(dest, s.join("\n"))
  end
end

include Parser
puts expand_vars("!{ls -l}")
