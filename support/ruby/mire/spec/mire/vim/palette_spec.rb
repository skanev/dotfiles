require 'spec_helper'

module Mire
  module Vim
    describe Palette do
      it 'can extract command documentation' do
        text = <<~END
          ":: A regular command
          command Regular call something()

          ":: A regular command with bang
          command! RegularBang call something()

          ":: Command with arguments
          command -nargs=1 Arguments call something()

          ":: Command with arguments and a bang
          command! -nargs=1 ArgumentsBang call something()

          ":: Complex command
          command  -bang   -nargs=?   -complete=dir   Complex     call something()

          ":: Complex command with a bang
          command! -bang   -nargs=?   -complete=dir   ComplexBang call something()

            ":: An indented command
            command Indented call something()

          command Undocumented call something()
        END

        expected = [
          [:command, 'Regular', 'A regular command'],
          [:command, 'RegularBang', 'A regular command with bang'],
          [:command, 'Arguments', 'Command with arguments'],
          [:command, 'ArgumentsBang', 'Command with arguments and a bang'],
          [:command, 'Complex', 'Complex command'],
          [:command, 'ComplexBang', 'Complex command with a bang'],
          [:command, 'Indented', 'An indented command'],
        ]

        actual = Palette.extract_documented text

        actual.should eq expected
      end
    end
  end
end
