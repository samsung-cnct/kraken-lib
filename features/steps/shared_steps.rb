Then(/^the output should eventually match:$/) do |string|
  eventual_output { assert_matching_output(string, output_from(@commands[-1])) }
end

Then(/^the exit status should eventually be (\d+)$/) do |arg1|
  eventual_exit_code { assert_exit_status(arg1) }
end