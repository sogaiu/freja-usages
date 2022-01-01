(import freja/new_gap_buffer :as gb)
(import freja/state)
(import freja/default-hotkeys :as dh)

(import freja/evaling)

(import ./to-test :as t)

# XXX: for investigation
(defn current-gb
  []
  (get-in state/editor-state [:stack 0 1 :editor :gb]))

(defn sample-fn
  [x y]
  (* x y))

(comment

  (sample-fn 2 3)
  # =>
  6

  )

(defn run-usages
  [gb]
  (-> gb gb/commit!)
  (def {:text src} gb)
  (def test-src
    (try
      (t/rewrite-as-test-file src)
      ([e]
        (eprintf "problem rewriting: %p" e)
        nil)))
  (when test-src
    (evaling/eval-it state/user-env test-src))
  gb)

(put-in dh/gb-binds
        [:control :shift :u]
        (comp dh/reset-blink run-usages))
