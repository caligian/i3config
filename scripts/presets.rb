require 'yaml'

class Presets
  CONFIG_DIR = File.join(ENV['HOME'], '.config', 'i3')
  DEFAULTS = YAML.load(File.read('defaults.yaml'))

  attr_reader :dir, :default, :presets

  def initialize(name, default)
    @dir = File.join(CONFIG_DIR, name)
    !Dir.exist?(@dir) && `mkdir -p #{@dir}`
    @default = default
  end

  def write(name, conf)
    File.write(File.join(@dir, name + '.yaml'), YAML.dump(conf.merge(@default)))
  end

  def load
    @presets = Dir.children(@dir).map {|f| File.join(@dir, f)}
  end

  def get(pattern)
    @presets.filter {|f| f =~ /ya?ml$/ and f =~ pattern }
  end

  def read(pattern)
    s = {}
    get(pattern).each {|f| s[f] = YAML.load(File.read(f)) }
    s
  end

  def delete(pattern)
    get(pattern).each {|f| `rm #{f}`}
  end

  def menu(dmenu: false, rofi: false, read: false)
    basename = @presets.map {|f| File.basename(f).sub(/.ya?ml$/, '')}.sort
    show = ->() {basename.each_with_index {|f, idx| printf("%-10d %s\n", idx, f.strip)}}
    valid = false
    n = basename.length

    if !dmenu and !rofi
      while not valid
        show.call
        print 'Enter integer> '
        input = gets 
        input.strip!

        if input == ''
          puts 'No input provided'
        elsif input !~ /[0-9]+/
          puts 'Invalid input provided'
        else
          input = $~.to_s.to_i

          if input >= n || input < 0
            puts 'Invalid index provided'
          end

          valid = @presets[input]
        end
      end
      valid
    elsif dmenu or rofi
      input = ''

      if dmenu
        input = `echo -e '#{basename.join "\n"}' | dmenu -i -b -l 10 -fn 'Sans 12'`
      else
        input = `echo -e '#{basename.join "\n"}' | rofi -i -dmenu`
      end

      input.strip!
      input = input == '' ? false : read ? YAML.load(File.read(@presets[basename.index input])) : @presets[basename.index(input)]
    end
  end
end

p = Presets.new('global', Presets::DEFAULTS)
p.load
p.menu(rofi: true, read: true)
