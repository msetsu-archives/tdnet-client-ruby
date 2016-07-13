$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'tdnet'

require 'minitest/autorun'
require 'mocha/mini_test'


def test_resource(path)
  File.join (File.expand_path '../resource/', __FILE__), path
end
