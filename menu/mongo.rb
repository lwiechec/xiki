module Xiki
  class Mongo
    MENU = %`
      - .collections/
      - docs/
        > Create
        @foo.save({_id:"a", txt:"b"})

        > Show
        @foo.find()
        @foo.find({_id:"a"})

        > Update
        @foo.update({_id:"a"}, {txt:"bbb"})

        > Delete
        @foo.remove({_id:"a"})
      `

    def self.collections collection=nil, doc=nil

      collection.sub!(/\/$/, '') if collection

      # /, so list databases

      if ! collection
        json = self.run 'printjson(db._adminCommand("listDatabases"))'
        o = JSON[json]
        return o["databases"].map{|d| "#{d['name']}/"}
      end

      # /db/, so list records

      if ! doc
        txt = self.run("db.#{collection}.find()")
        txt = %Q`> No documents yet.  Create one?\n{ "_id":"id", "name":"Steve", "description":"whatever"}` if txt == ""
        return txt.gsub(/^/, '| ')
      end

      # /db/doc, so save

      doc.sub!(/^\| /, '')
      command = "db.#{collection}.save(#{doc})"

      txt = self.run command   # .gsub(/^/, '| ')

      "@flash/- saved!"

    end

    def self.run command
      command << ".forEach(printjson)" if command =~ /.find\(/
      txt = `mongo admin --eval '#{command}'`

      if txt =~ /couldn't connect to server/
        raise "> Mongo isn't running. Start it?
          @/tmp/
            % mongod
          ".unindent
      end

      txt.sub /(.+\n){2}/, ''   # Delete first 2 lines
    end

    def self.init

      # - Is this being called anywhere?
      #   - Maybe have item in menu that saves it to startup
      #     - maybe just shows file syntax for adding to a file!

      Launcher.add(/^db\./) do |l|   # General db... lines
        l.strip!
        txt = self.run l
        Tree.under "#{txt.strip}\n", :escape=>'| ', :no_slash=>1
      end

      Launcher.add(/^(\w+)\.(save|update)\(/) do |l|   # Shortcut for foo.save()
        l.strip!
        l = "db.#{l}"
        txt = self.run l
        Tree.under "done#{txt.strip}\n", :escape=>'| ', :no_slash=>1
      end

      Launcher.add(/^(\w+)\.find\(/) do |l|   # Shortcut for foo.find()
        l.strip!
        l = "db.#{l}"
        txt = self.run l
        Tree.under "#{txt.strip}\n", :escape=>'| ', :no_slash=>1
      end

      Launcher.add(/^(\w+)\.remove\(/) do |l|   # Shortcut for foo.remove()
        l.strip!
        l = "db.#{l}"
        txt = self.run l
        Tree.under "#{txt.strip}\n", :escape=>'| ', :no_slash=>1
      end

    end
  end
  Mongo.init
end
