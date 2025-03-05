
#
# Specifying stagnum
#
# Tue Mar  4 14:27:37 JST 2025  The Board Room
#


group Stagnum do

  test 'general use case' do

    pool = Stagnum::Pool.new('pool-zero', 4)

    q = Stagnum::DoneQueue.new

    30.times do |i|

      pool.enqueue(q, { i: i }) do |d|

        sleep rand * 1

        d[:tname] = Thread.current.name
      end
    end

    successes, failures = q.pop_all

    assert_is_a successes, Array
    assert_is_a failures, Array

    assert_size successes, 30
    assert_size failures, 0

    assert(
      successes.map { |s| s[1][:tname] }.uniq.sort,
      %w[ pool-zero__0 pool-zero__1 pool-zero__2 pool-zero__3 ])
  end

  test 'on_* test' do

    pool = Stagnum::Pool.new('pool-zero', 4)

    s, f = [], []

    q = Stagnum::DoneQueue.new
    q.on_success do |r|
      s << r
    end
    q.on_failure do |r|
      f << r
    end

    30.times do |i|

      pool.enqueue(q, { i: i }) do |d|

        sleep rand * 1

        d[:tname] = Thread.current.name
      end
    end

    q.pop_all

    assert_size s, 30
    assert_size f, 0

    assert s[0][0], :success
    assert_match s[0][1][:tname], /^pool-zero__\d$/
  end
end

