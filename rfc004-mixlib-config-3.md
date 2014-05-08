# mixlib-config 3.0

I'd like to add some more user-focused features in mixlib-config 3.0, allowing
more flexibility in defining the actual file.

Features:
- group do ... end
- merge
- set
- matching
- set_matching
- sub configs (key.key.key.rb) for groups
- yamls, inis for groups?

## config do blocks

Right now, to set multiple parameters in a ConfigContext, you need to do:

```
server.port 4000
server.host '127.0.0.1'
```

In this proposal, you could do it with a block:

```
server do
  port 4000
  host '127.0.0.1'
end
```

## arbitrary-key config contexts

There are some sorts of config context which contain arbitrary keys, each of which is a config context itself.  For example one might like to be able to do this:

```
ssh_hosts do
  spanky do
    host '192.168.0.1'
    key_file '/home/jkeiser/spanky.pem'
  end
  google do
    host '192.168.0.1'
    key_file '/home/jkeiser/spanky.pem'
  end
end
```

To define the config context for values, the new command `default_config_context` can be invoked:

```
class MyConfig < Mixlib::Config
  config_context :ssh_hosts do
    default_config_context do
      config_strict_mode true
      default :host, '127.0.0.1'
      default :port, 22
      configurable :key_file
    end
  end
end
```

## configure

Not all keys are encodeable as ruby method calls. To accomodate non-simple keys, we propose a `configure` syntax:

```
ssh_hosts do
  configure 'blarghle.com' do
    port 1956
  end
end
```

## matching groups

It is sometimes useful to allow keys that match on values. We suggest allowing "configure_matching [<glob>|<regular expression>]" to let the user do this.

```
ssh_hosts do
  configure_matching '*.com' do
    port 1900
  end
  configure 'yahoo.com' do
    port 1901
  end
end

config.ssh_hosts['foo.com'].port == 1900
config.ssh_hosts['yahoo.com'].port == 1901

