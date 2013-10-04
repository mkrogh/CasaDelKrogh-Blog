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

  class ImageTag < Liquid::Tag
    def initialize(tag_name, image, tokens)
      super
      @image = File.join("images", image.strip);
      @classes = [];
    end

    def css_classes
      if not @classes.empty?
        "class=\"#{@classes.join(" ")}\" "
      end
    end

    def render(context)
      "<img src=\"/#{@image}\" #{css_classes}alt=\"#{File.basename(@image)}\" />"
    end
  end

  class RightImageTag < ImageTag
    def initialize(tag_name, image, tokens)
      super
      @classes.push("right")
    end
  end

  class CenterImageTag < ImageTag
    def initialize(tag_name, image, tokens)
      super
      @classes.push("center")
    end
  end
end # Gallery

##USAGE: 
# {% slider vim-themes/sh %}
Liquid::Template.register_tag("slider", Images::SliderTag)

Liquid::Template.register_tag("image", Images::ImageTag)
Liquid::Template.register_tag("image_right", Images::RightImageTag)
Liquid::Template.register_tag("image_center", Images::CenterImageTag)
