require 'helper'
require_relative '../bash_comp_spec_helpers'

require_relative '../fixtures/bash_complete_fixtures'

describe_spec_file(
  spec_path:        __FILE__,
  module:           Thor::Completion::Bash::CommandMixin,
  class:            BashCompleteFixtures::Main,
  method:           :bash_complete,
) do

  include BashCompSpecHelpers

  describe_setup "process `request` and sort results" do

    let( :request ) { build_request *words }

    subject { super().call( request: request, index: 1 ).sort }

    use_case "complete :boolean options" do

      _when words: [ basename, 'dashed-main-cmd', '--bool' ] do
        it "compeltes to `--bool-opt`" do
          is_expected.to eq ['--bool-opt']
        end
      end # WHEN

      _when words: [ basename, 'dashed-main-cmd', '--no-b' ] do
        it "compeltes to `--no-bool-opt`" do
          is_expected.to eq ['--no-bool-opt']
        end
      end # WHEN

    end # CASE complete :boolean options


    use_case "complete :string options" do

      _when words: [ basename, 'dashed-main-cmd', '--str' ] do
        it "compeltes to `--str-opt=`" do
          is_expected.to eq ['--str-opt=']
        end
      end # WHEN

    end # CASE complete :string options


    use_case "list options" do

      _when words: [ basename, 'dashed-main-cmd', '--' ] do
        it "Lists all `--` options" do
          is_expected.to eq [
            '--bool-opt',
            '--no-bool-opt',
            '--str-opt=',
            '--help',
          ].sort
        end
      end # WHEN

    end # CASE complete :string options

  end # SETUP "sorted results when passed `request`"
end # Spec File Description