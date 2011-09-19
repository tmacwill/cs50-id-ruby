Gem::Specification.new do |s|
    s.name = "cs50"
    s.version = "0.1.3"
    s.platform = Gem::Platform::RUBY
    s.authors = ["Tommy MacWilliam"]
    s.email = "macwilliamt@gmail.com"
    s.homepage = "https://docs.cs50.net/CS50_ID"
    s.summary = "Ruby library for CS50 ID"
    s.description = "Utility functions for authenticating users via Harvard's OpenID provider, CS50 ID (https://id.cs50.net/)"
    s.files = ["lib/cs50.rb"]
    s.add_dependency("ruby-openid")
end
