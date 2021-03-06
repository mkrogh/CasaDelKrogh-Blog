module Jekyll
  require "sass"
  class SassConverter < Converter
    safe true
    priority :low

    def matches(ext)
      ext =~ /sass/i
    end

    def output_ext(ext)
      ".css"
    end

    def convert(content)
      begin
        puts "Compiling css from sass file"
        engine = Sass::Engine.new(content, :syntax => :sass, :load_paths => ["./assets/themes/CasaDelKrogh/css/"])
        engine.render
      rescue StandardError => e
        puts "!!! SASS Error: " + e.message
      end
    end
  end
end
