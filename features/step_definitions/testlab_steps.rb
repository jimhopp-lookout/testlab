When /^I get help for "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} help`)
end

When /^I get status with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} status`)
end

When /^I build the lab with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} build`)
end

When /^I up the lab with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} up`)
end

When /^I down the lab with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} down`)
end

When /^I destroy the lab with "([^"]*)"$/ do |app_name|
  @repo = File.expand_path(File.join(File.dirname(__FILE__), "..", "", "support"))
  @app_name = app_name
  step %(I run `#{app_name} --repo=#{@repo} destroy`)
end
