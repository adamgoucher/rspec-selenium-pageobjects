RSpec::Matchers.define :have_errors do |expected|
  match do |actual|
    !actual.empty?
  end
  
  failure_message_for_should_not do |actual|
    actual.join("\n")
  end
end