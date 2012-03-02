var pig_server = 'https://localhost:8080'

// http://www.w3.org/TR/XMLHttpRequest/
var data = new XMLHttpRequest()
function callOtherDomain(url) {
    if(data)
    {
        data.open('GET', url, true)
        data.onreadystatechange = handler
        data.send()
    }
}
function handler(evtXHR) {
    if (data.readyState == 4) /* data transfer completed */
    {
        if (data.status == 200)
            $('body').append(data.responseText)
        else
            $('body').append('') /* TODO handle other status codes */
    }
    else
        dump('ATTN readyState: ' + data.readyState)
}

if(window.location != pig_server) {
    callOtherDomain(pig_server)
}
