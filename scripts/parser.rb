class Parser
  require 'yaml'

  CONFIG_DIR = File.join(ENV['HOME'], '.config', 'i3')

  def initialize(defaults)
    @defaults = defaults
    @vars = @defaults['vars']
  end

  def mkconf(key, config)
    _mkarr = ->(k, conf) {
      default = @defaults[k]
      if v.length < default.length 
        v = v + default.slice(v.length, default_v.length)
      end

      v.map! {|c| 
        c.strip!
        check_color c
        c !~ /^#/ ? '#' + c : c 
      }
    }
    _mkconf = ->(k, conf) {
      default = @defaults[k]
      default.each do |k, value|
        if !conf.has_key? k
          conf[k] = value
        elsif default.is_a? Array
          conf[k] = _mkarr.call(k, conf[k])
        end
      end
    }

    if key == 'global'
      @defaults.each {|k, v| _mkconf.call k, config[k]}
    elsif config.is_a? Hash
      _mkconf.call key, config
    elsif config.is_a? Array
      _mkarr.call key, config
    elsif !config
      if @defaults[key].is_a? Array
        config = _mkarr.call key, []
      elsif @defaults[key].is_a? Hash
        config = _mkconf.call key, {}
      else
        config = @defaults[key]
      end
    end

    config
  end

  # #{ruby expression}
  # ${variable}
  # %{environment variable}
  # !{sh command}
  def expand_vars(s)
    s = s.to_s
    vars = s.scan(/[$#%!][{][^}]+[}]/).flatten
    vars.each {|var| 
      varname = var[2...var.length-1]

      if var[0] == '#'
        s = s.gsub(var, eval(varname) || '')
      elsif var[0] == '!'
        s = s.gsub(var, `#{varname}`)
      elsif var[0] == '%'
        s = s.gsub(var, ENV[varname] || '')
      elsif var[0] == '$'
        s = s.gsub(var, @vars[varname] || '')
      end
    }
    s
  end

  def check_color(c)
    c !~ /^#?[0-9a-fA-F]{6}/ and raise "Invalid hex: #{c}"
  end

  def check_color_arr(arr)
    arr.each {|c| check_color c}
  end

  def parse(key, conf=false, depth: 0, &block)
    _get_arr_s = lambda {}
    _get_s = lambda {}
    _get_hash_s = lambda {}

    
    _get_arr_s = ->(key, arr) { 
      check_color_arr arr
      key + " " + arr.join(" ") 
    }

    _get_s = ->(key, value) {
      value = value || @defaults[key]
      value.is_a?(Array) ? _get_arr_s.call(key, value) : "#{key} #{value}"
    }

    _get_hash_s = ->(key, h, depth: 0, str: []) {
      spaces = depth > 0 ? '    ' * depth : ''
      h.each { |k, v|
        if block; k, v = block.call(k, v); end

        if v.is_a? Hash
          str.push "#{spaces}#{k} {"
          _get_hash_s.call(key, v, depth: depth+1, str: str)
          str.push "#{spaces}}"
        else
          str.push spaces + _get_s.call(k, v)
        end
      }
      str.join "\n"
    }

    conf = mkconf(key, conf)
    if conf.is_a? Hash
      _get_hash_s.call key, conf, depth: depth
    else
      _get_s.call key, conf
    end
  end

  def parse_options(opts)
    parse('options', opts)
  end

  def parse_autostart(cmds)
    cmds = cmds || []
    (@defaults['autostart'] + cmds).map {|c| 'exec --no-startup-id ' + expand_vars(c)}.join "\n"
  end

  def parse_bar(conf)
    s = ["bar {", parse('bar', conf || false, depth: 1)]
    s.push "\n}"
    s.join "\n"
  end

  def parse_colors(conf)
    parse('colors', conf)
  end

  def parse_keybindings(conf)
    # M = Super
    # C = Control
    # S = Shift
    # A = Alt/Meta
    # spec: {Modifier}:{keys}
    s = []

    conf = mkconf('keybindings', conf)
    conf.each do |keys, cmd|
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

    mkconf('modes', conf).each do |mode, cmd|
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

  def parse_includes(paths={})
    (paths + @defaults['includes']).map {|p| 
      "include " + File.join(CONFIG_DIR, 'i3', p + '.conf')
    }.join "\n"
  end
 
  def parse_vars(vars={})
    parse('vars', vars) { |k, v|
      "set $#{k} #{v}"
    }
  end

  def compile(colors: {}, bar: {}, keybindings: {}, autostart: [], options: {}, save: false)
    s = []
    s.push parse_colors(colors)
    s.push parse_bar(bar)
    s.push parse_keybindings(keybindings)
    s.push parse_autostart(autostart)
    s.push parse_options(options)
    s = s.join "\n"

    if save
      dest = File.join(CONFIG_DIR, 'config')
      File.write(dest, s)
    end

    s
  end
end
