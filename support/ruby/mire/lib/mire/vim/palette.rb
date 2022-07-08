module Mire
  module Vim
    module Palette
      extend self

      def extract_documented(text)
        text.scrub.scan(/^\s*":: (.*)\n\s*command!?\s+(?:-\S+\s+)*(\w+)/).map do |name, command|
          [:command, command, name]
        end
      end

      def all_in_dotfiles
        extract_documented `cd '#{Dotfiles.root_dir}' && (fd --glob '*.vim' | xargs cat)`
      end
    end
  end
end
