require_relative '../lib/rationalist'
require 'minitest/autorun'
require 'minitest/expectations'

describe 'dotted' do
  it 'dotted alias' do
    argv = Rationalist.parse(['--a.b', '22'], { default: { :'a.b' => 11 }, alias: { :'a.b' => 'aa.bb' } });
    argv[:a][:b].must_equal(22)
    argv[:aa][:bb].must_equal(22)
  end

  it 'dotted default' do
    argv = Rationalist.parse('', { default: { :'a.b' => 11 }, alias: { :'a.b' => 'aa.bb' } });
    argv[:a][:b].must_equal(11)
    argv[:aa][:bb].must_equal(11)
  end

  it 'dotted default with no alias' do
    argv = Rationalist.parse('', { default: { :'a.b' => 11 } });
    argv[:a][:b].must_equal(11)
  end
end

