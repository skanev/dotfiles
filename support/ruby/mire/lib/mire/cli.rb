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
        Mire::Stalker.stalk STDIN
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
          if event = Mire::Depot.instance.stalker_events.detect { _1['quickfix'] }
            puts "# stalker quickfix #{event['id']}"
            print event['quickfix']
          end
        end
      end

      c.desc 'Show the latest quickfix so it is consumable by Vim'
      c.command :quickfix do |sc|
        sc.action do
          if event = Mire::Depot.instance.stalker_events.detect { _1['quickfix'] }
            puts "# stalker quickfix #{event['id']}"
            print event['quickfix']
          end
        end
      end

      c.desc 'Show a specific failure in a quickfix to load a nested stacktrace in Vim'
      c.command :failure do |sc|
        sc.action do |_, _, args|
          id, index = *args
          if event = Mire::Depot.instance.stalker_events.detect { _1['quickfix'] && _1['id'] == id }
            puts event['failures'][index.to_i]
          end
        end
      end
    end
  end
end
