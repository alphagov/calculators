require "rake/testtask"

Rake::TestTask.new("test:unit:calculators") do |t|
  t.libs << "test"
  t.test_files = Dir["test/unit/calculators/**/*_test.rb"]
end