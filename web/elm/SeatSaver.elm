module SeatSaver where

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import StartApp
import Effects exposing (Effects, Never)
import Task exposing (Task)
import Http
import Json.Decode as Json exposing ((:=))


app =
  StartApp.start
  { init = init
  , update = update
  , view = view
  , inputs = [incomingActions]
  }


main: Signal Html
main =
  app.html


port tasks : Signal (Task Never ())
port tasks =
  app.tasks


port seatRequests : Signal Seat
port seatRequests =
  seatRequestsBox.signal


-- MODEL


type alias Seat =
  { seatNo : Int
  , occupied : Bool
  }


type alias Model =
  List Seat


init: (Model, Effects Action)
init =
  ([], Effects.none)


-- EFFECTS

--fetchSeats: Effects Action
--fetchSeats =
  --Http.get decodeSeats "http://localhost:4000/api/seats"
    --|> Task.toMaybe
    --|> Task.map SetSeats
    --|> Effects.task


decodeSeats: Json.Decoder Model
decodeSeats =
  let
    seat =
      Json.object2(\seatNo occupied -> (Seat seatNo occupied))
        ("seatNo" := Json.int)
        ("occupied" := Json.bool)
  in
    Json.at ["data"] (Json.list seat)


sendSeatRequest : Seat -> Effects Action
sendSeatRequest seat =
  Signal.send seatRequestsBox.address seat
    |> Effects.task
    |> Effects.map (always NoOP)

-- UPDATE


type Action = Toggle Seat | SetSeats Model


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Toggle seatToToggle ->
      let
        updateSeat seatFromModel =
            if seatFromModel.seatNo == seatToToggle.seatNo then
              { seatFromModel | occupied = not seatFromModel.occupied }
            else seatFromModel
      in
        (List.map updateSeat model, Effects.none)
    SetSeats seats ->
        (seats, Effects.none)
    RequestSeat seat ->
      (model, sendSeatRequest seat)
    NoOP ->
      (model, Effects.none)


-- VIEW

view: Signal.Address Action -> Model -> Html
view address model =
  ul [ class "seats" ] (List.map (seatItem address) model)


seatItem: Signal.Address Action -> Seat -> Html
seatItem address seat =
  let
    occupiedClass =
      if seat.occupied then "occupied" else "available"
  in
    li
      [ class ("seat " ++ occupiedClass)
      , onClick address (RequestSeat seat)
      ]
      [ text (toString seat.seatNo) ]


-- SIGNALS


port seatLists : Signal Model


incomingActions: Signal Action
incomingActions =
  Signal.map SetSeats seatLists


seatRequestsBox : Signal.Mailbox Seat
seatRequestsBox =
  Signal.mailbox (Seat 0 false)
