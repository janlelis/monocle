require_relative '../lib/rationalist'
require 'minitest/autorun'
require 'minitest/expectations'

describe 'all bools' do
  it 'flag boolean true (default all --args to boolean)' do
    argv = Rationalist.parse(['moo', '--honk', 'cow'], {
      boolean: true
    })

    argv.must_equal({
      honk: true,
      _: ['moo', 'cow']
    })
  end
end