require 'sinatra/base'
require 'yaml'
require 'json'
require 'timeout'


module PatriciaApp
  class App < Sinatra::Base

    def self.generate_routes
      # CSS
      settings.app_css.each do |dir|
        get dir do
          content_type 'text/css'
          File.new(File.join(settings.app_css_dir, dir)).readlines
        end
      end

      # JS
      settings.app_js.each do |dir|
        get dir do
          content_type 'text/js'
          File.new(File.join(settings.app_js_dir, dir)).readlines
        end
      end
    end

    configure do
      begin
        config_file = File.expand_path('../../../bin/app_config.yml',
                                       __FILE__)
        app_configs = YAML.load_file(config_file)
        markup_dir = app_configs[:markup_dir]
        set :environment, 'production'
        set :app_markup_dir, markup_dir
        set :app_markdown_glob, '.{md,markdown,org,textile,rst,rest,restx}'
        set :app_css_path, '/patricia.css'
        set :app_js_path, '/patricia.js'
        set :app_public_folder, app_configs[:public_folder]
        set :app_tooltips, app_configs[:tooltips]
        set :app_editor, app_configs[:editor]
        set :app_ace, app_configs[:ace]
        set :app_ace_theme, app_configs[:ace_theme]
        set :app_ace_keybinding, app_configs[:ace_keybinding]
        set :app_ace_mode, app_configs[:ace_keybinding]
        set :app_gfm, app_configs[:gfm]
        # CSS
        if app_configs[:css_dir] != nil
          set :app_css_dir, app_configs[:css_dir]
          css_paths = Dir[app_configs[:css_dir] + '/**/*.css']
            .collect do |path|
            path.gsub(/#{app_css_dir}/, '')
          end
          set :app_css, css_paths
        else
          set :app_css_dir, ''
          set :app_css, []
        end
        # JS
        if app_configs[:js_dir] != nil
          set :app_js_dir, app_configs[:js_dir]
          js_paths = Dir[app_configs[:js_dir] + '/**/*.js']
            .collect do |path|
            path.gsub(/#{app_js_dir}/, '')
          end
          set :app_js, js_paths
        else
          set :app_js_dir, ''
          set :app_js, []
        end
        # Content types
        set :app_content_types, {
          'png' => 'image/png',
          'jpg' => 'image/jpeg',
          'jpeg' => 'image/jpeg',
          'gif' => 'image/gif',
          'bmp' => 'image/bmp',
          'torrent' => 'image/x-bittorrent',
          'svg' => 'image/svg+xml',
          'xml' => 'application/xml',
          'atom' => 'application/atom-xml',
          'zip' => 'application/zip',
          'bz' => 'application/x-bzip',
          'bz2' => 'application/x-bzip2',
          'gzip' => 'application/gzip',
          'pdf' => 'application/pdf',
          'sh' => 'application/x-sh',
          '7z' => 'application/x-7z-compressed',
          'swf' => 'application/x-shockwave-flash',
          'xml' => 'application/xml;charset=utf-8',
          'avi' => 'video/x-msvideo',
          'txt' => 'text/plain',
          'css' => 'text/css',
          'csv' => 'text/csv',
          'html' => 'text/html',
          # Send markup source files
          #
          # One can argue if this is semantically correct (alternative:
          # `plain/x-markdown;charset=UTF-8'), but as there is no official
          # final specification and this solution comes with the highest
          # browser-compatibility, it is preferred.
          'md' => 'text/plain',
          'markdown' => 'text/plain',
          'org' => 'text/plain',
          'textile' => 'text/plain',
          'rst' => 'text/plain',
          'rest' => 'text/plain',
          'rstx' => 'text/plain',
        }
        self.generate_routes
      rescue
        # Ignore.
      end
    end

    helpers do
      def build_toc
        Patricia::Wiki.new(settings.app_markup_dir).build_toc
      end

      def generate_page_title
        capitalize_all(File.basename(settings.app_markup_dir).gsub(/-/,
                                                                   ' '))
      end

      def capitalize_all(string)
        string.split.inject([]) do |result, token|
          result << token[0].capitalize + token[1..-1]
        end.join(' ')
      end
    end

    get '/' do
      if settings.app_gfm
        html = Patricia::Converter.gfm_to_html(File.dirname(__FILE__) +
                                               '/views/wiki/welcome.md')
      else
        html = Patricia::Converter.to_html(File.dirname(__FILE__) +
                                           '/views/wiki/welcome.md')
      end
      @html = '<div id="p-welcome-text-page" class="">' + html + '</div>'
      @toc = build_toc
      @title = generate_page_title
      @page_title = ''
      @breadcrumb = ''
      @stylesheets = settings.app_css
      @javascripts = settings.app_js
      haml 'wiki/page'.to_sym, :layout => :application
    end

    get %r{/404/?} do
      haml '404'.to_sym, :layout => :application
    end

    get %r{/patricia/search/?} do
      haml :search, :layout => :application
    end

    post %r{/patricia/search/?} do
      @previous_search_query = params[:search_query] || ''
      if params[:case_sensitive]
        search_query = %r{#{params[:search_query]}}
        @previous_search_query_was_sensitive = true
      else
        search_query = %r{#{params[:search_query]}}i
        @previous_search_query_was_sensitive = false
      end
      # Search all markup files
      @results = []
      paths = Dir[File.join(settings.app_markup_dir, '/**/*' +
                            settings.app_markdown_glob)]
      paths.each do |path|
        if File.read(path)
          p = path.gsub(/#{settings.app_markup_dir}/, '')
          file_name = File.basename(p, '.*')
          no_ext = File.join(File.dirname(p), file_name).sub(/^\.\//, '')
          beautiful_file_name = capitalize_all(file_name.gsub(/-/, ' '))
          beautiful_path = no_ext.split('/').collect do |s|
            capitalize_all(s.gsub(/-/, ' '))
          end.delete_if(&:empty?).join(' > ')
          content = File.read(path)
          lines = content.split("\n").length
          if content =~ search_query
            @results << [beautiful_file_name, no_ext, beautiful_path,
                         lines]
          end
        end
      end
      haml :search, :layout => :application
    end

    post %r{/patricia/offsets/?} do
      if settings.app_editor
        file_content = File.read(File.join(settings.app_markup_dir,
                                           params[:markup_url]))
        offsets = []
        # Time out if the RegEx is too complex.
        begin
          Timeout::timeout(3) do
            filler = " *\n*\w*"
            pattern = Regexp.new(filler, Regexp::MULTILINE)
            params[:string].split.each do |token|
              pattern =
                Regexp.new(pattern.to_s + filler + Regexp.quote(token),
                           Regexp::MULTILINE)
            end
            pattern = Regexp.new(pattern.to_s + filler, Regexp::MULTILINE)

            # Skip empty/whitespace only queries.
            if !pattern.to_s.empty? && !(pattern.to_s =~ /^\s*$/)
              file_content.scan(pattern) do |c|
                offsets << [$~.offset(0)[0], $~.offset(0)[1]]
              end
            end
          end
        rescue
          # Ignore.
        end

        content_type 'json'
        {:markup => file_content, :offsets => offsets}.to_json
      else
        redirect to('/404')
      end
    end

    post %r{/patricia/edit/?} do
      if settings.app_editor
        File.open(File.join(settings.app_markup_dir,
                            params[:markup_url]), 'w') do |f|
          f.puts(params[:string])
        end
      else
        redirect to('/404')
      end
    end

    get settings.app_css_path do
      pwd = File.dirname(__FILE__)
      css = ''
      [
       '/assets/stylesheets/bootstrap.min.css',
       '/assets/stylesheets/app.css',
      ].each do |path|
        css << File.read(pwd + path) + "\n\n"
      end
      content_type 'text/css'
      css
    end

    get settings.app_js_path do
      pwd = File.dirname(__FILE__)
      js = ''
      files =
        [
         '/assets/javascripts/jquery-1.11.0.min.js',
         '/assets/javascripts/bootstrap.min.js',
         '/assets/javascripts/app.js',
        ]
      files << '/assets/javascripts/tooltips.js' if settings.app_tooltips
      files << '/assets/javascripts/src-min-noconflict/ace.js' if
        settings.app_ace
      files << '/assets/javascripts/ace_editor.js' if settings.app_ace
      files << '/assets/javascripts/editor.js' if settings.app_editor
      files.each do |path|
        js << File.read(pwd + path) + "\n\n"
      end
      content_type 'text/javascript'
      js
    end

    get %r{/(.*)} do |path|
      # This assumes that there are not two or more files with the same
      # file name, but different extensions (e.g. `/smart/green/frog.md'
      # and `/smart/green/frog.markdown'). If so, it will chose the one it
      # finds first.
      # If this becomes a problem in the future, one could send a
      # disambiguation page with links to each of the files for this
      # request.
      begin
        file_path = Dir[settings.app_markup_dir + '/' + path +
                        settings.app_markdown_glob].first
        @markup_url = file_path.gsub(/#{settings.app_markup_dir}/, '')
        if settings.app_gfm
          @html = Patricia::Converter.gfm_to_html(file_path)
        else
          @html = Patricia::Converter.to_html(file_path)
        end
        @toc = build_toc
        arrow = ' > '
        @title = generate_page_title
        @breadcrumb = capitalize_all(File.dirname(path).gsub(/\//, ' '))
        breadcrumb_array = @breadcrumb.split
        if breadcrumb_array.length >= 1 && breadcrumb_array.first !~ /\./
          @breadcrumb = breadcrumb_array.inject([]) do |result, token|
            result << capitalize_all(token.gsub(/-/, ' '))
          end.join(arrow) + arrow
        else
          @breadcrumb = ''
        end
        @stylesheets = settings.app_css
        @javascripts = settings.app_js
        @page_title = capitalize_all(File.basename(path).gsub(/-/, ' '))
          .split.join(' ')
        @ace = settings.app_ace
        @ace_theme = settings.app_ace_theme if settings.app_ace_theme
        @ace_keybinding = settings.app_ace_keybinding if
          settings.app_ace_keybinding
        @ace_mode = settings.app_ace_mode if settings.app_ace_mode
        haml 'wiki/page'.to_sym, :layout => :application
      rescue
        file_path = File.join(settings.app_markup_dir, path)
        if File.exists?(file_path)
          ext = File.extname(path).gsub(/\./, '')
          # Try to guess the correct content type for popular content
          # types.
          content_type settings.app_content_types[ext] ||
            'application/octet-stream'
          send_file(file_path)
        else
          redirect to('/404')
        end
      end
    end

    # `patricia.rb' already defines this, but redefining it here decouples
    # the web app from the static file generator.
    def _without_extension(path)
      path.sub(/\..*$/, '')
    end

  end
end
