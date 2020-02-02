# rationalist [![[version]](https://badge.fury.io/rb/rationalist.svg)](https://badge.fury.io/rb/rationalist)  [![[travis]](https://travis-ci.org/janlelis/rationalist.png)](https://travis-ci.org/janlelis/rationalist)

*With __rationalist__, the options are just a hash!*

Strongly influenced by substack's
[minimist](https://github.com/substack/minimist) nodejs module.

## setup

Add to your `Gemfile`:

```ruby
gem 'rationalist'
```

For more info, see the original README below, with all JS replaced with Ruby.

# minimist

parse argument options

This module is the guts of optimist's argument parser without all the
fanciful decoration.

# example

```ruby
require 'rationalist'
argv = Rationalist.parse(ARGV)
p argv
```

```
$ ruby example/parse.rb -a beep -b boop
{:_=>[], :a=>"beep", :b=>"boop"}
```

```
$ ruby example/parse.js -x 3 -y 4 -n5 -abc --beep=boop foo bar baz
{ :_=>["foo", "bar", "baz"],
  :x=>3,
  :y=>4,
  :n=>5,
  :a=>true,
  :b=>true,
  :c=>true,
  :beep=>"boop" }
```

# methods

```ruby
require 'rationalist'
```

## argv = Rationalist.parse(args = ARGV, **opts, &unknown_block)

Return an argument object `argv` populated with the array arguments from `args`.

`argv[:_]` contains all the arguments that didn't have an option associated with
them.

Numeric-looking arguments will be returned as numbers unless `opts[:string]` or
`opts[:boolean]` is set for that argument name.

Any arguments after `'--'` will not be parsed and will end up in `argv[:_]`.

options can be:

* `opts[:string]` - a string or array of strings argument names to always treat as
strings
* `opts[:boolean]` - a boolean, string or array of strings to always treat as
booleans. if `true` will treat all double hyphenated arguments without equal signs
as boolean (e.g. affects `--foo`, not `-f` or `--foo=bar`)
* `opts[:alias]` - an object mapping string names to strings or arrays of string
argument names to use as aliases
* `opts[:default]` - an object mapping string argument names to default values
* `opts[:stop_early]` - when true, populate `argv[:_]` with everything after the
first non-option
* `opts[:'--']` - when true, populate `argv._` with everything before the `--`
and `argv[:'--']` with everything after the `--`. Here's an example:
* `&unknown_block` - a block which is invoked with a command line parameter not
defined in the `opts` configuration object. If the function returns `false`, the
unknown option is not added to `argv`.

```ruby
>> Rationalist.parse('one two three -- four five --six'.split(' '), { '--': true })
{ :_=>["one", "two", "three"],
  :"--"=>["four", "five", "--six"] }
```

Note that with `opts[:'--']` set, parsing for arguments still stops after the
`--`.

# install

With [rubygems](https://rubygems.org) do:

```
gem install rationalist
```

# license

MIT

**rationalist** was written by Jan Lelis and [minimist](https://github.com/substack/minimist) was written by James Halliday.
