# encoding: utf-8

module Github
  # Request arguments handler
  class Arguments

    include Normalizer
    include Validations

    # Arguments used to construct request path
    #
    attr_reader :arguments

    # Parameters passed to request
    attr_reader :params

    # The request api
    #
    attr_reader :api

    # Required arguments
    #
    attr_reader :args_required
    private :args_required

    # Takes api, filters and required arguments
    #
    def initialize(api, options={})
      @api = api
      normalize! options
      @args_required = options.fetch('args_required', []).map(&:to_s)
    end

    # Parse arguments to allow for flexible api calls.
    # Arguments can be part of parameters hash or be simple string arguments.
    #
    def parse(*args)
      options = args.extract_options!
      normalize! options

      if args.any?
        parse_arguments *args
      else
        # Arguments are inside the parameters hash
        parse_options options
      end
      @params = options
      self
    end

    private

    def parse_arguments(*args)
      assert_presence_of *args
      args.each_with_index do |arg, indx|
        api.set args_required[indx], arg
      end
      check_requirement!(*args)
    end

    def parse_options(options)
      options.each do |key, val|
        key = key.to_s
        if args_required.include? key
          assert_presence_of val
          options.delete key
          api.set key, val
        end
      end
    end

    # Check if required arguments are present
    #
    def check_requirement!(*args)
      args_length          = args.length
      args_required_length = args_required.length

      if args_length < args_required_length
        ::Kernel.raise ArgumentError, "wrong number of arguments (#{args_length} for #{args_required_length})"
      end
    end

  end # Arguments
end # Github