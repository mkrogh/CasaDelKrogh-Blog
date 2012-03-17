# A simple way to make page extempts in liquid.
# Usage:
#  Can be used anywhere liquid syntax is parsed (templates, includes, posts/pages)
#  {{ page.content | debug }}
#
module PageFold
    def page_fold(input, url, text="Read more")
      more = "<!--more-->"
      if input.include? more
        input.split(more).first + "<p><a href=\"#{url}\">#{text}</a></p>"
      else
        input
      end 
    end
end # PageFold

Liquid::Template.register_filter(PageFold)
