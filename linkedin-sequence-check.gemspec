Gem::Specification.new do |s|
  s.name = "linkedin-sequence-check"
  s.version = "1.0.0"
  s.summary = "Ruby CLI that checks a five-branch LinkedIn outreach sequence: missing branches, length, braces, links in the note, existing-connection open"
  s.description = "Ruby CLI that checks a five-branch LinkedIn outreach sequence: missing branches, length, braces, links in the note, existing-connection openers and hook labels."
  s.authors = ["Jainendra Ojha"]
  s.email = ["account@onegtmlab.dev"]
  s.license = "MIT"
  s.homepage = "https://www.onegtmlab.dev/growth-playbooks/linkedin-outreach"
  s.metadata = { "source_code_uri" => "https://github.com/jaizendra-netizen/linkedin-sequence-check" }
  s.required_ruby_version = ">= 2.7"
  s.files = Dir["lib/**/*.rb", "bin/*", "LICENSE", "README.md"]
  s.bindir = "bin"
  s.executables = ["linkedin-sequence-check"]
end
