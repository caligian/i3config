require 'yaml'

class Presets
  CONFIG_DIR = File.join(ENV['HOME'], '.config', 'i3')
  DEFAULTS = YAML.load(File.read('defaults.yaml'))

  attr_reader :dir, :defaults, :presets, :presets_written

  class << self
    def get_classes
      classes = {}
      Presets::DEFAULTS.each {|name, defaults|
        next if name == 'vars'
        cls =  Class.new(super_class=Presets)
        cls.const_set :CONFIG_PATH, CONFIG_DIR
        cls.const_set :DEFAULTS, defaults
        classes[name] = cls.new name
      }
      classes
    end
  end

  def initialize(name)
    @dir = File.join(CONFIG_DIR, 'presets', name)
    !Dir.exist?(@dir) && `mkdir -p #{@dir}`
    @presets = Dir.children(@dir).map {|f| File.join(@dir, f)}
    @presets_written = []
  end

  def write(name, conf)
    @presets_written << "#{name}.yaml"
    File.write(File.join(@dir, @presets_written[-1]), YAML.dump(conf.merge(DEFAULTS)))
  end

  def get(pattern)
    @presets.filter {|f| f =~ /yaml$/ and f =~ pattern }
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
