require_relative '../lib/rationalist'
require 'minitest/autorun'
require 'minitest/expectations'

describe 'bool' do
  it 'flag boolean default false' do
    argv = Rationalist.parse(['moo'], {
      boolean: ['t', 'verbose'],
      default: { verbose: false, t: false }
    })

    argv.must_equal({
      verbose: false,
      t: false,
      _: ['moo']
    })
  end

  it 'boolean groups' do
    argv = Rationalist.parse(['-x', '-z', 'one', 'two', 'three'], {
      boolean: ['x','y','z']
    })

    argv.must_equal({
      x: true,
      y: false,
      z: true,
      _: ['one', 'two', 'three']
    })
  end

  it 'boolean and alias with chainable api' do
    aliased = ['-h', 'derp']
    regular = ['--herp',  'derp']
    options = { herp: {alias: 'h', boolean: true} }
    aliased_argv = Rationalist.parse(aliased, {
      boolean: 'herp',
      alias: { h: 'herp' }
    })
    property_argv = Rationalist.parse(regular, {
      boolean: 'herp',
      alias: { h: 'herp' }
    })
    expected = {
      herp: true,
      h: true,
      _: ['derp']
    };

    aliased_argv.must_equal(expected);
    property_argv.must_equal(expected);
  end

  it 'boolean and alias with options hash' do
    aliased = ['-h', 'derp']
    regular = ['--herp', 'derp']
    options = {
      alias: { h: 'herp' },
      boolean: 'herp'
    }

    aliased_argv = Rationalist.parse(aliased, options)
    property_argv = Rationalist.parse(regular, options)
    expected = {
      herp: true,
      h: true,
      _: ['derp']
    }
    aliased_argv.must_equal(expected);
    property_argv.must_equal(expected);
  end

  it 'boolean and alias using explicit true' do
    aliased = ['-h', 'true']
    regular = ['--herp', 'true']
    options = {
      alias: { h: 'herp' },
      boolean: 'h'
    }

    aliased_argv = Rationalist.parse(aliased, options)
    property_argv = Rationalist.parse(regular, options)
    expected = {
      herp: true,
      h: true,
      _: []
    }
    aliased_argv.must_equal(expected);
    property_argv.must_equal(expected);
  end

  it 'boolean and --x=true' do
    parsed = Rationalist.parse(['--boool', '--other=true'], {
      boolean: 'boool'
    })
    parsed[:boool].must_equal true
    parsed[:other].must_equal 'true'

    parsed = Rationalist.parse(['--boool', '--other=false'], {
      boolean: 'boool'
    })

    parsed[:boool].must_equal true
    parsed[:other].must_equal 'false'
  end
end
