require_relative '../lib/rationalist'
require 'minitest/autorun'
require 'minitest/expectations'

describe 'unknown' do
  it 'boolean and alias is not unknown' do
    unknown = []
    unknown_block = ->(arg){
      unknown.push(arg)
      false
    }
    aliased = ['-h', 'true', '--derp', 'true']
    regular = ['--herp',  'true', '-d', 'true']
    opts = {
      alias: { h: 'herp' },
      boolean: 'h',
    }
    aliased_argv = Rationalist.parse(aliased, opts, &unknown_block)
    property_argv = Rationalist.parse(regular, opts, &unknown_block)

    unknown.must_equal(['--derp', '-d'])
  end

  it 'flag boolean true any double hyphen argument is not unknown' do
    unknown = []
    unknown_block = ->(arg){
      unknown.push(arg)
      false
    }

    argv = Rationalist.parse(['--honk', '--tacos=good', 'cow', '-p', '55'], {
      boolean: true,
    }, &unknown_block)

    unknown.must_equal(['--tacos=good', 'cow', '-p'])
    argv.must_equal({
      honk: true,
      _: []
    })
  end

  it 'string and alias is not unknown' do
    unknown = []
    unknown_block = ->(arg){
      unknown.push(arg)
      false
    }

    aliased = ['-h', 'hello', '--derp', 'goodbye']
    regular = ['--herp',  'hello', '-d', 'moon']
    opts = {
      alias: { h: 'herp' },
      string: 'h',
    }

    aliased_argv = Rationalist.parse(aliased, opts, &unknown_block)
    property_argv = Rationalist.parse(regular, opts, &unknown_block)

    unknown.must_equal(['--derp', '-d'])
  end

  it 'default and alias is not unknown' do
    unknown = []
    unknown_block = ->(arg){
      unknown.push(arg)
      false
    }

    aliased = ['-h', 'hello']
    regular = ['--herp',  'hello']
    opts = {
      default: { h: 'bar' },
      alias: { h: 'herp' },
    }
    aliased_argv = Rationalist.parse(aliased, opts, &unknown_block)
    property_argv = Rationalist.parse(regular, opts, &unknown_block)

    unknown.must_equal([])
    unknown_block.call(nil) # exercise fn for 100% coverage
  end

  it 'value following -- is not unknown' do
    unknown = []
    unknown_block = ->(arg){
      unknown.push(arg)
      false
    }

    aliased = ['--bad', '--', 'good', 'arg']
    opts = {
      :'--' => true,
    }
    argv = Rationalist.parse(aliased, opts, &unknown_block)

    unknown.must_equal(['--bad'])
    argv.must_equal({
      :'--' => ['good', 'arg'],
      :_ => [],
    })
  end
end
