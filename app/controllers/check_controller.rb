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

    # Need to check if the ruby code has syntax errors.
      # * If it does, we skip rspec and return errors
      # * If it does not, then we can run rspec tests

    results = `docker run --rm -v /tmp/#{unique_id}:/opt/code ruby:2.3rspec rspec -f json /opt/code/code.rb`
    results = JSON.parse(results)

    filtered_answer = extractor(results)

    render json: filtered_answer
    # render json: results

  rescue => e
    p "Error caught"
    render json: { errors: "There was a syntax error in your code." }, status: 422
  end


  def extractor(results)
    answer = []
    results['examples'].each do |result|
      next if result['status'] == 'passed'

      message = result['exception']['message'].split("\n").delete_if(&:blank?).map(&:strip)
      answer.push({
        full_description: result['full_description'],
        status: result['status'],
        exception: {
          class: result['exception']['class'],
          message: {
            expected: message[0],
            got: message[1],
            compared: message[2]
          }
        },
      })
    end
    answer.unshift({
      summary_line: results['summary_line']
    })
    answer
  end
  # def extractor(results)
  #   answer = []
  #   results.each do |result|
  #     answer.push({
  #       expected: result.match(regex("expected"))[0],
  #       got: result.match(regex("got"))[0],
  #     })
  #   end
  #
  #   answer
  # end
  #
  # def regex(word)
  #   /(?<=#{word}:).+(?=(\\n)+)?/
  # end

end
