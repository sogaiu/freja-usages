(import ../freja-usages/usages/to-test :as t)

(comment

  (def src
    ``
    (defn my-fn
      [x]
      (+ x 1))

    (comment

      (def a 1)

      (my-fn a)
      # =>
      2

      )

    (my-fn 8)
    ``)

  (t/rewrite-as-test-file src)
  # =>
  ``
  # influenced by janet's tools/helper.janet

  (var _verify/start-time 0)
  (var _verify/end-time 0)
  (var _verify/test-results @[])

  (defmacro _verify/is
    [t-form e-form &opt name]
    (default name
      (string "test-" (inc (length _verify/test-results))))
    (with-syms [$ts $tr
                $es $er]
      ~(do
         (def [,$ts ,$tr] (protect ,t-form))
         (def [,$es ,$er] (protect ,e-form))
         (array/push _verify/test-results
                     {:expected-form ',e-form
                      :expected-value ,$er
                      :name ,name
                      :passed (if (and ,$ts ,$es)
                                (deep= ,$tr ,$er)
                                nil)
                      :test-form ',t-form
                      :test-value ,$tr
                      :type :is})
         ,name)))

  (defn _verify/start-tests
    []
    (set _verify/start-time (os/clock))
    (set _verify/test-results @[]))

  (defn _verify/end-tests
    []
    (set _verify/end-time (os/clock)))

  (defn _verify/print-color
    [msg color]
    # XXX: what if color doesn't match...
    (let [color-num (match color
                      :black 30
                      :blue 34
                      :cyan 36
                      :green 32
                      :magenta 35
                      :red 31
                      :white 37
                      :yellow 33)]
      (prin (string "\e[" color-num "m"
                    msg
                    "\e[0m"))))

  (defn _verify/dashes
    [&opt n]
    (default n 60)
    (string/repeat "-" n))

  (defn _verify/print-dashes
    [&opt n]
    (print (_verify/dashes n)))

  (defn _verify/print-form
    [form &opt color]
    (def buf @"")
    (with-dyns [:out buf]
      (printf "%m" form))
    (def msg (string/trimr buf))
    (print ":")
    (if color
      (_verify/print-color msg color)
      (prin msg))
    (print))

  (defn _verify/report
    []
    (var total-tests 0)
    (var total-passed 0)
    # analyze results
    (var passed 0)
    (var num-tests (length _verify/test-results))
    (var fails @[])
    (each test-result _verify/test-results
      (++ total-tests)
      (def {:passed test-passed} test-result)
      (if test-passed
        (do
          (++ passed)
          (++ total-passed))
        (array/push fails test-result)))
    # report any failures
    (var i 0)
    (each fail fails
      (def {:test-value test-value
            :expected-value expected-value
            :name test-name
            :passed test-passed
            :test-form test-form} fail)
      (++ i)
      (print)
      (prin "--(")
      (_verify/print-color i :cyan)
      (print ")--")
      (print)
      #
      (_verify/print-color "failed:" :yellow)
      (print)
      (_verify/print-color test-name :red)
      (print)
      #
      (print)
      (_verify/print-color "form" :yellow)
      (_verify/print-form test-form)
      #
      (print)
      (_verify/print-color "expected" :yellow)
      (_verify/print-form expected-value)
      #
      (print)
      (_verify/print-color "actual" :yellow)
      (_verify/print-form test-value :blue))
    (when (zero? (length fails))
      (print)
      (print "No tests failed."))
    # summarize totals
    (print)
    (_verify/print-dashes)
    (when (= 0 total-tests)
      (print "No tests found, so no judgements made.")
      (break true))
    (if (not= total-passed total-tests)
      (_verify/print-color total-passed :red)
      (_verify/print-color total-passed :green))
    (prin " of ")
    (_verify/print-color total-tests :green)
    (print " passed")
    (_verify/print-dashes)
    (when (not= total-passed total-tests)
      (os/exit 1)))
  (_verify/start-tests)

  (defn my-fn
    [x]
    (+ x 1))




    (def a 1)

    (_verify/is
    (my-fn a)
    # =>
    2 "line-10")

    :smile

  (my-fn 8)
  (_verify/end-tests)
  (_verify/report)

  ``

  )
