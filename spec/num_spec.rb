require_relative '../lib/rationalist'
require 'minitest/autorun'
require 'minitest/expectations'

describe 'num' do
  it 'nums' do
    argv = Rationalist.parse([
      '-x', '1234',
      '-y', '5.67',
      '-z', '1e7',
      '-w', '10f',
      '--hex', '0xdeadbeef',
      '789'
    ])
    argv.must_equal({
      x: 1234,
      y: 5.67,
      z: 1e7,
      w: '10f',
      hex: 0xdeadbeef,
      _: [789]
    })
  end

  it 'already a number' do
    argv = Rationalist.parse([ '-x', 1234, 789 ]);
    argv.must_equal({ x: 1234, _: [789] });
  end
end
