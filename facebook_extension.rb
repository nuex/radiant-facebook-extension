require 'rest-graph'
class FacebookExtension < Radiant::Extension
  version "0.1"
  description "Access Facebook OpenGraph data."
  url "http://github.com/nuex/radiant-facebook-extension.git"

  def activate
    Page.send :include, Facebook::Tags
  end
end
