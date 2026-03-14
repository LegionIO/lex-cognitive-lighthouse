# frozen_string_literal: true

require 'securerandom'

require_relative 'cognitive_lighthouse/version'
require_relative 'cognitive_lighthouse/helpers/constants'
require_relative 'cognitive_lighthouse/helpers/beacon'
require_relative 'cognitive_lighthouse/helpers/fog'
require_relative 'cognitive_lighthouse/helpers/lighthouse_engine'
require_relative 'cognitive_lighthouse/runners/cognitive_lighthouse'
require_relative 'cognitive_lighthouse/client'

module Legion
  module Extensions
    module CognitiveLighthouse
      extend Legion::Extensions::Core if Legion::Extensions.const_defined? :Core
    end
  end
end
