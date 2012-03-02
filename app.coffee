send_email = require './plugins/email'

_  = require 'underscore'
db = require 'nstore'
fs = require 'fs'
db = db.extend(require('nstore/query')())
users = db.new('db/cosmin.db', -> {})
history = db.new('db/history.db', -> {})
log = console.log

express = require('express')
app = express.createServer({key: fs.readFileSync('ssl/privatekey.pem').toString(), cert: fs.readFileSync('ssl/certificate.pem').toString()})
io  = require('socket.io').listen(app)
io.set('log level', 1)

#app.use app.router
#app.use express.compiler({src: __dirname + "/coffee", dest: __dirname + "/public", enable: ["coffeescript"]})
#app.use express.static(__dirname + "/public")

app.listen(8080)


app.get '/dotjs', (req, res) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.sendfile __dirname + '/dotjs/default.js'

app.get '/list', (req, res) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.sendfile __dirname + '/list.min.js'

app.get '/js', (req, res) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.sendfile __dirname + '/pig.js'

app.get '/', (req, res) ->
    origin = req.headers.origin
    history.save null, {date: new Date(), origin: req.headers.origin,  referer: req.headers.referer}, (err) ->
    res.header 'Access-Control-Allow-Origin', '*'
    res.sendfile __dirname + '/pig.html'

chat = io.of '/chat'
chat.on 'connection', (socket) ->
    socket.on 'disconnect', -> {}

    socket.on 'check', (hostname, pathname, search) ->
        url = hostname + pathname + search
        socket.emit 'help', ''
        users.get url, (err, doc, key) ->
            if err
                false
            else
                input = ''
                for val in doc['tags']
                    input = input + ' ' + val
                socket.emit 'help', input

    tag_array = (input, ident) ->
        reg = new RegExp ident+"\(\\w+\)", "g"
        ret = new Array()
        tags = input.match reg
        if tags
            tags.forEach (element, index, array) ->
                ret.push element.replace ident, ''
        return ret

    socket.on 'pack', (hostname, pathname, search, input) ->
        input ?= 'undefined'
        switch input
            when 'undefined' then log 'undefined input'
            when '' then socket.emit 'confirm', 'ok'
            when '?' then false
            when 'help' then socket.emit 'help', '#add_tag    !del_tag'
            when '!?' then false
            when '!help' then socket.emit 'confirm', 'ok'
            else
                url = hostname + pathname + search
                users.save null, {hostname: hostname, pathname: pathname, search: search, date: new Date(), input: input}, (err) ->
                    if err
                        throw err

                    chat.emit 'log', input
                    
                    # process tags
                    # TODO: implement top domain tags
                    at_list = tag_array input, "@"
                    at_list.forEach (user) ->
                        sent = new send_email user, url, input
                        if sent
                            socket.emit 'email', 'ok'
                        else
                            socket.emit 'email', 'err'

                    tag_list = tag_array input, "#"
                    notag_list = tag_array input, "!"
                    users.get url, (err, doc, key) ->
                        if !err
                            tag_list = _.uniq tag_list.concat(doc['tags'])

                        difftags = _.difference tag_list, notag_list

                        # TODO: execute only if tags change
                        users.save url, {tags: difftags}, (err) ->
                            if err
                                throw err
                            socket.emit 'confirm', 'ok'
