require 'opal'
require 'opal/rspec/version'

# Just register our opal code path with opal build tools
Opal.append_path File.expand_path('../../../opal', __FILE__)

# TODO: If this isn't performant, inline it
%w{rspec rspec-core rspec-expectations rspec-mocks rspec-support}.each do |gem|
  Opal.append_path File.expand_path("../../../#{gem}/lib", __FILE__)
end

Opal::Processor.dynamic_require_severity = :warning

Opal::Processor.stub_file "rspec/matchers/built_in/have"
Opal::Processor.stub_file "diff/lcs"
Opal::Processor.stub_file "diff/lcs/hunk"
Opal::Processor.stub_file "fileutils"
Opal::Processor.stub_file "test/unit/assertions"
Opal::Processor.stub_file "coderay"
Opal::Processor.stub_file "optparse"
Opal::Processor.stub_file "shellwords"
Opal::Processor.stub_file "socket"
Opal::Processor.stub_file "uri"
Opal::Processor.stub_file "drb/drb"
