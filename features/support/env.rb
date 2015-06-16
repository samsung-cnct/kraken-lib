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
      raise error if Time.now >= time_limit
      retry_last_command(time_limit)     
      retry
    end    
  end

  def retry_last_command(time_limit)
    begin
      puts "Retrying #{@commands[-1]} after #{polling_interval} seconds..."
      sleep polling_interval
      run_simple(@commands[-1])
    rescue Exception => error
      raise error if Time.now >= time_limit
      retry
    end
  end
end
World(AsyncSupport)