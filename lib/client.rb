require 'rest_client'
require 'json'

class Client
  attr_reader :email, :subject, :text, :test_mode

  def initialize(attributes ={})
    @email     = attributes[:email].to_s.strip.split(",")
    @subject   = attributes[:subject]
    @text      = attributes[:text]
    @test_mode = attributes[:test_mode] || false
  end

  def send_email
    return ERROR_MSG if detect_supressions?
    return EMAIL_ERROR if email.empty?

    data = {
      from: 'Mailgun Sandbox <postmaster@sandbox3ec4bb7791344e6b93b3cc96e3009782.mailgun.org>',
      to: email,
      'o:campaign' => CAMPAIGN_ID,
      'o:testmode' => test_mode,
      subject: subject,
      text: text
    }

    RestClient.post(API_ENDPOINTS[:send_email], data)

  rescue => ex
    return ex
  end

  private

  #This is the campaign id for this domain, I have created
  #using create campaign api
  CAMPAIGN_ID = '110kvb'.freeze
  ERROR_MSG   = "Error: This email address is included in do not contact list".freeze
  EMAIL_ERROR = 'Error: Email can not be blank'.freeze
  API_KEY     = 'key-e30f5b8e86f6358e29044615021ab9d6'
  DOMAIN_NAME = 'sandbox3ec4bb7791344e6b93b3cc96e3009782.mailgun.org'

  API_ENDPOINTS = {
    send_email: "https://api:#{API_KEY}"\
    "@api.mailgun.net/v3/#{DOMAIN_NAME}/messages",

    get_unsubscribers: "https://api:#{API_KEY}"\
    "@api.mailgun.net/v3/#{DOMAIN_NAME}/unsubscribes"
  }

  def detect_supressions?
    response     = RestClient.get API_ENDPOINTS[:get_unsubscribers]
    unsubscribes = JSON.parse(response)['items'].map {|item| item['address'] }

    email.any? { |email| unsubscribes.include?(email) }
  end
end

# puts "Enter comma seperated email address"
# email = gets

# puts "Enter Subject"
# subject = gets

# puts "Enter Text"
# text = gets

# puts Client.new({ email: email, subject: subject, text: text }).send_email
