(import ../freja-usages/to-test :as t)

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

  (defn _verify/dump-results
    []
    (if-let [test-out (dyn :usages-as-tests/test-out)]
      (spit test-out (marshal _verify/test-results))
      # XXX: could this sometimes have problems?
      (printf "%p" _verify/test-results)))

  (_verify/start-tests)

  (defn my-fn
    [x]
    (+ x 1))

  (upscope

    (def a 1)

    (_verify/is
    (my-fn a)
    # =>
    2 "line-10")

    )

  (my-fn 8)
  (_verify/end-tests)
  (_verify/dump-results)

  ``

  )
