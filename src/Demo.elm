module Demo exposing
    ( Page
    , sandbox
    , View, fullScreen
    )

{-|


# Modules

@docs Page

@docs sandbox


# Views

@docs View, fullScreen

-}

import Browser
import Browser.Dom
import Browser.Events
import Element exposing (Element)
import Html exposing (Html)
import Pixels exposing (Pixels)
import Render
import Size exposing (Size)
import Svg exposing (Svg)
import Task



-- Api


{-| -}
type alias Page model msg =
    { generator : Size Pixels -> Svg (Msg msg)
    , size : View
    , init : model
    , update : msg -> model -> model
    , gui : model -> Element msg
    }


{-| -}
sandbox : Page model msg -> Program () (Model model msg) (Msg msg)
sandbox page =
    Browser.element
        { init =
            init
                { model = page.init, generator = page.generator }
        , update =
            update
                { update = page.update }
        , subscriptions =
            subscriptions
        , view =
            view
                { gui = page.gui }
        }



-- Page View


{-| -}
type View
    = FullScreen


{-| -}
fullScreen : View
fullScreen =
    FullScreen



-- Init


type alias Model page msg =
    { size : Size Pixels
    , generator : Size Pixels -> Svg (Msg msg)
    , picture : Maybe (Svg (Msg msg))
    , page : page
    }


init :
    { model : model, generator : Size Pixels -> Svg (Msg msg) }
    -> ()
    -> ( Model model msg, Cmd (Msg msg) )
init page _ =
    ( { size = Size.size (Pixels.float 0) (Pixels.float 0)
      , generator = page.generator
      , picture = Nothing
      , page = page.model
      }
    , Task.perform GotViewport Browser.Dom.getViewport
    )



-- Update


toMsg : msg -> Msg msg
toMsg =
    UserMsg


type Msg msg
    = GotViewport Browser.Dom.Viewport
    | WindowResize Float Float
    | GeneratePicture
    | UserMsg msg


update :
    { update : msg -> model -> model }
    -> Msg msg
    -> Model model msg
    -> ( Model model msg, Cmd (Msg msg) )
update page msg model =
    case msg of
        GotViewport { viewport } ->
            update
                page
                (WindowResize viewport.width viewport.height)
                model

        WindowResize width height ->
            { model | size = Debug.log "size" <| Size.size (Pixels.float width) (Pixels.float height) }
                |> update page GeneratePicture

        GeneratePicture ->
            ( { model | picture = Just <| model.generator model.size }, Cmd.none )

        UserMsg userMsg ->
            ( { model | page = page.update userMsg model.page }, Cmd.none )


subscriptions : model -> Sub (Msg msg)
subscriptions _ =
    Browser.Events.onResize (\w h -> WindowResize (toFloat w) (toFloat h))



-- View


view : { gui : model -> Element msg } -> Model model msg -> Html (Msg msg)
view page model =
    let
        picture =
            case model.picture of
                Nothing ->
                    Element.none

                Just rendering ->
                    Render.cartesian model.size rendering
                        |> Element.html

        gui =
            page.gui model.page
                |> Element.map toMsg
    in
    Element.layout
        [ Element.inFront gui ]
        picture
