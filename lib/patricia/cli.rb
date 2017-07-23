require_relative '../patricia'
require 'optparse'


module CLI

  @@options = {}

  def self.options
    @@options
  end

  OptionParser.new do |opts|
    opts.banner = 'Usage: patricia <markup-dir> [output-dir] [options]'
    opts.separator '---------------------------------------------------'
    opts.separator ''
    opts.separator 'Options:'

    opts.on('-p', '--port PORT', Integer,
            'Port to run the server on') do |v|
      options[:port] = v
    end

    opts.on('-c', '--css DIR', 'Directory with CSS files to be',
            'included in the output',
            '  (All .css files in this directory',
            '  and its subdirectories will be', '  hoovered up.)') do |v|
      options[:css] = File.expand_path(v.strip)
    end

    opts.on('-j', '--js DIR', 'Directory with JavaScript files to be',
            'included in the output', '  (All .js files in this directory',
            '  and its subdirectories will be', '  hovered up.)') do |v|
      options[:js] = File.expand_path(v.strip)
    end

    opts.on('-t', '--[no-]tooltips', 'Show tooltips with filepaths when',
            '  hovering over elements in the',
            '  sidebar (default: hide)') do |v|
      options[:tooltips] = v
    end

    opts.on('-e', '--editor', 'Enable markup editor') do |v|
      options[:editor] = v
    end

    opts.on('-g', '--gfm',
            'Use GitHub Flavored Markdown for all', '  rendering') do |v|
      options[:gfm] = v
    end

    opts.on('-a', '--ace',
            'Use Ace editor (only useful', " when using `-e')") do |v|
      options[:ace] = v
    end

    opts.on('--ace-theme THEME',
            'Theme to use with Ace') do |v|
      options[:ace_theme] = v
    end

    opts.on('--ace-keybinding KEYBINDING',
            'Keybinding to use with Ace') do |v|
      options[:ace_keybinding] = v
    end

    opts.on('--ace-mode MODE',
            'Mode to use with Ace') do |v|
      options[:ace_mode] = v
    end

    # Description

    opts.separator ''
    opts.separator 'Info:'

    opts.on_tail('-h', '--help', 'Show this message') do |v|
      puts opts
      exit
    end
    opts.on_tail('-v', '--version', 'Show the version') do |v|
      puts Patricia::VERSION
      exit
    end
  end.parse!

  @@options[:markup_dir] = ARGV.shift
  @@options[:output_dir] = ARGV.shift

  if !@@options[:markup_dir]
    puts 'ERROR: Need a markup directory'
    exit
  end

end
