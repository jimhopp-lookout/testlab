# Monkey Patch the String class so we can have some easy ANSI methods
class String
  include ZTK::ANSI
end
