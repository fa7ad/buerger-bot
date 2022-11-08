# frozen_string_literal: true

require 'watir'

require_relative 'logger'
require_relative 'notify'

module BuergerBot
  BASE_URL = 'https://service.berlin.de/terminvereinbarung/termin/tag.php'

  PERM_PARAMS = '?termin=1&herkunft=1'

  DIENSTLEISTER = [
    122_210, 122_217, 122_219, 122_227, 122_231, 122_238, 122_243, 122_252, 122_260, 122_262, 122_254, 122_271, 122_273,
    122_277, 122_280, 122_282, 122_284, 122_291, 122_285, 122_286, 122_296, 150_230, 122_301, 122_297, 122_294, 122_312,
    122_314, 122_304, 122_311, 122_309, 317_869, 324_433, 325_341, 324_434, 324_435, 122_281, 324_414, 122_283, 122_279,
    122_276, 122_274, 122_267, 122_246, 122_251, 122_257, 122_208, 122_226
  ].freeze

  BLAUE_KARTE = 326_798

  # Robot is the main class of the Buerger::Bot gem.
  class Robot
    def initialize
      @name = "#{NAME} #{VERSION}"
    end

    def make_url(service = BLAUE_KARTE)
      init_params = PERM_PARAMS

      with_location_params = DIENSTLEISTER.reduce(init_params) do |query, dl|
        query + "&dienstleister[]=#{dl}"
      end

      BASE_URL + with_location_params + "&anliegen[]=#{service}"
    end

    def promt_user
      Notifications.notify 'Appointment found!', open_chrome: true
      Logger.log 'Press y to keep looking for appointments, any other key to exit'
      gets.chomp.downcase != 'y'
    end

    def found_appointment?(browser, service_url)
      browser.goto service_url
      link = browser.element css: '.calendar-month-table:first-child td.buchbar a'
      if link.exists?
        link.click
        promt_user
      end
      false
    rescue StandardError => e
      Logger.fail(e.inspect)
      false
    end

    def run
      Logger.log "Starting #{@name}..."
      browser = Watir::Browser.new :chrome
      # Logger.log "Enter Service ID or 0 for default (#{BLAUE_KARTE}):"
      # service = gets.chomp.to_i
      # service = BLAUE_KARTE if service.zero? || service.nil?
      service_url = make_url BLAUE_KARTE

      until found_appointment?(browser, service_url)
        Logger.log 'No appointment found, retrying in 25 seconds...'
        sleep 25
        Logger.log "#{'-' * 80}\nTrying again"
      end
    end
  end
end
