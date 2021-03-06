require "helper"

describe Thor::Command do
  def command(options = {})
    options.each do |key, value|
      options[key] = Thor::Option.parse(key, value)
    end

    @command ||= Thor::Command.new \
      name: :can_has,
      description: "I can has cheezburger",
      long_description: "I can has cheezburger\nLots and lots of it",
      usage: "can_has",
      options: options
  end

  def klass_mock namespace, arguments
    Class.new( Struct.new( :namespace, :_arguments ) ) {
      def arguments *args
        _arguments
      end
    }.new namespace, arguments
  end

  describe "#formatted_usage" do
    it "includes namespace within usage" do
      object = klass_mock("foo", [])
      expect(
        command(:bar => :required).formatted_usage(object)
      ).to eq("foo:can_has --bar=BAR")
    end

    it "includes subcommand name within subcommand usage" do
      object = klass_mock("main:foo", [])
      expect(
        command(:bar => :required).formatted_usage(object, false, true)
      ).to eq("foo can_has --bar=BAR")
    end

    it "removes default from namespace" do
      object = klass_mock("default:foo", [])
      expect(
        command(:bar => :required).formatted_usage(object)
      ).to eq(":foo:can_has --bar=BAR")
    end

    it "injects arguments into usage" do
      options = {:required => true, :type => :string}
      object = klass_mock("foo", [Thor::Argument.new(:bar, options)])

      expect( object.arguments command: 'blah' ).to have_attributes length: 1

      expect(
        command(:foo => :required).formatted_usage(object)
      ).to eq("foo:can_has BAR --foo=FOO")
    end
  end

  describe "#dynamic" do
    it "creates a dynamic command with the given name" do
      expect(Thor::DynamicCommand.new("command").name).to eq("command")
      expect(Thor::DynamicCommand.new("command").description).to eq("A dynamically-generated command")
      expect(Thor::DynamicCommand.new("command").usage).to eq("command")
      expect(Thor::DynamicCommand.new("command").options).to eq({})
    end

    it "does not invoke an existing method" do
      dub = double
      expect(dub.class).to receive(:handle_no_command_error).with("to_s")
      Thor::DynamicCommand.new("to_s").run(dub)
    end
  end

  describe "#dup" do
    it "dup options hash" do
      command = Thor::Command.new \
        name: "can_has",
        options: { :foo => true, :bar => :required }
      command.dup.options.delete(:foo)
      expect(command.options[:foo]).to be
    end
  end

  describe "#run" do
    it "runs a command by calling a method in the given instance" do
      dub = double
      expect(dub).to receive(:can_has) { |*args| args }
      expect(dub).to receive(:on_run_success) { |result, *rest| result }
      expect(command.run(dub, [1, 2, 3])).to eq([1, 2, 3])
    end

    it "raises an error if the method to be invoked is private" do
      klass = Class.new do
        def self.handle_no_command_error(name)
          name
        end
        
        def on_run_success result, *rest
          result
        end

        def can_has
          "fail"
        end
        private :can_has
      end

      expect(command.run(klass.new)).to eq("can_has")
    end
  end
end
