# A simple way to make page extempts in liquid.
# Usage:
#  Can be used anywhere liquid syntax is parsed (templates, includes, posts/pages)
#  {{ "folder" | gallery }}
#
module Images
  class SliderTag < Liquid::Tag
    def initialize(tag_name, folder, tokens)
      super
      @folder = folder.strip
    end

    def render(context)
      output="<div class=\"slider\">\n<ul class=\"inner\">\n"
      Dir.glob("images/#{@folder}/*").sort.each do |img|
        basename= File.basename(img)
        output += "<li class=\"item\"><img src=\"/#{img}\" alt=\"#{basename}\" /></li>\n"
      end

      output += "</ul>\n</div>\n"
    end
  end
end # Gallery

Liquid::Template.register_tag("slider", Images::SliderTag)
