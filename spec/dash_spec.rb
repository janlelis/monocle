require_relative '../lib/rationalist'
require 'minitest/autorun'
require 'minitest/expectations'

describe 'dash' do
  it '-' do
    Rationalist.parse(['-n', '-']).must_equal({ n: '-', _: [] })
    Rationalist.parse(['-']).must_equal({ _: ['-'] })
    Rationalist.parse(['-f-']).must_equal({ f: '-', _: [] })
    Rationalist.parse(['-b', '-'], boolean: 'b').must_equal({ b: true, _: ['-'] })
    Rationalist.parse(['-s', '-'], string: 's').must_equal({ s: '-', _: [] })
  end

  it '-a -- b' do
    Rationalist.parse(['-a', '--', 'b']).must_equal({ a: true, _: ['b'] })
    Rationalist.parse(['--a', '--', 'b']).must_equal({ a: true, _: ['b'] })
  end

  it 'move arguments after the -- into their own `--` array' do
    Rationalist.parse(['--name', 'John', 'before', '--', 'after'], { :'--' => true }).must_equal(
      { name: 'John', _: ['before'], :'--' => ['after'] }
    )
  end
end
