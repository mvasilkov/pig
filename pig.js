(function() {
  var chat, help, on_off, pack, pack_show, packet;
  var options = {item: '<li><span style="display:none" class="time"></span><span class="log"></span></li>'};
  var hackerList = new List('hacker-list', options);

  chat = io.connect('https://localhost:8080/chat', {
    secure: true
  });

  help = document.querySelector('#help_box') || document.getElementById('help');

  chat.on('connect', function() {
    chat.emit('check', window.location.hostname, window.location.pathname, window.location.search);
    return help.style.border = '2px solid #ffda00';
  });

  chat.on('disconnect', function() {
    return help.style.border = '2px solid #ff9900';
  });

  window.onkeydown = function(e) {
    var ep;
    ep = e.keyCode || e.which;
    if (ep === 112) {
      window.focus();
      return on_off();
    }
  };

  packet = document.querySelector('#packet') || document.getElementById('packet');
  hacker_list = document.querySelector('#hacker-list') || document.getElementById('hacker-list');

  pack = document.querySelector('#pack') || document.getElementById('pack');

  packet.onkeypress = function(e) {
    var packetVal;
    if (e.which === 13) {
      packetVal = packet.value;
      chat.emit('pack', window.location.hostname, window.location.pathname, window.location.search, packetVal);
      return packet.value = '';
    }
  };

  chat.on('log', function(log) {
      hackerList.add({time: Date(), log: log})
      hackerList.sort('time', { asc: false });
  });

  chat.on('confirm', function(ret) {
    chat.emit('check', window.location.hostname, window.location.pathname, window.location.search);
    return on_off();
  });

  chat.on('help', function(ret) {
    var packetVal;
    packetVal = packet.value;
    help.innerHTML = ret;
    return help.style.border = '2px solid #ffda00';
  });
  chat.on('email', function(ret) {
    return help.style.border = '2px solid #daff00';
  });

  pack_show = 0;

  on_off = function() {
    pack_show = (pack_show + 1) % 2;
    if (pack_show) {
      hacker_list.style.display = 'block';
      packet.style.display = 'block';
      packet.focus();
      return packet.select();
    } else {
      hacker_list.style.display = 'none';
      return packet.style.display = 'none';
    }
  };

  pack.onmouseover = function(e) {
    return packet.focus();
  };

  pack.onmouseout = function(e) {
    return packet.blur();
  };

  packet.onfocus = function(e) {
    return packet.style.backgroundColor = '#ffeb73';
  };

}).call(this);
