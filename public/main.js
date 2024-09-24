document.addEventListener('DOMContentLoaded', setupUI);
function setupUI() {
  listDevices();
  document.querySelector('.nav-toggle').addEventListener ('click', toggleNav);
}

function toggleNav() {
  var nav = document.querySelector(".nav-menu");
  if (nav.classList.contains('is-active')) {
    nav.classList.remove('is-active');
  } else {
    nav.classList.add('is-active');
  }
}

function listDevices() {
  var request = new XMLHttpRequest();
  request.open('GET', location.origin + '/api/devices', true);

  request.onload = function() {
    if (this.status >= 200 && this.status < 400) {
      var devices = JSON.parse(this.response);

      if (devices.length === 0) {
        console.log("No devices present")
        return;
      }

      var list = document.querySelector('.device-list');
      list.innerHTML = '';

      devices.sort(function(a,b){
        return new Date(b.added) - new Date(a.added);
      });

      devices.forEach(function(l) {
        console.log(l)
        var t = document.querySelector('.device-template');
        t.content.querySelector('.device-name').textContent = l.name;
        t.content.querySelector('.device-id').textContent = l.id;
        t.content.querySelector('.device-link').textContent = l.address;
        t.content.querySelector('.device-link').href = 'http://' + l.address;

        var clone = document.importNode(t.content, true);
        list.appendChild(clone);
      });

    } else {
      console.log("We reached our target server, but it returned an error")
    }
  };

  request.onerror = function() {
    console.log("There was a connection error of some sort")
  };

  request.send();
}

function addTD(e, text) {
  var td = document.createElement('td');
  td.innerHTML = text;
  return e.appendChild(td);
}