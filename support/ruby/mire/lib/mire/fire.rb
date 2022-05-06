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
        modified.each { file_changed _1 }
      end
      listener.start
      try_running
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

        run_spec target_spec if File.exist? target_spec
      when /^spec\/(.*)_spec\.rb$/
        run_spec file.to_s
      end
    end

    def try_running
      run_spec 'spec/mire/vim/palette_spec.rb'
    end

    def run_spec(spec_file)
      command = "rspec --force-color --format=documentation #{spec_file}"
      system 'clear'
      event = nil

      beholder = Beholders::Rspec.build
      beholder.on_conclusion do |type, data|
        case type.to_sym
        in :event then Depot.instance.store_stalker_event data
        in :fire then event = data
        end

        event = data
      end

      Open3.popen2e(command) do |_input, output, _wait_thr|
        beholder.feed_pipe(output) do |chunk|
          print chunk
        end
      end

      return unless event

      message = {
        type: :mire,
        file: Pathname(spec_file).realpath.to_s,
        failures: event[:failures],
      }

      pp message

      Depot.instance.publish(message.to_json)

      event
    end
  end
end
