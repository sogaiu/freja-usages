(import freja/default-hotkeys :as dh)

(import ./freja-usages :as fu)

(dh/set-key dh/gb-binds
            [:control :shift :u]
            (comp dh/reset-blink fu/run-usages))
