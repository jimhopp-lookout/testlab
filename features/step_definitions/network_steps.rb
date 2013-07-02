When /^I get the networks status with "([^"]*)"$/ do |app_name|
  network_cmd(app_name, %W(status -n labnet))
end

def network_cmd(app_name, *args)
  testlab_cmd(app_name, [%(network), args].flatten)
end
