# A simple way to embed gists in liquid.
# Usage:
#  Can be used anywhere liquid syntax is parsed (templates, includes, posts/pages)
#  {# gist gistURL %}
#
module Gist
   class GistTag < Liquid::Tag
     def initialize(tag_name, gist, tokens)
       super
       @gist = gist
     end

     def render(context)
       "<script src=\"#{@gist}\"> </script>"
     end
   end
end 
Liquid::Template.register_tag("gist", Gist::GistTag)
