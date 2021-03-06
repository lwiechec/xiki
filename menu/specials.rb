module Xiki
  class Specials
    MENU = "
      - see/
        - keys/
          > Find next special char in this view
          - search+just+special
        <@ encoding/
        @ascii/
      "

    def self.menu_after output, *args

      return if args != []

      # /, so add output...

      dir = Tree.dir :file=>1

      txt = `od -ct uC #{dir}`.gsub(/^/, '| ').gsub(/ +$/, '')

      "#{txt}#{output}"
    rescue RuntimeError=>e
      raise e if e.message !~ /This menu must be nested/   # Only handle if it's the complaining about not nesting under a dir

      "#{e.message}\n#{output}"

    end
  end
end
