require 'listen'
require 'pathname'
require 'open3'
require 'simplecov'

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
      dumper = root.join('scripts/simplecov_dumper.rb')
      command = "rspec -r \"#{dumper}\" --force-color --format=documentation #{spec_file}"
      system 'clear'
      event = nil

      bus = EventBus.new
      bus.listen(
        stalker: -> (data) { Depot.instance.store_stalker_event data },
        fire: -> (data) { event = data },
      )
      beholder = Beholders::Rspec.new bus

      key = "fire:simplecov:#{Time.now.to_f}"
      env = {
        'MIRE_FIRE_REDIS_KEY' => "mire:#{key}",
        'MIRE_FIRE_REDIS_CHANNEL' => '7',
      }

      Open3.popen2e(env, command) do |_input, output, _wait_thr|
        beholder.feed_pipe(output) do |chunk|
          print chunk
        end
      end

      coverage =
        if (data = Depot.instance.redis.get(key))
          simplecov_json Marshal.load(data)
        else
          []
        end

      return unless event

      message = {
        type: :mire,
        file: Pathname(spec_file).realpath.to_s,
        failures: event[:failures],
        simplecov: coverage,
      }

      Depot.instance.publish(message.to_json)

      event
    end

    private

    def simplecov_json(result)
      data = []

      result.files.map do |file|
        element = {}
        element[:name] = file.filename
        element[:lines] = []

        file.lines.each do |line|
          element[:lines] << [line.coverage, line.src.chomp]
        end

        data << element
      end

      data
    end
  end
end
