# frozen_string_literal: true

require 'terminal-notifier'

require_relative 'version'

module BuergerBot
  # Notification utility for the bot.
  module Notifications
    def self.notify(message, open_chrome: false)
      TerminalNotifier.notify(
        message,
        title: "#{NAME} #{VERSION}",
        activate: open_chrome ? 'com.google.Chrome' : nil
      )
    end
  end
end
