require_relative '../lib/rationalist'
require 'minitest/autorun'
require 'minitest/expectations'

describe 'Rationalist.parse' do
  it 'parses no' do
    Rationalist.parse(['--no-moo']).must_equal({ moo: false, _: [] })
  end

  it 'parses multiple times the same option' do
    Rationalist.parse(['-v', 'a', '-v', 'b', '-v', 'c']).must_equal({ v: ['a','b','c'], _: [] })
  end

  it 'comprehensive' do
    Rationalist.parse([
      '--name=meowmers', 'bare', '-cats', 'woo',
      '-h', 'awesome', '--multi=quux',
      '--key', 'value',
      '-b', '--bool', '--no-meep', '--multi=baz',
      '--', '--not-a-flag', 'eek'
    ]).must_equal({
      c: true,
      a: true,
      t: true,
      s: 'woo',
      h: 'awesome',
      b: true,
      bool: true,
      key: 'value',
      multi: ['quux', 'baz'],
      meep: false,
      name: 'meowmers',
      _: ['bare', '--not-a-flag', 'eek']
    })
  end

  it 'flag boolean' do
    Rationalist.parse(['-t', 'moo'], { boolean: 't' }).must_equal({ t: true, _: ['moo'] })
  end

  it 'flag boolean value' do
    Rationalist.parse(['--verbose', 'false', 'moo', '-t', 'true'], {
      boolean: ['t', 'verbose'],
      default: { verbose: true }
    }).must_equal({
      verbose: false,
      t: true,
      _: ['moo'],
    })
  end

  it 'newlines in params'  do
    Rationalist.parse(['-s', "X\nX"]).must_equal({ _: [], s: "X\nX" })

    # reproduce in bash:
    # VALUE="new
    # line"
    # node program.js --s="$VALUE"
    Rationalist.parse(["--s=X\nX"]).must_equal({ _: [], s: "X\nX" })
  end

  it 'strings'  do
    Rationalist.parse(['-s', '0001234'], { string: 's' })[:s].must_equal('0001234')
    Rationalist.parse(['-x', '56'], { string: 'x' })[:x].must_equal('56')
  end

  it 'stringArgs' do
    Rationalist.parse(['  ', '  '], { string: '_' })[:_].must_equal(
      ['  ', '  ']
    )
  end

  it 'empty strings' do
    Rationalist.parse(['-s'], { string: 's' })[:s].must_equal('')
    Rationalist.parse(['--str'], { string: 'str' })[:str].must_equal('')

    letters = Rationalist.parse(['-art'], {
      string: ['a', 't']
    })
    letters[:a].must_equal('')
    letters[:r].must_equal(true)
    letters[:t].must_equal('')
  end

  it 'string and alias' do
    x = Rationalist.parse(['--str',  '000123'], {
      string: 's',
      alias: { s: 'str' }
    })

    x[:str].must_equal('000123')
    x[:s].must_equal('000123')

    y = Rationalist.parse(['-s',  '000123'], {
      string: 'str',
      alias: { str: 's' }
    })

    y[:str].must_equal('000123')
    y[:s].must_equal('000123')
  end

  it 'slashBreak' do
    Rationalist.parse(['-I/foo/bar/baz']).must_equal({ I: '/foo/bar/baz', _: [] })
    Rationalist.parse(['-xyz/foo/bar/baz']).must_equal(
      { x: true, y: true, z: '/foo/bar/baz', _: [] }
    )
  end

  it 'alias' do
    argv = Rationalist.parse(['-f', '11', '--zoom', '55'], {
      alias: { z: 'zoom' }
    })

    argv[:zoom].must_equal(55)
    argv[:z].must_equal(argv[:zoom])
    argv[:f].must_equal(11)
  end

  it 'multiAlias' do
    argv = Rationalist.parse(['-f', '11', '--zoom', '55'], {
      alias: { z: ['zm', 'zoom'] }
    })

    argv[:zoom].must_equal(55)
    argv[:z].must_equal(argv[:zoom])
    argv[:z].must_equal(argv[:zm])
    argv[:f].must_equal(11)
  end

  it 'nested dotted objects' do
    argv = Rationalist.parse([
      '--foo.bar', '3', '--foo.baz', '4',
      '--foo.quux.quibble', '5', '--foo.quux.o_O',
      '--beep.boop'
    ])

    argv[:foo].must_equal({
      bar: 3,
      baz: 4,
      quux: {
        quibble: 5,
        o_O: true
      },
    })
    argv[:beep].must_equal({ boop: true })
  end
end
