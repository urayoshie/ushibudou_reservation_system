class SlackNotification
  def self.execute(text)
    uri = URI.parse("https://slack.com/api/chat.postMessage")
    post_params = {
      token: Rails.application.credentials.dig(:slack, :token),
      channel: Rails.application.credentials.dig(:slack, :channel),
      text: text,
    }

    response = Net::HTTP.post_form(uri, post_params)
    # send_email(text, response.code) and return unless response.code == "200"
    # body = JSON.parse response.body
    # send_email(text, body["error"]) unless body["ok"]
  end
end
