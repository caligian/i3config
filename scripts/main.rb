require_relative 'presets'
require_relative 'parser'
require 'optparse'
require 'yaml'

class Main
  include Parser

  def initialize
    @presets_dir = File.join Presets::CONFIG_DIR, 'presets'
    Dir.mkdir(@presets_dir) unless Dir.exist? @presets_dir
    @classes = Presets.get_classes
  end

  def write_sample_preset(type, name='default.yaml')
    path = File.join(@presets_dir, type, name)
    s = YAML.dump(Presets::DEFAULTS[type])
    dir = File.join(@presets_dir, type)
    Dir.mkdir(dir) unless Dir.exist?(dir)
    path = File.join(dir, name)
    File.write(path, s)
  end

  def new_preset(type, name)
    raise 'Invalid preset type specified' unless @classes.has_key? type
    preset = @classes[type]
    editor = editor || 'nvim'
    preset.write(name, {})
    name = preset.presets_written[-1]
    write_sample_preset type, name
    set_preset type, name
  end

  def write_preset(type, name, conf)
    @classes[type].write(name, conf)
  end

  def set_preset(type, name)
    File.write(
      File.join(@presets_dir, type, "current_preset"),
      name
    )
  end

  def get_preset(type, pattern)
    @classes[type].get pattern
  end

  def get_config(save: true)
    conf = {}

    Presets::DEFAULTS.each {|type, defaults|
      current_dir = File.join @presets_dir, type
      current_path = File.join current_dir, 'current_preset'
      current_preset = false
      current = defaults

      if File.exist?(current_path)
        current_preset = File.join(current_dir, File.read(current_path) + '.yaml')
        current = YAML.load(File.read(current_preset))
      end

      conf[type.to_sym] = current
    }

    compiled = compile(**conf)
    save && File.write(File.join(ENV['HOME'], '.config', 'i3', 'config'), compiled)
    compiled
  end
end

# Use this in an REPL and manage your presets
themer = Main.new
themer.new_preset 'colors', 'gruvbox'
