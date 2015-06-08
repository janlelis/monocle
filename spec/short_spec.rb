require_relative '../lib/rationalist'
require 'minitest/autorun'
require 'minitest/expectations'

describe 'short' do
  it 'numeric' do
    Rationalist.parse(['-n123']).must_equal({ n: 123, _: [] })
    Rationalist.parse(['-123', '456']).must_equal({ 1 => true, 2 => true, 3 => 456, _: [] })
  end

  it 'boolean' do
    Rationalist.parse(['-b']).must_equal({ b: true, _: [] })
  end

  it 'bare' do
    Rationalist.parse(['foo', 'bar', 'baz']).must_equal({ _: ['foo', 'bar', 'baz'] })
  end

  it 'group' do
    Rationalist.parse(['-cats']).must_equal({ c: true, a: true, t: true, s: true, _: [] })
  end

  it 'group next' do
    Rationalist.parse(['-cats', 'meow']).must_equal({ c: true, a: true, t: true, s: 'meow', _: [] })
  end

  it 'short capture' do
    Rationalist.parse(['-h', 'localhost']).must_equal({ h: 'localhost', _: [] })
  end

  it 'short captures' do
    Rationalist.parse(['-h', 'localhost', '-p', '555']).must_equal({ h: 'localhost', p: 555, _: [] })
  end

  it 'mixed short bool and capture' do
    Rationalist.parse(['-h', 'localhost', '-fp', '555', 'script.js']).must_equal({
      f: true, p: 555, h: 'localhost',
      _: ['script.js'],
    })
  end

  it 'short and long' do
    Rationalist.parse(['-h', 'localhost', '-fp', '555', 'script.js']).must_equal({
      f: true, p: 555, h: 'localhost',
      _: ['script.js'],
    })
  end
end
