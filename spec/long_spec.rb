require_relative '../lib/rationalist'
require 'minitest/autorun'
require 'minitest/expectations'

describe 'long' do
  it 'long boolean' do
    Rationalist.parse([ '--bool' ]).must_equal({ bool: true, _: [] })
  end

  it 'long capture sp' do
    Rationalist.parse([ '--pow', 'xixxle' ]).must_equal({ pow: 'xixxle', _: [] })
  end

  it 'long capture eq' do
    Rationalist.parse([ '--pow=xixxle' ]).must_equal({ pow: 'xixxle', _: [] })
  end

  it 'long captures sp' do
    Rationalist.parse([ '--host', 'localhost', '--port', '555' ]).must_equal({ host: 'localhost', port: 555, _: [] })
  end

  it 'long captures eq' do
    Rationalist.parse([ '--host=localhost', '--port=555' ]).must_equal({ host: 'localhost', port: 555, _: [] })
  end
end
