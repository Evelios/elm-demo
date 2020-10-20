module Demo exposing (static)

{-|


# Modules

@docs static

-}

import Browser
import Browser.Dom
import Browser.Events
import Element
import Html exposing (Html)
import Pixels exposing (Pixels)
import Render
import Size exposing (Size)
import Svg exposing (Svg)
import Task



-- Api


static : (Size Pixels -> Svg Msg) -> Program () (Model Msg) Msg
static generator =
    Browser.element
        { init = init generator
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- Init


type alias Model msg =
    { size : Size Pixels
    , generator : Size Pixels -> Svg msg
    , picture : Maybe (Svg msg)
    }


init : (Size Pixels -> Svg msg) -> () -> ( Model msg, Cmd Msg )
init generator _ =
    ( { size = Size.size (Pixels.float 0) (Pixels.float 0)
      , generator = generator
      , picture = Nothing
      }
    , Task.perform GotViewport Browser.Dom.getViewport
    )



-- Update


type Msg
    = GotViewport Browser.Dom.Viewport
    | WindowResize Float Float
    | GeneratePicture


update : Msg -> Model msg -> ( Model msg, Cmd Msg )
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
            ( { model | picture = Just <| model.generator model.size }, Cmd.none )


subscriptions : model -> Sub Msg
subscriptions _ =
    Browser.Events.onResize (\w h -> WindowResize (toFloat w) (toFloat h))



-- View


view : Model Msg -> Html Msg
view model =
    Element.layout [] <|
        case model.picture of
            Nothing ->
                Element.none

            Just picture ->
                Render.cartesian model.size picture
                    |> Element.html
