require 'batch_actions'
require 'arbre'
require 'bootstrap-sass'
require 'haml'
require 'kaminari'
require 'ransack'

require_relative 'base/engine'
require_relative 'base/app_helpers'
require_relative 'base/module_helpers'
require_relative 'base/shim'

module SlashAdmin
  module AdminSets
    module Base
    end

    module ActiveAdmin
    end
  end

  module Shims
  end

  module ViewHelpers
  end
end