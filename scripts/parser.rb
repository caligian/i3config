require_relative 'defaults'

module Parser
  include Defaults

  def check_color(c)
    c !~ /^#?[0-9a-fA-F]{6}/ and raise "Invalid hex: #{c}"
  end

  def parse(conf, s:[], d:0, tr: false)
    tr == false and raise 'Translation table not provided'
    s.length == 0 && conf.merge!(I3BAR_DEFAULTS)
    spaces = d > 0 ? '    ' * d : ''

    conf.each { |k,v| 
      _k = k
      k = tr.has_key?(k) ? tr[k] : k

      if k.is_a? Hash
        s.push "#{spaces}#{_k} {\n"
        parse(v, s: s, d:d+1, tr: k)
        s.push "#{spaces}}"
      else
        k = k.to_s
        if v.is_a? Array
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

  def parse_i3bar_conf(conf)
    s = parse(conf, tr: I3BAR_TR, d:1)
    s[0] = "bar {\n#{s[0]}"
    s.push "\n}"
    s.join "\n"
  end
end

include Parser
puts parse_i3bar_conf({})
