#http://www.hacksparrow.com/node-js-exports-vs-module-exports.html
# TODO: maybe use http://www.nodemailer.org/ ?
module.exports = (user, url, input) ->
    email = new Array()
    email['cosmin'] = 'cosmin.neagu@gmail.com'
    addr = email[user]
    mailer = require('mailer')
    mailer.send {
        host : '',
        #port : '25',
        port : '587',
        domain : '',
        to : addr,
        from : '',
        subject : 'Shared: ' + url,
        body: url + '\n' + input,
        authentication : 'login',
        username : '',
        password : ''
    }, (err, result) ->
        if err
            console.log(err)
        else
            if addr
                console.log('sent email to ' + user + ' ' + addr)
                true
            else
                console.log('email not sent: ' + user + ' ' + addr)
                false
