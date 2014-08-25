SimpleWorker
============

Distribute automation scripts on multiple machines.

Usage
=====

Create `simpleworker.yml` in the projects working directory.  Ruby must be
setup on the remote host such that it is available in the login shell.

```yml
---
workers:
  - type: ssh                      # type of worker
    directory: /tmp/foobar         # directory on remote host
    user: bill                     # user on remote host
    host: my.remote.host.com       # remote host name
```

```ruby
require 'simpleworker'

# execute with workers configured in $PWD/simpleworker.yml
SimpleWorker::Runnner.run "my-command"

# execute with a special worker configuration
SimpleWorker::Runner.load("my-worker-config.yml").run "my-command"
```

Examples
========

[Distribute cucumber scenarios](http://jesg.github.io/testing/2014/08/23/distributed-cucumber.html)

Note on Patches/Pull Requests
=============================

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

