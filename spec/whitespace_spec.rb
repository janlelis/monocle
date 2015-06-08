require_relative '../lib/rationalist'
require 'minitest/autorun'
require 'minitest/expectations'

describe 'whitespace' do
  it 'whitespace should be whitespace' do
    Rationalist.parse([ '-x', "\t" ])[:x].must_equal "\t"
  end
end