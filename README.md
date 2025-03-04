
# stagnum

A stupid Ruby worker pool based on `Thread` and `Thread::Queue`.

```ruby
pool = Stagnum::Pool.new('pool-zero', 4)
  #
  # 4 worker threads to service the enqueued jobs

q = Stagnum::DoneQueue.new
  #
  # a queue shared by a group of jobs to enqueue

30.times do |i|

  pool.enqueue(q, { i: i }) do |d|

    sleep rand * 1

    d[:tname] = Thread.current.name
  end
end

successes, failures = q.pop_all
  #
  # Stagnum::DoneQueue extends Thread::Queue
  # but has a #pop_all convenience method

pp successes
  #
  # ==>
  #
  # [[:success, {i: 0, tname: "pool-zero__0"}],
  #  [:success, {i: 3, tname: "pool-zero__3"}],
  #  [:success, {i: 1, tname: "pool-zero__1"}],
  #  [:success, {i: 2, tname: "pool-zero__2"}],
  #  [:success, {i: 7, tname: "pool-zero__2"}],
  #  [:success, {i: 5, tname: "pool-zero__3"}],
  #  [:success, {i: 9, tname: "pool-zero__3"}],
  #  [:success, {i: 6, tname: "pool-zero__1"}],
  #  [:success, {i: 4, tname: "pool-zero__0"}],
  #  [:success, {i: 8, tname: "pool-zero__2"}]]
```

One can use `Thread::Queue` instead of `Stagnum::DoneQueue`

## LICENSE

MIT, see [LICENSE.txt](LICENSE.txt)

