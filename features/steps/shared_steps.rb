Then(/^the output should eventually match:$/) do |string|
  eventual_success { assert_matching_output(string, output_from(@commands[-1])) }
end

Then(/^the exit status should eventually be (\d+)$/) do |exit_status|
  eventual_success { assert_exit_status(exit_status.to_i) }
end

When(/^I kubectl system services/) do 
  run_simple("kubectl --cluster=#{ENV['CUKE_CLUSTER']} get services --namespace=kube-system")
end

When(/^I kubectl services/) do 
  run_simple("kubectl --cluster=#{ENV['CUKE_CLUSTER']} get services")
end

When(/^I kubectl nodes/) do 
  run_simple("kubectl --cluster=#{ENV['CUKE_CLUSTER']} get nodes")
end