# frozen_string_literal: true

module BuergerBot
  # Logging utility for the bot.
  module Logger
    def self.log(message)
      puts "  #{message}"
    end

    def self.success(message)
      puts "+ #{message}"
    end

    def self.fail(message)
      puts "- #{message}"
    end
  end
end
