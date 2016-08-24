# require 'securerandom'

class CheckController < ApplicationController

  def receives_data
    response = JSON.parse(request.raw_post)
    body = response['body']
    tests = response['tests']

    unique_id = SecureRandom.hex(10)

    Dir.mkdir("/tmp/#{unique_id}")

    File.open("/tmp/#{unique_id}/code.rb", 'w') do |f|
      f.puts body
      f.puts tests
    end
    # results = `docker run --rm -v /tmp/#{unique_id}:/opt/code ruby:2.3 rspec /opt/code/code.rb`
    results = `docker run --rm -v /tmp/#{unique_id}:/opt/code ruby:2.3 which rspec`
    # results = `docker run --rm -v /tmp/#{unique_id}:/opt/code ruby:2.3 rspec /opt/code/code.rb`
    p results



    render json: "success"
    # it just needs to render the errors
    # and if there are none return 200 or something
  end
end
