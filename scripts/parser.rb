require_relative 'defaults'

module Parser
  include Defaults

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
        out = yield [k, v]
        s.push out
      elsif k.is_a? Hash
        s.push "#{spaces}#{_k} {\n"
        parse(v, s: s, d:d+1, tr: k)
        s.push "#{spaces}}"
      else
        k = k.to_s
        if v.is_a? Array
          puts default_v
          v = v + (default_v.slice(v.length, default_v.length) || [])
          v = v.map {|c| 
            c.strip!
            check_color c
            c !~ /^#/ ? '#' + c : c 
          }
          s.push "#{spaces}#{k} #{v.join ' '}" 
        else
          s.push "#{spaces}#{k} #{v}"
        end
      end
    }

    s
  end

  def parse_options(opts={})
    parse(OPTIONS.merge(opts)).join "\n"
  end

  def parse_exec(cmds=[])
    (EXEC + cmds).join "\n"
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

  def parse_keybindings(conf={})
    # M = Super
    # C = Control
    # S = Shift
    # A = Alt/Meta
    # spec: {Modifier}:{keys}
  end
end

include Parser
puts parse_window_colors
