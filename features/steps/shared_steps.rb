Then(/^the output should eventually match:$/) do |string|
  eventual_success { assert_matching_output(string, output_from(@commands[-1])) }
end

Then(/^the exit status should eventually be (\d+)$/) do |exit_status|
  eventual_success { assert_exit_status(exit_status.to_i) }
end