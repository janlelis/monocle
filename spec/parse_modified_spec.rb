require_relative '../lib/rationalist'
require 'minitest/autorun'
require 'minitest/expectations'

describe 'parse modified' do
  it 'parse with modifier functions' do
    argv = Rationalist.parse([ '-b', '123' ], { boolean: 'b' })

    argv.must_equal({
      b: true,
      _: [123]
    })
  end
end