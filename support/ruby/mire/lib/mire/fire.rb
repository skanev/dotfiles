require 'listen'
require 'pathname'
require 'open3'

module Mire
  module Fire
    extend self

    def root
      Pathname('.').realpath
    end

    def run
      listener = Listen.to('.') do |modified, _added, _removed|
        # puts(modified:, added:, removed:)
        modified.each { file_changed _1 }
      end
      listener.start
      sleep
    end

    def file_changed(name)
      file = Pathname(name).relative_path_from(root)

      if file.to_s == 'lib/mire/fire.rb'
        puts '==== Restarting ===='
        exec 'bin/mire fire'
      end

      puts file

      case file.to_s
      when /^lib\/(.*)\.rb$/
        target_spec = "spec/#{$1}_spec.rb"
        if File.exist? target_spec
          puts "Run #{target_spec}"
          run_spec "rspec --force-color #{target_spec}"
        end
      when /^spec\/(.*)_spec\.rb$/
        target_spec = file.to_s
        run_spec "rspec --force-color #{target_spec}"
      end
    end

    def try_running
      run_spec 'rspec --force-color spec/mire/vim/palette_spec.rb'
    end

    def run_spec(command)
      event = nil

      beholder = Beholders::Rspec.build
      beholder.on_conclusion do |*args|
        event = args[1]
      end

      Open3.popen2e(command) do |input, output, wait_thr|
        beholder.feed_pipe(output) do |chunk|
          print chunk
        end
      end

      p event

      event
    end
  end
end
