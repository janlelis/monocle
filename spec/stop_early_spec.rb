require_relative '../lib/rationalist'
require 'minitest/autorun'
require 'minitest/expectations'

describe 'stop early' do
  it 'stops parsing on the first non-option when stopEarly is set' do
    argv = Rationalist.parse(
     ['--aaa', 'bbb', 'ccc', '--ddd'],
      stop_early: true,
    )

    argv.must_equal(
      aaa: 'bbb',
      _: ['ccc', '--ddd'],
    )
  end
end
