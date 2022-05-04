module Mire
  module Dotfiles
    extend self

    def root_dir
      Pathname(__FILE__).dirname.join('../../../../..').to_s
    end
  end
end
