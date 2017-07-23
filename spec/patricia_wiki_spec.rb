require 'sinatra'
require_relative '../lib/patricia/patricia'


describe "Patricia::Wiki" do
  before(:all) do
    pwd = File.dirname(__FILE__)
    css_dir = File.join(pwd, 'assets/stylesheets/')
    js_dir = File.join(pwd, 'assets/javascripts/')
    css = Dir[css_dir + '/**/*.css']
      .collect { |x| x.sub(/#{css_dir}/, '') }
    js = Dir[js_dir + '/**/*.js'].collect { |x| x.sub(/#{js_dir}/, '') }
    markup_dir = File.join(pwd, 'random-test-wiki')
    @output_dir = File.join(pwd, 'output')

    @patricia = Patricia::Wiki.new(markup_dir, :@output_dir =>
                                   @output_dir, :css => css, :js => js)
    @patricia.render
  end

  describe "Rendering a markup dir to HTMl and writes it to an output \
directory containing  static HTML files" do
    it "contains the correct output for a Markdown input file" do
      output = File.read(File.join(@output_dir, 'colors/blue/index.html'))
      expect(output).to include('c40445cd-f06a-461c-9008-9ca890d893d1')
      expect(output).to include('blue')
      expect(output).to include('id="toc"')
      expect(output).to include('id="content"')
    end

    it "contains the correct output for an Org input file" do
      output =
        File.read(File.join(@output_dir, 'colors/bright-orange/index.html'))
      expect(output).to include('37ed608c-7c67-4a48-99ae-d351b576269d')
      expect(output).to include('bright')
      expect(output).to include('orange')
      expect(output).to include('id="toc"')
      expect(output).to include('id="content"')
    end

    it "contains the correct output for an Textile input file" do
      output =
        File.read(File.join(@output_dir, 'colors/dark-yellow/index.html'))
      expect(output).to include('46dbe50e-be4a-42b9-8796-50ddf302ead0')
      expect(output).to include('yellow')
      expect(output).to include('id="toc"')
      expect(output).to include('id="content"')
    end

    it "contains the correct output for an reStructuredText input file" do
      output =
        File.read(File.join(@output_dir, 'colors/light-pink/index.html'))
      expect(output).to include('8c180fdb-6db8-404d-ba7c-0fe8487234a3')
      expect(output).to include('pink')
      expect(output).to include('id="toc"')
      expect(output).to include('id="content"')
    end

    it "confirms that there is a static file copied over to the output \
directory" do
      exists = File.exists?(File.join(@output_dir, 'colors/image.png'))
      expect(exists).to be(true)
    end
  end


  describe "Helpers" do
    describe "Patricia::Wiki#_css_tags" do
      it "link tag markup for a list of resource paths" do
        paths =
          [
           'javascripts/one.css',
           'javascripts/two.css',
           'javascripts/three.css',
          ]
        css_tags = @patricia._css_tags(paths)
        output = <<-CSSTAGS

<link rel="stylesheet" href="javascripts/one.css" type="text/css">
<link rel="stylesheet" href="javascripts/two.css" type="text/css">
<link rel="stylesheet" href="javascripts/three.css" type="text/css">
CSSTAGS
        expect(css_tags).to eq(output.gsub(/\n$/, ''))
      end
    end

    describe "Patricia::Wiki#_js_tags" do
      it "script tag markup for a list of resource paths" do
        paths =
          [
           'stylesheets/one.js',
           'stylesheets/two.js',
           'stylesheets/three.js',
          ]
        js_tags = @patricia._css_tags(paths)
        output = <<-JSTAGS

<link rel="stylesheet" href="stylesheets/one.js" type="text/css">
<link rel="stylesheet" href="stylesheets/two.js" type="text/css">
<link rel="stylesheet" href="stylesheets/three.js" type="text/css">
JSTAGS
        expect(js_tags).to eq(output.gsub(/\n$/, ''))
      end
    end

    describe "Patricia::Wiki#_without_extension" do
      it "returns a file path without its extension" do
        output = @patricia._without_extension('/path/to/file.txt')
        expected_output = '/path/to/file'
        expect(output).to eq(expected_output)
      end
    end

    describe "Patricia::Wiki#_without_input_dir" do
      it "returns a path without the input markup directory" do
        subpath = '/subpath/to/file'
        path = File.join(@patricia.input_dir, subpath)
        output = @patricia._without_input_dir(path)
        expect(output).to eq(subpath)
      end
    end
  end
end
