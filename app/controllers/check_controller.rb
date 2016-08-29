class CheckController < ApplicationController

  def receives_data
    response = JSON.parse(request.body.string)

    body = response['body']
    tests = response['tests']

    unique_id = SecureRandom.hex(10)

    Dir.mkdir("/tmp/#{unique_id}")

    File.open("/tmp/#{unique_id}/code.rb", 'w') do |f|
      f.puts body
      f.puts tests
    end
    puts "*" * 10
    puts "*" * 10
    puts "*" * 10
    puts "*" * 10

    results = `docker run --rm -v /tmp/#{unique_id}:/opt/code ruby:2.3rspec rspec -f json /opt/code/code.rb`
    results = JSON.parse(results)
    p results['examples'][0]['description']
    raise
    results = results.split(/(?=[0-9]+\))/)
    results.shift # removes the FFFFF and Failures part
    p results.first
    filtered_answer = extractor(results)

    render json: filtered_answer
  end

  def extractor(results)
    answer = []
    results.each do |result|
      answer.push({
        expected: result.match(regex("expected"))[0],
        got: result.match(regex("got"))[0],
      })
    end

    answer
  end

  def regex(word)
    /(?<=#{word}:).+(?=(\\n)+)?/
  end

end
