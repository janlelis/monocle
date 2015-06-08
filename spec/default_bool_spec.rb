require_relative '../lib/rationalist'
require 'minitest/autorun'
require 'minitest/expectations'

describe 'default bool' do
  it 'boolean default true' do
    argv = Rationalist.parse([], {
        boolean: 'sometrue',
        default: { sometrue: true }
    });
    argv[:sometrue].must_equal true
  end

  it 'boolean default false' do
    argv = Rationalist.parse([], {
        boolean: 'somefalse',
        default: { somefalse: false }
    });
    argv[:somefalse].must_equal false
  end

  it 'boolean default to nil' do
    argv = Rationalist.parse([], {
        boolean: 'maybe',
        default: { maybe: nil }
    });
    argv[:maybe].must_equal nil
    argv = Rationalist.parse(['--maybe'], {
        boolean: 'maybe',
        default: { maybe: nil }
    });
    argv[:maybe].must_equal true
  end
end

