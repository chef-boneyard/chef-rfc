Steven, Paul, and myself were having a discussion about adding
an `on_failure` handler on a per-resource basis. I wrote up an RFC proposing
an API for this functionality.

Defining an +on_failure+ block will rescue any exceptions, execute the given
block, and then retry the resource action.

```ruby
meal 'breakfast' do
  on_failure { notify :eat, 'food[bacon]' }
end
```

The +on_failure+ block accepts an optional list of options, such as the number
of times to retry before bubbling the exception up the stack.

```ruby
meal 'breakfast' do
  on_failure(retries: 3) { notify :eat, 'food[bacon]' }
end
```

You can also specify an exception or list of exceptions to run the failure
block against. If the exception raised matches the given exception class (or
a subclass of that exception) the block is executed. Otherwise the exception
will bubble up.

```ruby
meal 'breakfast' do
  on_failure(UncookedError) { notify :fry, 'food[bacon]' }
end
```

It's possible to specify multiple exceptions to rescue in a given block.

```ruby
meal 'breakfast' do
  on_failure(UncookedError, HungryError) { notify :fry, 'food[bacon]' }
end
```

The +on_failure+ parameter is compilative, meaning declaring multiple
+on_failure+ blocks is permissive. Blocks are executed in the order in
which they are defined, from top-to-bottom. The pattern is useful if you
need different exception handling depending on the type of exception raised.

```ruby
meal 'breakfast' do
  on_failure(UncookedError) { notify :fry, 'food[bacon]' }
  on_failure(ColdError) { notify :microwave, 'food[bacon]' }
end
```

For more complex failure handling, you can specify a multi-step block. The
contents of the block are executed in the context of the containing recipe,
in the top-level run_context (so it can notify existing resources in the
top-level resource collection).

```ruby
meal 'breakfast' do
  on_failure do
    alarm '7:00am' do
      action :buzz
    end
  end
end
```

The block for +on_failure+ yields an optional reference to the parent
resource (+meal[breakfast]+ in this example). This is helpful if you need
information about the parent resource, such as the value of a parameter
in your failure handling.

```ruby
meal 'breakfast' do
  on_failure do |breakfast|
    alarm breakfast.start_time do
      action :buzz
    end
  end
end
```

And these different methodologies can be mixed-and-matched.

```ruby
meal 'breakfast' do
  on_failure(UncookedError) do
    oven 'main' do
      action :start
    end
  end
  on_failure(ThirstyError, retries: 3) do |breakfast|
    breakfast.minutes_until_served.each do
      juice 'orange' do
        action :drink
      end
    end
  end
end
```
