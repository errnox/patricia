require 'fileutils'
require 'kramdown'
require 'org-ruby'
require 'redcloth'
require 'pandoc-ruby'
require 'github/markup'


module Patricia

  class Converter
    @@converters = {
      # Markdown
      'md' => :kramdown,
      'markdown' => :kramdown,
      # Org
      'org' => :org_ruby,
      # Textile
      'textile' => :redcloth,
      # reStructuredText
      'rst' => :pandoc_rst,
      'rest' => :pandoc_rst,
      'restx' => :pandoc_rst,
    }

    def self.converters
      @@converters
    end

    # Markdown

    def self.kramdown(markup)
      Kramdown::Document.new(markup).to_html
    end

    # Org

    def self.org_ruby(markup)
      Orgmode::Parser.new(markup).to_html
    end

    # Textile

    def self.redcloth(markup)
      RedCloth.new(markup).to_html
    end

    # reStructuredText

    def self.pandoc_rst(markup)
      PandocRuby.new(markup, :from => :rst, :to => :html).convert
    end

    def self.to_html(path)
      markup = File.read(path)
      self.send @@converters[File.extname(path).sub(/^\./, '')], markup
    end

    def self.gfm_to_html(path)
      GitHub::Markup.render(path)
    end
  end

  class Wiki

    attr_reader :dirs, :output_dirs, :asset_files, :input_dir, :header,
    :footer

    def initialize(input_dir, **options)
      options = {:output_dir => 'output', :js => [], :css =>
        []}.merge(options)
      @dirs = {}
      @output_dirs = []
      @input_dir = input_dir
      @output_dir = options[:output_dir]
      @asset_files = []
      options[:css] = [] if options[:css] == nil
      options[:js] = [] if options[:js] == nil
      @css = options[:css]
      @js = options[:js]

      directory_hash
      @toc = build_toc
    end

    def _css_tags(paths)
      tags = ''
      paths.each do |path|
        tags << "\n" +
          '<link rel="stylesheet" href="' + path + '" type="text/css">'
      end
      tags
    end

    def _js_tags(paths)
      tags = ''
      paths.each do |path|
        tags << "\n" + '<script type="text/javascript" src="' + path +
          '" type="text/css"></script>'
      end
      tags
    end

    def directory_hash(*args)
      path = args[0] || @input_dir
      data = {:data => (args[0] || path)}
      data[:children] = children = []
      Dir.foreach(path) do |entry|
        next if entry == '..' || entry == '.'
        full_path = File.join(path, entry)
        if File.directory?(full_path)
          children << directory_hash(full_path)
        else
          children << full_path
        end
      end
      @dirs = data
    end

    def render(*dirs)
      FileUtils.rm_r(@output_dir) if Dir.exists?(@output_dir)
      render_files *dirs
    end

    def _without_extension(path)
      File.join(File.dirname(path), File.basename(path, '.*'))
    end

    def _without_input_dir(path)
      path.sub(/#{@input_dir}/, '')
    end

    def render_files(*dirs)
      dirs = dirs[0] || @dirs
      dirs.each_pair do |k, v|
        if v.class == Array
          v.each do |child|
            if child.class == Hash
              render_files child
            else
              ext = File.extname(child).sub(/\./, '')
              if Converter.converters.keys.include?(ext)
                Dir.mkdir(@output_dir) unless Dir.exists?(@output_dir)
                if File.file?(child)
                  output_child_dir =
                    _without_input_dir(_without_extension(child))
                else
                  output_child_dir =
                    _without_input_dir(child)
                end
                FileUtils.mkdir_p(File.join(@output_dir,
                                            output_child_dir))
                @output_dirs <<
                  _without_extension(_without_input_dir(output_child_dir))
                File.open(@output_dir + '/' + output_child_dir +
                          '/index.html', 'w') do |f|
                  f.puts page(Converter::to_html(child))
                end
              else
                # Copy images etc. over
                src = child
                dest = File.join(@output_dir,
                                 _without_input_dir(File.dirname(child)),
                                 File.basename(child))
                @asset_files << dest
                # Do not mk the output dir struct within itself.
                if _without_input_dir(File.dirname(child)) !=
                    @input_dir.gsub(/\/$/, '')
                  FileUtils.mkdir_p(File.dirname(dest))
                else
                  next
                end
                FileUtils.cp(src, dest)
              end
            end
          end
        end
      end
    end

    def page(content)
      <<-PAGE
<!DOCTYPE html>
<html>
  <head>
    <title></title>
    #{_css_tags(@css) if @css.length > 0}
    <meta charset="utf8"/>

    <!-- Turn caching off. -->
    <meta http-equiv="cache-control" content="max-age=0" />
    <meta http-equiv="cache-control" content="no-cache" />
    <meta http-equiv="expires" content="0" />
    <meta http-equiv="expires" content="Tue, 01 Jan 1980 1:00:00 GMT" />
    <meta http-equiv="pragma" content="no-cache" />

    <base href="/" target="_self"/>
  </head>
  <body>
    <div id="toc">
#{@toc}
    </div>
    <div id="content">
#{content}
    </div>
  <body>
    #{_js_tags(@js)}
  </body>
</html>
PAGE
    end

    def _list_link(path)
      basename = File.basename(path).split('-').map(&:capitalize).join(' ')
      pp = _without_extension(_without_input_dir(path))
      p = pp.gsub(/\.\//, '')  # .gsub(/\//, ' > ')
      if File.file?(path)
        # '<li><a href="' + _without_extension(_without_input_dir(path)) +
        #   '">' + _without_extension(basename).sub(/\.\//, '') + '</a>'
        '<li><a title="' + p + '" href="' + pp + '">' +
          _without_extension(basename).sub(/\.\//, '') + '</a>'
      else
        '<li><span title="' + p + '">' + basename + '</span>'
      end
    end

    def build_toc(*args)
      dirs = args[0] || @dirs
      html = args[1] || ''
      dirs.each_pair do |k, v|
        next if v == @input_dir
        if v.class == Array
          html << '<ul>' if !v.empty?
          v.each do |child|
            if child.class == Hash
              build_toc child, html
            else
              ext = File.extname(child).sub(/\./, '')
              next if !Converter.converters.keys.include?(ext)
              html << _list_link(child)
            end
          end
          html << '</ul>' if !v.empty?
        else
          html << _list_link(v)
        end
      end
      html << '</li>'
      html
    end
  end
end
