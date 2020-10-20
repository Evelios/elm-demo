module Main exposing (..)

import Browser
import Browser.Dom
import Browser.Events
import Element
import Html exposing (Html)
import Picture
import Pixels exposing (Pixels)
import Render
import Size exposing (Size)
import Svg exposing (Svg)
import Task


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- Init


type alias Model msg =
    { size : Size Pixels
    , picture : Maybe (Svg msg)
    }


init : () -> ( Model msg, Cmd Msg )
init _ =
    ( { size = Size.size (Pixels.float 0) (Pixels.float 0)
      , picture = Nothing
      }
    , Task.perform GotViewport Browser.Dom.getViewport
    )



-- Update


type Msg
    = GotViewport Browser.Dom.Viewport
    | WindowResize Float Float
    | GeneratePicture


update : Msg -> Model msg -> ( Model msg, Cmd msg )
update msg model =
    case msg of
        GotViewport { viewport } ->
            update
                (WindowResize viewport.width viewport.height)
                model

        WindowResize width height ->
            { model | size = Debug.log "size" <| Size.size (Pixels.float width) (Pixels.float height) }
                |> update GeneratePicture

        GeneratePicture ->
            ( { model | picture = Just <| Picture.drawing model.size }, Cmd.none )


subscriptions : model -> Sub Msg
subscriptions _ =
    Browser.Events.onResize (\w h -> WindowResize (toFloat w) (toFloat h))



-- View


view : Model msg -> Html msg
view model =
    Element.layout [] <|
        case model.picture of
            Nothing ->
                Element.none

            Just picture ->
                Render.cartesian model.size picture
                    |> Element.html
