require_relative 'voice/contents'
require_relative 'voice/parser'
require_relative 'voice/rss'

module Dlsite
  module Voice
    def make_current_contents
      latest_contents   = Dlsite::Voice::Parser.parse
      previous_contents = Dlsite::Voice::Contents.previous_contents

      latest_contents.merge(previous_contents).last(30)
    end

    module_function :make_current_contents
  end
end
