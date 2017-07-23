require 'rspec'
require 'rack/test'
require 'yaml'
require_relative '../lib/patricia/patricia'
require_relative '../lib/patricia/app'
require_relative 'test_helpers'


RSpec.configure do |c|
  c.include TestHelpers
end


describe "PatriciaApp::App" do
  include Rack::Test::Methods

  def app
    PatriciaApp::App
  end

  describe "Use default CSS and JavaScript" do

    before(:each) do
      config = {
        :css_dir => nil,
        :js_dir => nil,
        :tooltips => false,
        :editor => true,
        :ace => true,
        :ace_mode => 'markup',
        :ace_theme => 'solarized_dark',
        :ace_keybinding => 'emacs',
      }
      load_config(config)
    end


    describe "Rendering markup language Wiki files as HTML page" do

      after(:each) do
        # Check  for the existence of the sidebar
        expect(last_response.body).to include('toc')
        expect(last_response.body).to include('p-sidebar')
      end


      describe "Markup language: Markdown" do
        it "reads a Markdown file and renders it as HTML upon a GET \
request" do
          get '/colors/blue'
          expect(last_response).to be_ok
          expect(last_response.body)
            .to include('c40445cd-f06a-461c-9008-9ca890d893d1')
        end
      end

      describe "Markup language: Org" do
        it "reads an Org file and renders it as HTML upon a GET request" do
          get '/colors/bright-orange'
          expect(last_response).to be_ok
          expect(last_response.body)
            .to include('37ed608c-7c67-4a48-99ae-d351b576269d')
        end
      end

      describe "Markup language: Textile" do
        it "reads a Textile file and renders it as HTML upon a GET \
request" do
          get '/colors/dark-yellow'
          expect(last_response).to be_ok
          expect(last_response.body)
            .to include('46dbe50e-be4a-42b9-8796-50ddf302ead0')
        end
      end

      describe "Markup language: reStructuredText" do
        it "reads a reStructuredText file and renders it as HTML upon a \
GET request" do
          get '/colors/light-pink'
          expect(last_response).to be_ok
          expect(last_response.body)
            .to include('8c180fdb-6db8-404d-ba7c-0fe8487234a3')
        end
      end
    end


    describe "Return static files" do
      describe "Static file: PNG image" do
        it "returns a PNG image uppon a GET request" do
          get '/colors/image.png'
          expect(last_response).to be_ok
          expect(last_response.headers['Content-Type']).to eq('image/png')
        end
      end

      describe "Static file: HTML image" do
        it "returns a HTML image uppon a GET request" do
          get '/colors/cyan.html'
          expect(last_response).to be_ok
          expect(last_response.headers['Content-Type'])
            .to eq('text/html;charset=utf-8')
        end
      end

      describe "Static file: markup file" do
        it "returns a Markdown file uppon a GET request" do
          get '/colors/red.md'
          expect(last_response).to be_ok
        end

        it "returns an Org file uppon a GET request" do
          get '/colors/bright-orange.org'
          expect(last_response).to be_ok
        end

        it "returns a Textile file uppon a GET request" do
          get '/colors/dark-yellow.textile'
          expect(last_response).to be_ok
        end

        it "returns a reStructuredText file uppon a GET request" do
          get '/colors/light-pink.rst'
          expect(last_response).to be_ok
        end
      end

      describe "Static file: CSS file" do
        it "returns a CSS file uppon a GET request" do
          get '/patricia.css'
          expect(last_response).to be_ok
        end
      end

      describe "Static file: JavaScript file" do
        it "returns a JavaScript file uppon a GET request" do
          get '/patricia.js'
          expect(last_response).to be_ok
        end
      end
    end

    # Diverse

    describe "Page search" do
      it "returns a list of pages with the search query provided by a \
POST request" do
        post '/patricia/search', {:search_query =>
          'color', :case_sensitive => false}
        expect(last_response).to be_ok
      end

      it "displays links to all the pages found for the last search query \
upon a GET request" do
        get '/patricia/search'
        expect(last_response).to be_ok
      end
    end

    # Page Editing

    describe "Page Editing" do
      it "finds all matches for a sting in a page's markup and returns \
the markup together with the match offsets (POST)" do
        post '/patricia/offsets', {:markup_url =>
          'colors/red.md', :string => 'red'}
        expect(last_response).to be_ok
      end

      # it "updates the markup for a page with new markup (POST)" do
      #   new_markup = "# New markup\n\nThis is some *new* markup.\n"
      #   post '/patricia/edit', {:markup_url =>
      #     'colors/red.md', :string => new_markup}
      #   expect(last_response).to be_ok
      # end
    end

  end

  describe "Use custom CSS and JavaScript" do
    before(:each) do
      config = {
        :css_dir => File.join(File.dirname(__FILE__),
                              'assets/stylesheets/'),
        :js_dir => File.join(File.dirname(__FILE__),
                             'assets/javascripts/'),
        :tooltips => false,
        :editor => true,
        :ace => true,
        :ace_mode => 'markup',
        :ace_theme => 'solarized_dark',
        :ace_keybinding => 'emacs',
      }
      load_config(config)
    end

    describe "Static file: Custom CSS file" do
      it "returns a CSS file uppon a GET request" do
        get '/red.css'
        expect(last_response).to be_ok
        expect(last_response.body).to include('background-color')
        expect(last_response.body).to include('red')
      end
    end

    describe "Static file: Custom CSS file" do
      it "returns a CSS file uppon a GET request" do
        get '/green.css'
        expect(last_response).to be_ok
        expect(last_response.body).to include('background-color')
        expect(last_response.body).to include('green')
      end
    end

    describe "Static file: Custom JavaScript file" do
      it "returns a JavaScript file uppon a GET request" do
        get '/one.js'
        expect(last_response).to be_ok
        expect(last_response.body).to include('console.log')
        expect(last_response.body).to include('one')
      end
    end

    describe "Static file: Custom JavaScript file" do
      it "returns a JavaScript file uppon a GET request" do
        get '/two.js'
        expect(last_response).to be_ok
        expect(last_response.body).to include('console.log')
        expect(last_response.body).to include('two')
      end
    end
  end
end
