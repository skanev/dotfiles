require 'gli'

module Mire
  class CLI
    extend GLI::App

    def self.start
      exit run(ARGV)
    end

    program_desc 'Duct tape for personal use'

    desc 'Listen to stdin with stalker'
    command :stalk do |c|
      c.action do
        Mire::Stalker.stalk $stdin
      end
    end

    desc 'Runs FIRE continuously'
    command :fire do |c|
      c.action do
        require 'mire/fire'
        Mire::Fire.run
      end
    end

    desc 'Utilities for interacting with stalker'
    command :stalker do |c|
      c.desc 'Dump all the stalker events'
      c.command :dump do |sc|
        sc.action do
          require 'ap'
          ap Mire::Depot.instance.stalker_events
        end
      end

      c.desc 'Show the latest quickfix so it is consumable by Vim'
      c.command :quickfix do |sc|
        sc.action do
          if (event = Mire::Depot.instance.stalker_events.detect { _1['quickfix'] })
            puts "# stalker quickfix #{event['id']}"
            print event['quickfix']
          end
        end
      end

      c.desc 'Show the latest quickfix so it is consumable by Vim'
      c.command :quickfix do |sc|
        sc.desc 'The id of the quickfix event to show'
        sc.flag :id
        sc.action do |_, options|
          event =
            if options[:id]
              Mire::Depot.instance.stalker_events.detect { _1['id'] == options[:id] }
            else
              Mire::Depot.instance.stalker_events.detect { _1['quickfix'] }
            end

          if event
            puts "# stalker quickfix #{event['id']}"
            print event['quickfix']
          end
        end
      end

      c.desc 'Show a specific failure in a quickfix to load a nested stacktrace in Vim'
      c.command :failure do |sc|
        sc.action do |_, _, args|
          id, index = *args
          if (event = Mire::Depot.instance.stalker_events.detect { _1['quickfix'] && _1['id'] == id })
            puts event['failures'][index.to_i]
          end
        end
      end

      c.desc 'Shows the summary of all the events'
      c.command :events do |sc|
        sc.action do
          require 'time'
          relevant = Mire::Depot.instance.stalker_events.map do |event|
            time = event['timestamp']&.then { Time.parse(_1) }
            is_today = time && Time.now.strftime('%Y-%m-%d') == time.strftime('%Y-%m-%d')
            short_time = is_today ? time&.strftime('Today %H:%M') : time&.strftime('%Y-%m-%d %H:%m')
            {
              title: event['title'],
              id: event['id'],
              short_time:,
              beholder: event['beholder'],
              status: event['status'],
            }
          end
          puts relevant.to_json
        end
      end
    end

    desc 'Helpers for vim'
    command :vim do |c|
      c.desc 'Show all documented palette entities'
      c.command 'palette:documented' do |sc|
        sc.action do
          puts Vim::Palette.all_in_dotfiles.to_json
        end
      end
    end
  end
end
