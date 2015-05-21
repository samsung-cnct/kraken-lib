require 'aruba/cucumber'

Before do
  @aruba_timeout_seconds = 300
end

module AsyncSupport
  def eventual_output
    timeout = 300
    polling_interval = 1
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