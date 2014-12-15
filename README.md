KerbalStuff API Wrapper for Ruby
==============

A simple Ruby API Wrapper for KerbalStuff


## Gem Status
[![Gem Version](https://badge.fury.io/rb/KerbalStuff.png)](http://badge.fury.io/rb/KerbalStuff)


## Install

You can install the gem like this:

    gem install kerbalstuff
  
    
## Updating

When a new update is released, you can update your gem like this:

    gem update kerbalstuff
    
    
## Examples

Here are some examples of how you can use the wrapper.

```ruby
require 'kerbalstuff' # Require the Gem
```

```ruby
ks = KerbalStuff # Initialize the wrapper

ks.search_mod("parts pack") # returns an array containing Mod objects.
ks.search_user("godarklight") # returns an array containing User objects.

ks.get_mod(4) # returns a Mod object containing the information about the mod.
ks.get_user("RockyTV") # returns a User object containing the information about the user.

ks.get_latest_mod_version(4) # returns a ModVersion object containing information about the version.

ks.browse( {:page => 1, :orderby => "name", :order => "asc", :count => 5} ) # returns an Array containing mod objects
ks.browse_recent( {:page => 1} ) # returns an Array containing mod objects
ks.browse_featured( {:page => 1} ) # returns an Array containing mod objects
ks.browse_top( {:page => 1} ) # returns an Array containing mod objects

```

## Documentation
For a *slightly* more detailed version of the gem's methods, take a look [here](http://rubydoc.info/gems/KerbalStuff/).


## License

licensed under MIT License Copyright (c) 2014 Alexandre Oliveira. See LICENSE for further details.


## Contributing

See [CONTRIBUTING](http://github.com/RockyTV/KerbalStuffGem/blob/master/CONTRIBUTING.md)
