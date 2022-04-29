module Mire
  module Tmux
    extend self

    SUCCESS = '#[bg=colour236,fg=colour82]'
    WAITING = '#[bg=colour236,fg=colour243]'
    FAILURE = '#[bg=colour124,fg=colour255]'

    def refresh_client
      tmux 'refresh-client -S'
    end

    def status_clear
      tmux 'set -u @info'
    end

    def status_success
      set_info "#{SUCCESS} ✔︎"
    end

    def status_failure(text)
      set_info "#{FAILURE} 💥 #{text}"
    end

    def status_working(style = WAITING)
      set_info "#{style} …"
    end

    def set_info(info)
      tmux "set @info '#{info}'"
    end

    private

    def tmux(command)
      system "tmux #{command}" or raise 'Failed shelling out'
    end
  end
end
