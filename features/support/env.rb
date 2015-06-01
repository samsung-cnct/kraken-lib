require 'aruba/cucumber'

Before do
  @aruba_timeout_seconds = 300
end

module AsyncSupport
  def timeout
    300
  end

  def polling_interval
    1
  end

  def eventual_success
    time_limit = Time.now + timeout
    begin 
      yield
    rescue Exception => error
      puts "Retrying #{@commands[-1]} after #{polling_interval} seconds..."
      raise error if Time.now >= time_limit
      sleep polling_interval 
      run_simple(@commands[-1])
      retry
    end    
  end
end
World(AsyncSupport)