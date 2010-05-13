# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rnschrittmotor}
  s.version = "0.2"
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Sascha Teske"]
  s.date = %q{2010-05-13}
  s.description = %q{rnschrittmotor allows you to talk to the steppermotor controllerboard using ruby}
  s.email = %q{sascha.teske@microprojects.de}
  s.extra_rdoc_files = [
    "README.md",
    "gpl_v3.txt",
    "CHANGELOG"
  ]
  s.files = [
    "lib/rn_schrittmotor.rb",
    "Rakefile",
    "PostInstall.txt",
  ]
  s.homepage = %q{http://github.com/slaxor/rnschrittmotor}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{rnschrittmotor}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{Stepper-motor controller API}
  s.test_files = [
    "test/rn_schrittmotor_test.rb",
    "test/test_helper.rb",
  ]
end
