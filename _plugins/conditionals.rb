# A simple or filter for liquid.
# Usage:
#  Can be used anywhere liquid syntax is parsed (templates, includes, posts/pages)
#  {{ page.content | or: "Funkey" }}
#
module Conditionals
    def or(input, text)
      if input.nil? or input.empty?
        text
      else
        input
      end 
    end
end # Conditionals

Liquid::Template.register_filter(Conditionals)
