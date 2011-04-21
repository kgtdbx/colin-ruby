require 'rack/test'
require 'test/unit'
require File.join(File.dirname(__FILE__),'app.rb')

ENV['RACK_ENV']='test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end
  
  def test_people
    get '/people'
    p last_response.body
  end
end