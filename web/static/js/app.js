// Brunch automatically concatenates all files in your
// watched paths. Those paths can be configured at
// config.paths.watched in "brunch-config.js".
//
// However, those files will only be executed if
// explicitly imported. The only exception are files
// in vendor, which are never wrapped in imports and
// therefore are always executed.

// Import dependencies
//
// If you no longer want to use a dependency, remember
// to also remove its path from "config.paths.watched".
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

import socket from "./socket"

//let elmDiv = document.getElementById('elm-main')
//let elmApp = Elm.embed(Elm.SeatSaver, elmDiv);

var elmDiv = document.getElementById('elm-main')
  , initialState = {seatLists: []}
  , elmApp = Elm.embed(Elm.SeatSaver, elmDiv, initialState);

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("seats:planner", {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.on('set_seats', data => {
  console.log('got seats', data.seats)
  elmApp.ports.seatLists.send(data.seats)
})

// listen for seat requests
elm.ports.seatRequests.subscribe(seat => {
  console.log(seat)
})
