require 'yaml'

class Preset
  require_relative 'parser'

  CONFIG_DIR = File.join(ENV['HOME'], '.config', 'i3')
  DEFAULTS = YAML.load_file('defaults.yaml')
  attr_reader :dir, :defaults, :presets, :presets_written, :type, :current_path, :parser

  def initialize(type)
    type = type.to_s
    @dir = File.join(CONFIG_DIR, 'presets', type)
    @type = type
    @presets_written = []
    @defaults = DEFAULTS[@type]
    @parser = Parser.new DEFAULTS
    @current_path = File.join(@dir, 'current_preset')

    `mkdir -p #{@dir}` unless Dir.exist?(@dir)
  end

  def get_presets
    @presets = Dir.children(@dir).map {|f| File.join(@dir, f)}
    blank?(@presets) ? false : @presets
  end

  def set(name)
    File.write(@current_path, name)
  end

  def write(name, conf)
    @presets_written << "#{name}.yaml"
    File.write(File.join(@dir, @presets_written[-1]), YAML.dump(conf.merge(@defaults)))
  end

  def write_sample(name)
    write(name, @defaults)
  end

  def get(pattern, read: false)
    p = {}

    @presets.each {|f| 
      path = File.join(@dir, f)
      next unless (f =~ /yaml$/ and f =~ pattern and File.exist? path)
      p[File.basename f] = read ? YAML.load_file(path) : path
    }

    p
  end

  def read(name)
    path = File.join(@dir, "#{name}.yaml")
    return unless File.exist? path
    YAML.load_file(path) 
  end

  def get_current
    return unless File.exist? @current_path
    File.read(@current_path)
  end

  def read_current
    return unless File.exist? @current_path
    path = "#{File.read(@current_path).chomp}.yaml"
    path = File.join(@dir, path)
    YAML.load_file(path)
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

  class << self
    def compile(save: true)
      conf = {}
      ks = ['colors', 'bar', 'autostart', 'options', 'keybindings']
      p = false
      ks.each {|type|
        p = Preset.new type
        current_preset = false
        default = Preset::DEFAULTS[type]
        current = default

        if File.exist?(p.current_path)
          current = p.read_current
        end

        conf[type.to_sym] = current
      }

      p.parser.compile(**conf, save: save)
    end
  end
end
