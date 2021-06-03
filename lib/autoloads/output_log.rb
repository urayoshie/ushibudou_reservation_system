class OutputLog
  class << self
    def error(**params)
      message = format(params)
      Rails.logger.error(message)
      SlackNotification.execute(message) if Rails.env.production?
    end

    def info
      message = format(params)
      Rails.logger.info(message)
    end

    private

    def format(params)
      message = ""
      params.each { |k, h| message << "#{k}: #{h}\n" }
      message
    end
  end
end
